package rw.ui.game;

import flixel.addons.transition.TransitionData;
import flixel.addons.transition.Transition;
import rw.save.Save;
import rw.ui.menu.MainMenu;
import rw.ui.game.song.SongEventData;
import rw.util.*;
import rw.ui.objects.*;
import rw.ui.game.dialogue.*;
import rw.ui.game.stage.*;
import rw.ui.game.player.*;
import rw.ui.game.song.*;
import rw.ui.menu.freeplay.*;
import flixel.math.FlxPoint;
import flixel.util.FlxGradient;
import flixel.*;
import flixel.tweens.*;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.sound.FlxRhythmConductorUtil;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

using StringTools;

class PlayState extends ConductorState
{
	public static var instance:PlayState;

	public var immortal(default, null):Bool = #if immortal true #else false #end;

	public var player(default, null):Player;
	public var beatMonsters(default, null):FlxSpriteGroup;
	public var stage(default, null):Stage;

	public var song(default, null):Song;
	public var songData(default, null):SongData;
	public var songEvents:Array<FlxTimer> = [];

	public var components(get, never):Array<PlayableComponent>;

	function get_components():Array<PlayableComponent> return [stage, song];

	public function runOnComponents(a:PlayableComponent->Void) if (a != null) for (component in components) if (component != null) a(component);

	public var scoreText(default, null):FlxText;
	public var totalScore:Int = 0;
	public var score:Int = 0;
	public var hits:Int = 0;

	public var camGame(default, null):FlxCamera;
	public var camGameFollow(default, null):FlxObject;

	public var camHUD(default, null):FlxCamera;

	public var beatMonsterSpawner(default, null):FlxSprite;

	public var data(default, null) = {
		player: {
			cutsceneVelocityDamping: false
		},
		beatMonsters: {
			padding: 0.0,
			spawn: true,
			stepRate: 4,
			scale: 1.0
		}
	};

	public var stageBackLayer(default, null):FlxSpriteGroup;
	public var stageFrontLayer(default, null):FlxSpriteGroup;

	public var timeBar(default, null):RWSprite;
	public var timeBarSongLinked:Bool = false;
	public var timeBarTarget:Float = 0.0;

	public var transitionCam:FlxCamera;

	override public function new(song:String, ?variation:SongVariation = defaultVariation)
	{
		super(null, null);

		this.songData = new SongData(song, variation ?? defaultVariation);

		FlxG.log.add(song);
	}

	override function destroy()
	{
		super.destroy();

		instance = null;
	}

	override function create()
	{
		instance = null;
		instance = this;

		add(camGameFollow = new FlxObject(FlxG.width / 2, FlxG.height / 2));

		FlxG.cameras.reset(camGame = new FlxCamera());
		FlxG.cameras.add(camHUD = new FlxCamera(), false);
		FlxG.cameras.add(transitionCam = new FlxCamera(), false);
		transitionCam.bgColor.alpha = camHUD.bgColor.alpha = 0;

		camGame.follow(camGameFollow, LOCKON, 0.04);

		resetConductor();

		FlxG.sound.playMusic(Paths.getSong(songData.id, songData.variation), 1, false);
		FlxG.sound.music.onComplete = onSongEnd;

		if (FlxG.sound.music.length < 1)
		{
			skipping = true;
			onSongEnd();

			return;
		}

		FlxRhythmConductorUtil.loadMeta(conductor, FlxRhythmConductorUtil.parseTimeChanges(songData.bpmChanges));

		trace('song len: ${FlxG.sound.music.length / 1000}s');

		stageBackLayer = new FlxSpriteGroup();
		add(stageBackLayer);
		stageBackLayer.camera = camGame;

		createPlayer();
		add(player);

		beatMonsters = new FlxSpriteGroup();
		add(beatMonsters);
		beatMonsters.camera = camGame;

		beatMonsterSpawner = FlxGradient.createGradientFlxSprite(Math.floor(FlxG.width * 1.1), Math.floor(FlxG.height * 0.2),
			[FlxColor.RED, FlxColor.TRANSPARENT]);
		add(beatMonsterSpawner);
		beatMonsterSpawner.camera = camGame;
		beatMonsterSpawner.alpha = 0;

		stageFrontLayer = new FlxSpriteGroup();
		add(stageFrontLayer);
		stageFrontLayer.camera = camGame;

		scoreText = new FlxText(0, 0, FlxG.width, 'BOB', Constants.TEXT_SIZE);
		add(scoreText);
		scoreText.setBorderStyle(OUTLINE, FlxColor.BLACK, Constants.TEXT_OUTLINE_SIZE);
		scoreText.camera = camHUD;
		scoreText.alignment = CENTER;

		generateSong();

		beatMonsterSpawner.shader = beatMonsters.shader;

		for (event in songData.events) addEvent(event);

		transitionIn();

		if (introCutscene()) inIntroCutscene = true;

		timeBar = new RWSprite(null);
		timeBar.makeGraphic(1, 1);
		add(timeBar);
		timeBar.setScale(FlxG.width, Math.floor(Constants.TEXT_SIZE / 2));
		timeBar.y = FlxG.height - timeBar.height;
		timeBar.color = FlxColor.LIME;
		timeBar.setCamera(camHUD);
		timeBar.scale.x = 0;

		timeBarSongLinked = true;

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

	override function createTransition(data:TransitionData):Transition
	{
		var trans = super.createTransition(data);
		trans.camera = transitionCam;
		return trans;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		conductor.update(null);

		if (!inCutscene) managePlayer();
		else if (data.player.cutsceneVelocityDamping) playerVelocityDamping();

		if (beatMonsters != null) manageBeatMonsters();
		if (timeBarSongLinked) timeBarTarget = FlxG.width * (conductor.musicPosition / conductor.musicLength);

		timeBar.scale.x = FlxMath.lerp(timeBar.scale.x, timeBarTarget, 0.04);

		if (scoreText != null)
		{
			scoreText.text = 'Score: $score | Hits Taken: $hits';
			scoreText.screenCenter(X);
		}

		if (FlxG.keys.justPressed.ESCAPE) leave();

		runOnComponents(c -> c.update(elapsed));
	}

	function manageBeatMonsters()
	{
		beatMonsters.y = camGame.viewY;

		for (monster in beatMonsters)
		{
			monster.y += monster.height * (.2 * songData.scrollSpeed);

			if (monster.y > FlxG.height + monster.height)
			{
				beatMonsters.remove(monster);
				monster.destroy();

				continue;
			}

			if (!monster.overlaps(player.collision)) continue;
			if (immortal || inCutscene || player.stunned) continue;
			if (!camGame.visible || camGame.alpha < 0.1) continue;

			player.stunned = true;
			playerPlayAnim('hurt');
			player.velocity.x = 0;

			beatMonsters.remove(monster);
			monster.destroy();

			FlxG.sound.play(Paths.getAudio('game/hurt'));

			hits++;
		}

		if (beatMonsterSpawner == null) return;

		beatMonsterSpawner.y = camGame.viewY;
		beatMonsterSpawner.alpha = FlxMath.lerp(beatMonsterSpawner.alpha, (canSpawnMonster) ? 0.2 : 0, .1);
	}

	public function playerPlayAnim(anim:String, hasFlippedVer:Bool = true)
	{
		if (hasFlippedVer) player.playAnim(anim + ((player.flipX) ? 'R' : 'L'));
		else player.playAnim(anim);
	}

	public var control_left(get, never):Bool;

	function get_control_left():Bool return FlxG.keys.anyPressed([A, LEFT]) || (FlxG.mouse.pressed && FlxG.mouse.x < player.x);

	public var control_right(get, never):Bool;

	function get_control_right():Bool return FlxG.keys.anyPressed([D, RIGHT]) || (FlxG.mouse.pressed && FlxG.mouse.x > player.x);

	public var player_onLeftEdge(default, null):Bool = false;
	public var player_onRightEdge(default, null):Bool = false;

	function managePlayer()
	{
		player.maxVelocity.x = player.data.config.maxVelocityBase * songData.scrollSpeed;

		if (control_left) move(-1, true);
		else if (control_right) move(1, true);
		else playerVelocityDamping();

		player_onLeftEdge = player.x < player.width;
		player_onRightEdge = player.x > FlxG.width - (player.width * 2);

		if (player_onLeftEdge || player_onRightEdge)
		{
			if (player_onLeftEdge) player.x = player.width;
			if (player_onRightEdge) player.x = FlxG.width - (player.width * 2);
			player.velocity.x = 0;
		}
	}

	function leave()
	{
		if (inCutscene || !camHUD.visible || camHUD.alpha < 0.1) return;

		seenEndCutscene = seenIntroCutscene = true;
		skipping = true;
		onSongEnd();
	}

	public function move(mult = 1.0, playerMovement = false)
	{
		var shiftThing:Float = 1;

		if (playerMovement)
		{
			if (FlxG.keys.pressed.SHIFT) shiftThing *= 2;
			else if (FlxG.mouse.pressed) shiftThing *= 2 * (player.x / FlxG.mouse.x);
		}

		player.flipX = mult > -1;
		player.velocity.x += (player.data.config.speed * shiftThing) * mult;

		if (!player.stunned) if (!player.animation.name.startsWith('move') || player.animation.finished) playerPlayAnim('move');
	}

	public function playerVelocityDamping() player.velocity.x = FlxMath.lerp(player.velocity.x, 0, 0.1);

	public var skipping:Bool = false;

	public function onSongEnd()
	{
		if (inCutscene) return;

		FlxG.sound.music.stop();

		timeBarSongLinked = false;
		inEndCutscene = true;

		if (!skipping) if (endCutscene())
		{
			trace('Playin end cutscene');
			return;
		}

		trace('Yay we done');

		if (!immortal && !skipping) if (Save.saveSongScore(songData.toString(), score, totalScore))
		{
			FlxG.switchState(() -> new ResultsState(songData.toString()));
			return;
		}

		FlxG.switchState(() -> new MainMenu(true));
	}

	public var canSpawnMonster(get, never):Bool;

	function get_canSpawnMonster():Bool return !inEndCutscene && data.beatMonsters.spawn;

	override function onStepHit(step:Int, backward:Bool)
	{
		super.onStepHit(step, backward);

		if (!inCutscene && ((canSpawnMonster || !inEndCutscene && beatMonsters.members.length > 0) && data.beatMonsters.stepRate > 0))
		{
			var scoreInc:Int = 25;

			totalScore += scoreInc;
			if (!player.stunned) score += scoreInc;
		}

		if (canSpawnMonster && Math.floor(step % data.beatMonsters.stepRate) == 0) spawnBeatMonster();

		runOnComponents(c -> c.onStepHit(step, backward));
	}

	override function onBeatHit(beat:Int, backward:Bool)
	{
		super.onBeatHit(beat, backward);

		for (layer in [stageBackLayer, stageFrontLayer,])
		{
			layer.forEach(sprite ->
			{
				if (!Std.isOfType(sprite, StageSprite)) return;

				var stageSprite = cast(sprite, StageSprite);
				if (stageSprite == null) return;

				stageSprite.dance();
			});
		}

		runOnComponents(c -> c.onBeatHit(beat, backward));
	}

	public function spawnBeatMonster()
	{
		var beatMonster:FlxSprite = new FlxSprite().makeGraphic(32, 32, FlxColor.RED);
		beatMonster.scale.y = beatMonster.scale.x = data.beatMonsters.scale;
		beatMonster.updateHitbox();

		beatMonster.x = player.getGraphicMidpoint().x - (beatMonster.width / 2) - data.beatMonsters.padding;
		beatMonster.y = beatMonster.height * -2;

		beatMonster.shader = beatMonsters.shader;

		beatMonsters.add(beatMonster);

		beatMonsterSpawner.alpha += .1;
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
			case 'player-idle': playerPlayAnim('idle');

			case 'song-end': onSongEnd();

			case 'camera-off', 'cam-off': camGame.visible = false;

			case 'camera-on', 'cam-on': camGame.visible = true;

			case 'player-switch', 'player-change': if (event.data != null) makePlayer(Std.string(event.data));

			case 'stage-switch', 'stage-change': if (event.data != null) makeStage(Std.string(event.data));

			case 'beatmonsters-spawnmonster': spawnBeatMonster();

			case 'beatmonsters-stop': data.beatMonsters.spawn = false;

			case 'beatmonsters-resume', 'beatmonsters-start': data.beatMonsters.spawn = true;

			// the old beat system
			case 'beatmonsters-setrate', 'beatmonsters-rate', 'beatmonsters-setbeatrate', 'beatmonsters-beatrate':
				if (event.data != null
					&& (Std.isOfType(event.data,
						Float) || Std.isOfType(event.data,
							Int) || Std.isOfType(event.data,
							String))) data.beatMonsters.stepRate = Math.floor((Std.parseFloat(Std.string(event.data)) ?? 1.0) * 4);

			case 'beatmonsters-setsteprate', 'beatmonsters-steprate':
				if (event.data != null
					&& (Std.isOfType(event.data,
						Float) || Std.isOfType(event.data,
							Int) || Std.isOfType(event.data, String))) data.beatMonsters.stepRate = Math.floor((Std.parseFloat(Std.string(event.data)) ?? 1));
		}

		runOnComponents(c -> c.onEvent(event));
	}

	function generateSong()
	{
		song = SongManager.get(songData?.id, songData?.variation ?? defaultVariation);
		if (song != null) song.build();

		makeStage(songData?.stage ?? 'stage');
	}

	public function makeStage(stage:String)
	{
		if (stageBackLayer == null || stageFrontLayer == null) return;

		for (layer in [stageBackLayer, stageFrontLayer,])
		{
			for (sprite in layer.members)
			{
				stageBackLayer.members.remove(sprite);
				sprite.destroy();
			}

			layer.clear();
		}

		this.stage = StageManager.get(stage ?? 'stage');
		if (this.stage != null) this.stage.build();
	}

	public function createPlayer()
	{
		player = new Player(null);

		makePlayer(songData?.player);

		playerPlayAnim('idle');

		player.animation.onFinish.add(animName ->
		{
			if (inCutscene) return;

			playerPlayAnim('idle');
			player.stunned = false;
		});

		player.setScale(2);

		player.screenCenter();
		player.y = FlxG.height - player.height * 1.25;

		player.setCamera(camGame);

		if (immortal) player.alpha = .25;
	}

	public function makePlayer(newplayer:String) player.load(newplayer);

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

		return song?.introCutscene() ?? false;
	}

	function endCutscene():Bool
	{
		if (seenEndCutscene) return false;
		seenEndCutscene = true;

		return song?.endingCutscene() ?? false;
	}
}
