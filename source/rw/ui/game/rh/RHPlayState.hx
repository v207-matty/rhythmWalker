package rw.ui.game.rh;

import rw.ui.game.song.SongEventData;
import flixel.addons.transition.*;
import flixel.text.FlxText;
import flixel.*;
import flixel.util.FlxTimer;
import rw.ui.menu.freeplay.Freeplay;
import rw.save.Save;
import flixel.addons.sound.FlxRhythmConductorUtil;
import rw.ui.game.song.*;

class RHPlayState extends ConductorState
{
	public static var instance:RHPlayState;

	public var song(default, null):RHSong;
	public var songData(default, null):SongData;
	public var songEvents:Array<FlxTimer> = [];

	public var scoreText(default, null):FlxText;
	public var totalScore:Int = 0;
	public var score:Int = 0;

	public var camGame(default, null):FlxCamera;
	public var camGameFollow(default, null):FlxObject;

	public var camHUD(default, null):FlxCamera;
	public var camTransition(default, null):FlxCamera;

	public var timeBar:PlayTimeBar;

	public var components(get, never):Array<RHPlayableComponent>;

	function get_components():Array<RHPlayableComponent> return [song];

	public function runOnComponents(a:RHPlayableComponent->Void) if (a != null) for (component in components) if (component != null) a(component);

	override public function new(song:String, ?variation:SongVariation = defaultVariation)
	{
		super();

		this.songData = new SongData(song, variation ?? defaultVariation);
	}

	override function destroy()
	{
		super.destroy();

		instance = null;
	}

	override function createTransition(data:TransitionData):Transition
	{
		var trans = super.createTransition(data);
		trans.camera = camTransition;
		return trans;
	}

	override function create()
	{
		instance = null;
		instance = this;

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

		generateSong();

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
		FlxG.sound.music.stop();

		timeBar.linked = false;

		trace('Yay we done');

		if (!skipping) if (Save.saveSongScore(songData.toString(), score, totalScore))
		{
			FlxG.switchState(() -> new ResultsState(songData.toString()));
			return;
		}

		FlxG.switchState(() -> new Freeplay());
	}

	public function leave() onSongEnd(true);

	function generateSong()
	{
		song = SongManager.getRhythmHeaven(songData?.id, songData?.variation ?? defaultVariation);
		if (song != null) song.build();

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
}
