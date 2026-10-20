package ui.game;

import util.*;
import ui.objects.mobile.*;
import ui.objects.*;
import ui.game.dialogue.*;
import ui.game.stage.*;
import ui.game.player.*;
import ui.game.song.*;
import ui.freeplay.*;
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
	var immortal:Bool = Flag.PLAY_IMMORTAL;

	var player:RWSprite;
	var playerStunned:Bool = false;
	var playerCollision:FlxSprite;

	var beatMonsters:FlxSpriteGroup;

	var scrollSpeed:Float = 1;

	var song:Song;
	var songEvents:Array<FlxTimer> = [];

	var scoreText:FlxText;
	var totalScore:Int = 0;
	var score:Int = 0;
	var hits:Int = 0;

	var camGame:FlxCamera;
	var camHUD:FlxCamera;

	var camGameFollow:FlxObject;

	var beatMonsterSpawner:FlxSprite;

	var data = {
		beatMonsters: {
			spawn: true,
			stepRate: 4,
			scale: 1.0
		}
	};

	var playerData:PlayerData;

	var stageBackLayer:FlxSpriteGroup;
	var stageFrontLayer:FlxSpriteGroup;

	var leaveButton:CornerButton;

	var timeBar:RWSprite;
	var timeBarSongLinked:Bool = false;
	var timeBarTarget:Float = 0.0;

	override public function new(song:String, ?variation:SongVariation = defaultVariation)
	{
		super(null, null);

		this.song = new Song(song, variation ?? defaultVariation);

		FlxG.log.add(song);
	}

	override function create()
	{
		FlxTransitionableState.skipNextTransIn = true;

		super.create();

		camGameFollow = new FlxObject(FlxG.width / 2, FlxG.height / 2);
		add(camGameFollow);

		camGame = new FlxCamera();
		FlxG.cameras.add(camGame);

		camGame.follow(camGameFollow, LOCKON, 0.04);

		camHUD = new FlxCamera();
		FlxG.cameras.add(camHUD, false);
		camHUD.bgColor.alpha = 0;

		scrollSpeed = song.scrollSpeed;

		resetConductor();

		FlxG.sound.playMusic(Paths.getSong(song.id, song.variation), 1, false);
		FlxG.sound.music.onComplete = onSongEnd;

		FlxRhythmConductorUtil.loadMeta(conductor, FlxRhythmConductorUtil.parseTimeChanges(song.bpmChanges));

		trace('song len: ${FlxG.sound.music.length / 1000}s');

		stageBackLayer = new FlxSpriteGroup();
		add(stageBackLayer);
		stageBackLayer.camera = camGame;

		makePlayer();

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

		generateStage();

		beatMonsterSpawner.shader = beatMonsters.shader;

		for (event in song.events)
			addEvent(event);

		if (FlxG.sound.music.length < 1)
		{
			skipping = true;
			onSongEnd();
		}

		transitionIn();

		if (introCutscene())
			inIntroCutscene = true;

		timeBar = new RWSprite(null);
		timeBar.makeGraphic(1, 1);
		add(timeBar);
		timeBar.setScale(FlxG.width, Math.floor(Constants.TEXT_SIZE / 2));
		timeBar.y = FlxG.height - timeBar.height;
		timeBar.color = FlxColor.LIME;
		timeBar.setCamera(camHUD);
		timeBar.scale.x = 0;

		timeBarSongLinked = true;

		if (!Flag.IS_MOBILE_MODE)
			return;

		leaveButton = new CornerButton('backBtn');
		leaveButton.setCamera(camHUD);
		add(leaveButton);
		leaveButton.x = FlxG.width - leaveButton.width;
		leaveButton.onClicked.add(leave);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		conductor.update(null);

		if (scoreText != null)
		{
			scoreText.text = 'Score: $score | Hits Taken: $hits';
			scoreText.screenCenter(X);
		}

		if (playerCollision != null)
		{
			playerCollision.x = player.getGraphicMidpoint().x - (playerCollision.width / 2);
			playerCollision.y = player.getGraphicMidpoint().y - (playerCollision.height / 2);
		}

		if (!inCutscene)
			managePlayer();
		else if (song.id == 'encapture')
			playerVelocityDamping();

		if (beatMonsters != null)
			manageBeatMonsters();

		if (timeBarSongLinked)
			timeBarTarget = FlxG.width * (conductor.musicPosition / conductor.musicLength);

		timeBar.scale.x = FlxMath.lerp(timeBar.scale.x, timeBarTarget, 0.04);
	}

	function manageBeatMonsters()
	{
		beatMonsters.y = camGame.viewY;

		for (monster in beatMonsters)
		{
			monster.y += monster.height * (.2 * scrollSpeed);

			if (!immortal
				&& !inCutscene
				&& monster.overlaps(playerCollision)
				&& !playerStunned
				&& camGame.visible
				&& camGame.alpha >= 0.1)
			{
				playerStunned = true;
				playerPlayAnim('hurt');
				player.velocity.x = 0;

				beatMonsters.remove(monster);
				monster.destroy();

				FlxG.sound.play(Paths.getAudio('game/hurt'));

				hits++;
			}

			if (monster.y > FlxG.height + monster.height)
			{
				beatMonsters.remove(monster);
				monster.destroy();
			}
		}

		if (beatMonsterSpawner == null)
			return;

		beatMonsterSpawner.y = camGame.viewY;
		beatMonsterSpawner.alpha = FlxMath.lerp(beatMonsterSpawner.alpha, (canSpawnMonster) ? 0.2 : 0, .1);
	}

	function playerPlayAnim(anim:String, hasFlippedVer:Bool = true)
	{
		if (hasFlippedVer)
			player.animation.play(anim + ((player.flipX) ? 'R' : 'L'));
		else
			player.animation.play(anim);
	}

	function managePlayer()
	{
		player.maxVelocity.x = playerData.config.maxVelocityBase * scrollSpeed;

		if (FlxG.keys.anyPressed([A, LEFT]) || (FlxG.mouse.pressed && FlxG.mouse.x < player.x))
			move(-1);
		else if (FlxG.keys.anyPressed([D, RIGHT]) || (FlxG.mouse.pressed && FlxG.mouse.x > player.x))
			move(1);
		else
			playerVelocityDamping();

		if (player.x < player.width)
		{
			player.x = player.width;
			player.velocity.x = 0;
		}

		if (player.x > FlxG.width - (player.width * 2))
		{
			player.x = FlxG.width - (player.width * 2);
			player.velocity.x = 0;
		}

		if (FlxG.keys.justPressed.ESCAPE)
			leave();
	}

	function leave()
	{
		seenEndCutscene = seenIntroCutscene = true;
		skipping = true;
		onSongEnd();
	}

	function move(mult = 1.0)
	{
		var shiftThing:Float = 1;

		if (FlxG.keys.pressed.SHIFT)
			shiftThing *= 2;
		else if (FlxG.mouse.pressed)
			shiftThing *= 2 * (player.x / FlxG.mouse.x);

		player.flipX = mult > -1;
		player.velocity.x += (playerData.config.speed * shiftThing) * mult;

		if (!playerStunned)
			playerPlayAnim('move');
	}

	function playerVelocityDamping()
		player.velocity.x = FlxMath.lerp(player.velocity.x, 0, 0.1);

	var skipping:Bool = false;

	function onSongEnd()
	{
		if (inCutscene) return;

		seenIntroCutscene = seenEndCutscene = skipping;

		timeBarSongLinked = false;

		FlxG.sound.music.stop();

		inEndCutscene = true;

		if (endCutscene())
		{
			trace('Playin end cutscene');
			return;
		}

		final songCode = '${song.id}-${song.variation}';

		trace('Yay we done');

		if (!immortal && !skipping)
			if (Save.saveSongScore(songCode, score, totalScore))
			{
				FlxG.switchState(() -> new ResultsState(songCode));
				return;
			}

		FlxG.switchState(() -> new Freeplay());
	}

	public var canSpawnMonster(get, never):Bool;

	function get_canSpawnMonster():Bool
		return !inEndCutscene && data.beatMonsters.spawn;

	override function onStepHit(step:Int, backward:Bool)
	{
		super.onStepHit(step, backward);

		if (!inCutscene && ((canSpawnMonster || !inEndCutscene && beatMonsters.members.length > 0) && data.beatMonsters.stepRate > 0))
		{
			var scoreInc:Int = 25;

			totalScore += scoreInc;
			if (!playerStunned)
				score += scoreInc;
		}

		if (canSpawnMonster && Math.floor(step % data.beatMonsters.stepRate) == 0)
			spawnBeatMonster();
	}

	override function onBeatHit(beat:Int, backward:Bool)
	{
		super.onBeatHit(beat, backward);

		for (layer in [stageBackLayer, stageFrontLayer,])
		{
			layer.forEach(sprite ->
			{
				if (!Std.isOfType(sprite, StageSprite))
					return;

				var stageSprite = cast(sprite, StageSprite);
				if (stageSprite == null)
					return;

				stageSprite.dance();
			});
		}

		if (trainGetaway_sky != null && FlxG.sound.music.playing)
		{
			trainGetaway_sky.velocity.x -= trainGetaway_i;
			trainGetaway_i += 0.25;
		}
	}

	function spawnBeatMonster()
	{
		var beatMonster:FlxSprite = new FlxSprite().makeGraphic(32, 32, FlxColor.RED);
		beatMonster.scale.y = beatMonster.scale.x = data.beatMonsters.scale;
		beatMonster.updateHitbox();

		beatMonster.x = player.getGraphicMidpoint().x - (beatMonster.width / 2);
		beatMonster.y = beatMonster.height * -2;

		beatMonster.shader = beatMonsters.shader;

		beatMonsters.add(beatMonster);

		beatMonsterSpawner.alpha += .1;
	}

	function addEvent(event:SongEventData)
	{
		var songEvent = new FlxTimer();
		songEvents.push(songEvent);

		songEvent.start(event.time / 1000, function(t)
		{
			parseEvent(event);
			songEvents.remove(songEvent);
		});
	}

	function parseEvent(event:SongEventData)
	{
		trace(event);

		switch (event.id.toLowerCase())
		{
			case 'player-idle':
				playerPlayAnim('idle');

			case 'encapture-subjectbang':
				if (song.id != 'encapture' || containment04_tubeSubject == null)
					return;

				containment04_tubeSubject.animation.play('bang');
				if (inEndCutscene)
					return;

				camGame.followLerp *= 0.1;
				camGameFollow.setPosition(containment04_tubeSubject.getGraphicMidpoint().x, containment04_tubeSubject.getGraphicMidpoint().y);

				FlxTween.tween(camGame, {zoom: 1.5}, (FlxG.sound.music.length - FlxG.sound.music.time) / 1000, {
					ease: FlxEase.quartOut,
				});

				inEndCutscene = true;

			case 'song-end':
				onSongEnd();

			case 'trainwreak-gun':
				if (song.id == 'train wreak')
					trainWreak_shooter.animation.play('shoot', true);

			case 'traingetaway-reload':
				if (song.id == 'train getaway')
					trainGetaway_shooter.animation.play('reload', true);

			case 'traingetaway-gunjammed':
				if (song.id == 'train getaway')
					trainGetaway_shooter.animation.play('jammed', true);

			case 'traingetaway-gun':
				if (song.id == 'train getaway')
					trainGetaway_shooter.animation.play('shoot${FlxG.random.int(1, 2)}', true);

			case 'camera-off', 'cam-off':
				camGame.visible = false;

			case 'camera-on', 'cam-on':
				camGame.visible = true;

			case 'stage-switch', 'stage-change':
				if (event.data != null)
					makeStage(Std.string(event.data));

			case 'beatmonsters-spawnmonster':
				spawnBeatMonster();

			case 'beatmonsters-stop':
				data.beatMonsters.spawn = false;

			case 'beatmonsters-resume':
				data.beatMonsters.spawn = true;

			// the old beat system
			case 'beatmonsters-setrate', 'beatmonsters-rate', 'beatmonsters-setbeatrate', 'beatmonsters-beatrate':
				if (event.data != null
					&& (Std.isOfType(event.data, Float) || Std.isOfType(event.data, Int) || Std.isOfType(event.data, String)))
					data.beatMonsters.stepRate = Math.floor((Std.parseFloat(Std.string(event.data)) ?? 1.0) * 4);

			case 'beatmonsters-setsteprate', 'beatmonsters-steprate':
				if (event.data != null
					&& (Std.isOfType(event.data, Float) || Std.isOfType(event.data, Int) || Std.isOfType(event.data, String)))
					data.beatMonsters.stepRate = Math.floor((Std.parseFloat(Std.string(event.data)) ?? 1));
		}
	}

	function generateStage()
	{
		switch ([song.id, song.variation])
		{
			case ['mental', defaultVariation]:

			case ['scroll down chinatown', resolved]:
				makeStage('chinatown');

			case ['lost media', defaultVariation]:
				makeStage('crash landing');

			case ['first steps', resolved], ['shift around', resolved]:
				makeStage('stage-withered');

			case ['encapture', defaultVariation]:
				makeStage('containment-04');

			case ['train wreak', defaultVariation]:
				makeStage('train-wreak');

			case ['train getaway', defaultVariation]:
				var fireSegs:Array<Float> = [];
				var jammedSegs:Array<Float> = [];

				function addIncrementSeg(start:Float, inc:Int, skip:Array<Int>, ?jammed:Bool)
				{
					var incs = [0, 0.187, 0.375, 0.562, 0.750, 0.937, 1.125,];

					for (i in 0...inc)
					{
						if (skip.contains(i))
							continue;

						if (jammed)
							jammedSegs.push(start + incs[i]);
						else
							fireSegs.push(start + incs[i]);
					}
				}

				function addSeg(seg:Array<Float>)
					for (thing in seg)
						fireSegs.push(thing);

				addIncrementSeg(3, 7, []);
				addSeg([4.500, 4.781, 5.062, 5.343, 5.625]);
				addIncrementSeg(6, 7, [3]);
				addIncrementSeg(9, 7, [3]);
				addIncrementSeg(12, 7, [3]);
				addIncrementSeg(15, 7, [3]);
				addIncrementSeg(18, 7, [3]);
				addIncrementSeg(21, 7, [3]);
				addIncrementSeg(22.5, 7, [3], true);

				addIncrementSeg(27, 7, [3]);
				addIncrementSeg(30, 7, [3]);
				addIncrementSeg(33, 7, [3]);

				for (time in fireSegs)
					addEvent({
						time: time * 1000,
						id: 'traingetaway-gun'
					});

				for (time in jammedSegs)
					addEvent({
						time: time * 1000,
						id: 'traingetaway-gunJammed'
					});

				makeStage('train-getaway');

			case ['scroll down chinatown', defaultVariation]:
				makeStage('chinatown-bridge');

			default:
				makeStage('stage');
		}
	}

	var containment04_tubeSubject:StageSprite;

	var trainGetaway_i:Float = 1;

	var trainGetaway_sky:FlxBackdrop;
	var trainGetaway_shooter:TrainGetawayShooter;

	var trainWreak_shooter:TrainWreakShooter;

	function makeStage(?stage:String)
	{
		if (stageBackLayer == null || stageFrontLayer == null)
			return;

		for (layer in [stageBackLayer, stageFrontLayer,])
		{
			for (sprite in layer.members)
			{
				stageBackLayer.members.remove(sprite);
				sprite.destroy();
			}

			layer.clear();
		}

		switch (stage.toLowerCase())
		{
			case 'chinatown':
				var sky:FlxBackdrop = new FlxBackdrop(Paths.getImagePath('game/stages/chinatown/town/sky'));
				sky.scale.set(2, 2);
				sky.updateHitbox();
				sky.camera = camGame;

				sky.velocity.x = 2;
				sky.screenCenter();
				stageBackLayer.add(sky);

				var spr = new StageSprite('chinatown/town/town');
				spr.setGraphicSize(FlxG.width, FlxG.height);
				spr.updateHitbox();
				spr.screenCenter();
				stageBackLayer.add(spr);

			case 'crash landing':
				camGame.bgColor = 0xFF0D0712;

				var ship = new StageSprite('$stage/ship');
				var mountains = new StageSprite('$stage/mountains');
				var hills = new StageSprite('$stage/hills');
				var ground = new StageSprite('$stage/ground');
				var frontHills = new StageSprite('$stage/frontHills');

				ship.setScrollFactor(0.05);
				mountains.setScrollFactor(0.1);
				hills.setScrollFactor(0.25);
				ground.setScrollFactor(0.75);
				frontHills.setScrollFactor(0.9);

				for (spr in [ship, mountains, hills, ground, frontHills])
				{
					spr.setGraphicSize(FlxG.width, FlxG.height);
					spr.updateHitbox();
					spr.screenCenter();

					spr.setCamera(camGame);

					if (spr != frontHills)
						stageBackLayer.add(spr);
				}
				stageFrontLayer.add(frontHills);

				ship.setScale(Math.floor(FlxG.width / 1280));
				ship.alpha = .5;

				ship.x += FlxG.width * 2;
				ship.y += -FlxG.height * 2;

				FlxTween.tween(ship, {x: -FlxG.width * 2, y: FlxG.height * 2}, 6, {
					onComplete: t ->
					{
						stageBackLayer.remove(ship);
						ship.destroy();
					}
				});

				player.setScale(1.5);
				player.screenCenter();
				player.y = FlxG.height - player.height * 1.3;

				data.beatMonsters.scale = 0.75;

				if (!Flag.PLAY_SHADERS)
					return;

				var charShader = new CustomShader('dropshadow');

				charShader.setFloat('hue', -9.0);
				charShader.setFloat('saturation', -15.0);
				charShader.setFloat('brightness', -22.0);
				charShader.setFloat('contrast', 0.0);

				player.shader = beatMonsters.shader = charShader;

			case 'stage-withered':
				var backdrop:StageSprite = new StageSprite(stage);
				backdrop.setGraphicSize(FlxG.width, FlxG.height);
				backdrop.updateHitbox();
				backdrop.screenCenter();
				stageBackLayer.add(backdrop);
				backdrop.setCamera(camGame);

				if (!Flag.PLAY_SHADERS)
					return;

				var bgShader = new CustomShader('dropshadow');
				var charShader = new CustomShader('dropshadow');
				var monsterShader = new CustomShader('dropshadow');

				bgShader.setFloat('hue', -24.0);
				bgShader.setFloat('saturation', -24.0);
				bgShader.setFloat('brightness', -36.0);
				bgShader.setFloat('contrast', 0.0);

				charShader.setFloat('hue', -3.0);
				charShader.setFloat('saturation', 7.0);
				charShader.setFloat('brightness', -75.0);
				charShader.setFloat('contrast', 0.0);

				monsterShader.setFloat('hue', -43.0);
				monsterShader.setFloat('saturation', -51.0);
				monsterShader.setFloat('brightness', -73.0);
				monsterShader.setFloat('contrast', 0.0);

				backdrop.shader = bgShader;
				player.shader = charShader;
				beatMonsters.shader = monsterShader;

			case 'containment-04':
				camGame.bgColor = 0xFF595652;

				var floor:FlxBackdrop = new FlxBackdrop(Paths.getImagePath('game/stages/$stage/floor'), X);
				floor.scale.set(2, 2);
				floor.scrollFactor.set();
				floor.updateHitbox();
				floor.camera = camGame;
				floor.y = FlxG.height - floor.height;

				stageBackLayer.add(new Floor(floor, 0xFF696A6A, camGame, FlxPoint.weak(1, 0)));
				stageBackLayer.add(floor);

				var label = new StageSprite('$stage/label');
				label.setScale(2);
				label.screenCenter(X);
				label.y = FlxG.height - label.height;
				stageBackLayer.add(label);

				var tubes = 2 * Math.round(FlxG.width / 1280);

				for (i in 0...tubes)
				{
					var tube = new StageSprite('$stage/tube');
					tube.setScale(2);

					tube.y = FlxG.height - tube.height * 1.4 - 4;
					tube.x = ((tube.width * 2.75) * i) + 32;

					stageBackLayer.add(tube);

					if (i != tubes - 1)
						continue;

					containment04_tubeSubject = tube;
					containment04_tubeSubject.loadGraphic(Paths.getImagePath('game/stages/$stage/subject'), true, 128, 128);
					containment04_tubeSubject.addAnim('idle', [0, 1], 2, true);
					containment04_tubeSubject.addAnim('bang', [2, 3], 6, false);
					containment04_tubeSubject.animation.play('idle');
				}

			case 'train-wreak':
				var sky:FlxBackdrop = new FlxBackdrop(Paths.getImagePath('game/stages/$stage/sky'));
				sky.scale.set(2, 2);
				sky.updateHitbox();
				sky.velocity.x = 10;
				sky.screenCenter(X);
				sky.scrollFactor.set(.25, .25);
				stageBackLayer.add(sky);
				sky.camera = camGame;

				var city:FlxBackdrop = new FlxBackdrop(Paths.getImagePath('game/stages/$stage/city'), X);
				city.scale.set(2, 2);
				city.updateHitbox();
				city.screenCenter(X);
				city.scrollFactor.set(.5, .5);
				stageBackLayer.add(city);
				city.camera = camGame;

				var ground:FlxBackdrop = new FlxBackdrop(Paths.getImagePath('game/stages/$stage/ground'), X);
				ground.scale.set(2, 2);
				ground.updateHitbox();
				ground.screenCenter(X);
				ground.scrollFactor.set(.75, .75);
				ground.camera = camGame;

				stageBackLayer.add(new Floor(ground, 0xFF3B3E44, camGame));
				stageBackLayer.add(ground);

				var pieceList:Array<Dynamic> = [
					['crowds/randoms-left', 0.75],
					['crowds/randoms-right', 0.75],

					['crowds/center', 0.8],

					['smoke', 1],
					['trainSegment', 1],
					['trainGround', 1],
				];

				for (piece in pieceList)
				{
					var isRandom:Bool = Std.string(piece[0]).startsWith('crowds/randoms-');
					var isCrowd:Bool = Std.string(piece[0]).startsWith('crowds/');

					var pspr = new TrainWreakPiece(piece[0], camGame, piece[1]);
					stageBackLayer.add(pspr);

					if (isCrowd)
					{
						pspr.setScale(1.75);
						pspr.screenCenter();
					}

					if (isRandom)
					{
						pspr.x -= pspr.width * (0.5 * ((Std.string(piece[0]).endsWith('left')) ? 1 : -1.25));
						continue;
					}

					if (piece[0] == 'smoke')
					{
						pspr.blend = OVERLAY;
						pspr.alpha = 0.5;
					}
				}

				trainWreak_shooter = new TrainWreakShooter(camGame);
				trainWreak_shooter.screenCenter();
				trainWreak_shooter.x -= trainWreak_shooter.width * 0.25;
				trainWreak_shooter.y -= trainWreak_shooter.width * 0.5;
				stageBackLayer.add(trainWreak_shooter);

				player.screenCenter();
				player.y = FlxG.height - player.height * 1.15;

				persistentUpdate = true;

			case 'train-getaway':
				trainGetaway_sky = new FlxBackdrop(Paths.getImagePath('game/stages/$stage/sky'));
				trainGetaway_sky.scale.set(2, 2);
				trainGetaway_sky.velocity.x = 256 * -5;
				trainGetaway_sky.screenCenter(X);
				stageBackLayer.add(trainGetaway_sky);
				trainGetaway_sky.camera = camGame;

				var train = new FlxBackdrop(Paths.getImagePath('game/stages/$stage/train'), X);
				train.scale.set(2, 2);
				train.updateHitbox();
				train.screenCenter(X);
				train.y = FlxG.height - train.height;
				stageBackLayer.add(train);
				train.camera = camGame;

				player.setScale(1);
				player.updateHitbox();

				player.screenCenter();
				player.y = train.y - player.height * 0.95;

				data.beatMonsters.scale = 0.5;

				persistentUpdate = true;

				trainGetaway_shooter = new TrainGetawayShooter();
				stageBackLayer.add(trainGetaway_shooter);
				trainGetaway_shooter.camera = camGame;

				trainGetaway_shooter.screenCenter();
				trainGetaway_shooter.x = trainGetaway_shooter.width * -5;

				FlxTween.tween(trainGetaway_shooter, {x: FlxG.width - trainGetaway_shooter.width}, 2.75, {
					ease: FlxEase.sineInOut
				});

			case 'chinatown-bridge':
				persistentUpdate = true;

				var sky:FlxBackdrop = new FlxBackdrop(Paths.getImagePath('game/stages/chinatown/bridge/sky'));
				sky.scale.set(4, 4);
				sky.updateHitbox();
				sky.camera = camGame;

				sky.velocity.x = 2;
				sky.screenCenter();
				stageBackLayer.add(sky);

				var bridge:FlxBackdrop = new FlxBackdrop(Paths.getImagePath('game/stages/chinatown/bridge/bridge'), X);
				bridge.scale.set(4, 4);
				bridge.updateHitbox();
				bridge.camera = camGame;
				bridge.y = FlxG.height - bridge.height;
				stageBackLayer.add(bridge);

			case 'stage', 'understage':
				var backdrop:StageSprite = new StageSprite(stage);
				backdrop.setGraphicSize(FlxG.width, FlxG.height);
				backdrop.updateHitbox();
				backdrop.screenCenter();
				stageBackLayer.add(backdrop);
				backdrop.setCamera(camGame);
		}
	}

	function makePlayer()
	{
		playerData = new PlayerData(song.player);
		player = new RWSprite('game/players/${playerData.id}', true, playerData.config.dimensions.sprite[0], playerData.config.dimensions.sprite[1]);

		for (anim in playerData.animations)
		{
			if (anim == null || anim.name == null || anim.frames == null || anim.frames.length < 1)
				continue;

			trace('Player Anim : ${anim.name}');

			if (anim.createFlippedVarients)
			{
				player.addAnim(anim.name + 'L', anim.frames, anim.fps, anim.looped, anim.flipX, anim.flipY);
				player.addAnim(anim.name + 'R', anim.frames, anim.fps, anim.looped, anim.flipX, anim.flipY);
			}
			else
				player.addAnim(anim.name, anim.frames, anim.fps, anim.looped, anim.flipX, anim.flipY);
		}

		playerPlayAnim('idle');
		player.setScale(2);
		player.animation.onFinish.add(animName ->
		{
			if (inCutscene)
				return;

			playerPlayAnim('idle');
			playerStunned = false;
		});

		player.screenCenter();
		player.y = FlxG.height - player.height * 1.25;
		player.setCamera(camGame);

		playerCollision = new FlxSprite().makeGraphic(playerData.config?.dimensions?.hitbox[0] ?? 32, playerData.config?.dimensions?.hitbox[1] ?? 32,
			FlxColor.RED);
		playerCollision.visible = false;
		playerCollision.camera = camGame;

		if (immortal)
			player.alpha = .25;

		add(player);
		add(playerCollision);
	}

	var inIntroCutscene:Bool = false;
	var inEndCutscene:Bool = false;

	var inCutscene(get, never):Bool;

	function get_inCutscene():Bool
		return inIntroCutscene || inEndCutscene;

	var seenEndCutscene:Bool = false;
	var seenIntroCutscene:Bool = false;

	function introCutscene():Bool
	{
		if (seenIntroCutscene)
			return false;

		seenIntroCutscene = true;

		switch ([song.id, song.variation])
		{
			case ['lost media', defaultVariation]:
				camGameFollow.y -= FlxG.height * 2;
				camGame.focusOn(camGameFollow.getPosition());

				FlxTween.tween(camGameFollow, {y: FlxG.height / 2}, 1.5, {
					ease: FlxEase.backInOut,
				});

				FlxTimer.wait(1.75, () -> inIntroCutscene = false);

				return true;

			case ['train wreak', defaultVariation]:
				camGameFollow.y -= FlxG.height * 2;
				camGame.zoom = 0.5;
				camGame.focusOn(camGameFollow.getPosition());

				FlxTween.tween(camGameFollow, {y: FlxG.height / 2}, 6, {
					ease: FlxEase.backInOut,
				});

				function onZoomed(t)
				{
					stageBackLayer.forEach(sprite ->
					{
						if (!Std.isOfType(sprite, StageSprite) || sprite == null || sprite.isOnScreen(sprite.camera))
							return;

						stageBackLayer.remove(sprite);
						sprite.destroy();
					});
				}

				FlxTween.tween(camGame, {zoom: 1}, 6, {
					startDelay: 5,
					ease: FlxEase.backInOut,
					onComplete: onZoomed,
				});

				FlxTimer.wait(12, () -> inIntroCutscene = false);

				return true;

			case ['scroll down chinatown', defaultVariation]:
				playerPlayAnim('chinatown-bridge', false);
				player.y -= player.height * 0.5;

				function partTwo()
				{
					spawnBeatMonster();
					beatMonsterSpawner.alpha += .5;

					FlxTween.tween(player, {x: player.x - 128, y: player.y + player.height * 0.5}, .4, {
						ease: FlxEase.sineOut,
						startDelay: .2,
						onStart: t -> playerPlayAnim('chinatown-bridge-jump', false),
						onComplete: t ->
						{
							playerPlayAnim('idle');
							inEndCutscene = inIntroCutscene = false;
						}
					});
				}

				function partOne()
				{
					inEndCutscene = true;

					playerPlayAnim('chinatown-bridge-lookup', false);
					player.animation.onFinish.add(animName -> if (animName == 'chinatown-bridge-lookup') partTwo());
				}

				FlxTimer.wait(7.5, partOne);

				return true;

			default:
		}
		return false;
	}

	function endCutscene():Bool
	{
		if (seenEndCutscene)
			return false;

		seenEndCutscene = true;

		function idleAndDamp()
		{
			playerPlayAnim('idle');
			new FlxTimer().start(1 / FlxG.updateFramerate, t -> playerVelocityDamping(), FlxG.updateFramerate);
		}

		function ending()
		{

					inEndCutscene = false;
					onSongEnd();
		}

		switch ([song.id, song.variation])
		{
			case ['train wreak', defaultVariation]:
				idleAndDamp();

				FlxTween.tween(camGame, {zoom: 1.1}, 4, {ease: FlxEase.quintOut});
				FlxTween.tween(camHUD, {alpha: 0}, 4, {ease: FlxEase.quintOut});

				FlxG.sound.play(Paths.getAudio('game/cutscenes/fuse'));

				FlxTimer.wait(1, () ->
				{
					camGame.flash(FlxColor.ORANGE, 10);
					FlxG.sound.play(Paths.getAudio('game/cutscenes/explosion'));

					visible = false;
				});

				FlxTimer.wait(2, ending);

				return true;

			case ['shift around', defaultVariation]:
				idleAndDamp();

				FlxTimer.wait(1, () ->
				{
					player.flipX = true;

					playerPlayAnim('move');
					player.animation.curAnim.looped = true;

					FlxTween.tween(player, {x: FlxG.width + (player.width * 2)}, 3, {
						ease: FlxEase.sineIn,
					});
				});

				FlxTimer.wait(4, ending);

				return true;

			default:
		}

		return false;
	}
}
