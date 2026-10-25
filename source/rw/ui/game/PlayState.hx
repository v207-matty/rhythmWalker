package rw.ui.game;

import rw.ui.game.PlayData.PlayModeData;
import flixel.group.FlxSpriteGroup;
import rw.ui.game.rh.stage.*;
import rw.ui.game.song.SongEventData;
import flixel.addons.transition.*;
import flixel.text.FlxText;
import flixel.*;
import flixel.util.FlxTimer;
import rw.ui.menu.freeplay.Freeplay;
import rw.save.Save;
import flixel.addons.sound.FlxRhythmConductorUtil;
import rw.ui.game.song.*;

class PlayState<ComponentType:PlayableComponent, SongType:ComponentType> extends ConductorState
{
	public var immortal(default, null):Bool = #if immortal true #else false #end;

	public var song(default, null):SongType;

	public var songData(default, null):SongData;
	public var songEvents:Array<FlxTimer> = [];

	public var totalScore:Int = 0;
	public var score:Int = 0;

	public var camGame(default, null):FlxCamera;
	public var camGameFollow(default, null):FlxObject;

	public var camHUD(default, null):FlxCamera;
	public var camTransition(default, null):FlxCamera;

	public var timeBar(default, null):PlayTimeBar;

	public var gameplayElements(default, null):FlxSpriteGroup;

	public var back(default, null):FlxSpriteGroup;
	public var middle(default, null):FlxSpriteGroup;
	public var front(default, null):FlxSpriteGroup;

	public var layers(get, never):Array<FlxSpriteGroup>;

	function get_layers():Array<FlxSpriteGroup> return [back, middle, front];

	public function runOnLayers(a:FlxSpriteGroup->Void) if (a != null) for (layers in layers) if (layers != null) a(layers);

	public var components(get, never):Array<ComponentType>;

	function get_components():Array<ComponentType> return [song];

	public function runOnComponents(a:ComponentType->Void) if (a != null) for (component in components) if (component != null) a(component);

	override public function new(song:String, ?variation:SongVariation = defaultVariation)
	{
		super();

		this.songData = new SongData(song, variation ?? defaultVariation);
	}

	public var mode:PlayModeData;

	override function destroy()
	{
		super.destroy();

		runOnLayers(l ->
		{
			remove(l);

			l.destroy();
			l = null;
		});

		runOnComponents(c -> c.destroy());
	}

	override function createTransition(data:TransitionData):Transition
	{
		var trans = super.createTransition(data);
		trans.camera = camTransition;
		return trans;
	}

	override function create()
	{
		add(camGameFollow = new FlxObject(FlxG.width / 2, FlxG.height / 2));

		FlxG.cameras.reset(camGame = new FlxCamera());
		FlxG.cameras.add(camHUD = new FlxCamera(), false);
		FlxG.cameras.add(camTransition = new FlxCamera(), false);
		camTransition.bgColor.alpha = camHUD.bgColor.alpha = 0;

		camGame.follow(camGameFollow, LOCKON, 0.04);

		resetConductor();

		FlxG.sound.playMusic(Paths.getSong(songData.id, songData.variation), 1, false);
		FlxG.sound.music.onComplete = () -> onSongEnd(false);

		if (FlxG.sound.music.length < 1)
		{
			onSongEnd(true);
			return;
		}

		FlxRhythmConductorUtil.loadMeta(conductor, FlxRhythmConductorUtil.parseTimeChanges(songData.bpmChanges));

		add(back = new FlxSpriteGroup());
		add(middle = new FlxSpriteGroup());
		add(gameplayElements = new FlxSpriteGroup());
		add(front = new FlxSpriteGroup());

		generateState();

		if (introCutscene()) inIntroCutscene = true;

		add(timeBar = new PlayTimeBar());
		timeBar.setCamera(camTransition);

		#if MOBILE_MODE
		var backBtn = new rw.ui.objects.mobile.CornerButton('backBtn');
		backBtn.setCamera(camHUD);
		add(backBtn);
		backBtn.x = FlxG.width - backBtn.width;
		backBtn.onClicked.add(leave);
		#end

		persistentUpdate = true;

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		conductor.update(null);

		updateState(elapsed);

		if (FlxG.keys.justPressed.ESCAPE) leave();

		timeBar.target = FlxG.width * (conductor.musicPosition / conductor.musicLength);

		runOnComponents(c -> c.update(elapsed));
	}

	override function onBeatHit(beat:Int, backward:Bool)
	{
		super.onBeatHit(beat, backward);

		runOnComponents(c -> c.onBeatHit(beat, backward));
	}

	override function onStepHit(step:Int, backward:Bool)
	{
		super.onStepHit(step, backward);

		runOnComponents(c -> c.onStepHit(step, backward));
	}

	public function onSongEnd(skipping:Bool)
	{
		if (inCutscene) return;

		FlxG.sound.music.stop();

		timeBar.linked = false;
		inEndCutscene = true;

		if (!skipping) if (endCutscene())
		{
			trace('Playin end cutscene');
			return;
		}

		trace('Yay we done');

		if (!immortal && !skipping) if (Save.saveSongScore(songData.toString(), score, totalScore, mode))
		{
			FlxG.switchState(() -> new ResultsState(songData.toString()));
			return;
		}

		FlxG.switchState(() -> new Freeplay());
	}

	public function leave()
	{
		if (inCutscene || !camHUD.visible || camHUD.alpha < 0.1) return;

		seenEndCutscene = seenIntroCutscene = true;
		onSongEnd(true);
	}

	function generateState() generateSong();

	function updateState(elapsed:Float) {}

	function generateSong()
	{
		for (event in songData.events) addEvent(event);
	}

	public function addEvent(event:SongEventData)
	{
		var songEvent = new FlxTimer();
		songEvents.push(songEvent);

		songEvent.start(event.time / 1000, function(t)
		{
			if (event.entries?.length > 0) for (e in event.entries) parseEvent({id: e.id, data: e.data});
			else parseEvent({id: event.id, data: event.data});

			songEvents.remove(songEvent);
		});
	}

	// TODO: Def could do a class system here
	function parseEvent(event:SongEventRawData)
	{
		trace(event);

		switch (event.id.toLowerCase())
		{
			case 'song-end': onSongEnd(false);

			case 'camera-off', 'cam-off': camGame.visible = false;

			case 'camera-on', 'cam-on': camGame.visible = true;
		}

		runOnComponents(c -> c.onEvent(event));
	}

	public var inIntroCutscene:Bool = false;
	public var inEndCutscene:Bool = false;
	public var inCutscene(get, never):Bool;

	function get_inCutscene():Bool return inIntroCutscene || inEndCutscene;

	public var seenEndCutscene:Bool = false;
	public var seenIntroCutscene:Bool = false;

	function introCutscene():Bool
	{
		if (seenIntroCutscene) return false;

		seenIntroCutscene = true;

		return false;
	}

	function endCutscene():Bool
	{
		if (seenEndCutscene) return false;

		seenEndCutscene = true;

		return false;
	}
}
