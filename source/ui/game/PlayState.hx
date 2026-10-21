package ui.game;

import flixel.util.FlxSort;
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
			stepRate: 4
		}
	};

	var playerData:PlayerData;
	var stageData:Stage;

	var stageBackLayer:FlxSpriteGroup;
	var stageFrontLayer:FlxSpriteGroup;

	var stageBackLayerMap:Map<String, FlxSprite> = [];
	var stageFrontLayerMap:Map<String, FlxSprite> = [];

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
		else if (inCutscene && song.id == 'encapture')
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
		if (inCutscene)
			return;

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
				if (sprite == null || !sprite.animation.exists('idle') || sprite.animation.name != 'idle' && !sprite.animation.finished)
					return;
				sprite.animation.play('idle');
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
		var beatMonster:RWSprite = new RWSprite(null);
		beatMonster.makeGraphic(32, 32, FlxColor.RED);
		beatMonster.setScale(stageData.config?.beatmonsters?.scale ?? 1);

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
				if (trainWreak_shooter != null)
					trainWreak_shooter.animation.play('shoot', true);

			case 'traingetaway-reload':
				if (trainGetaway_shooter != null)
					trainGetaway_shooter.animation.play('reload', true);

			case 'traingetaway-gunjammed':
				if (trainGetaway_shooter != null)
					trainGetaway_shooter.animation.play('jammed', true);

			case 'traingetaway-gun':
				if (trainGetaway_shooter != null)
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

	var containment04_tubeSubject:FlxSprite;

	var trainGetaway_i:Float = 1;
	var trainGetaway_sky:FlxBackdrop;
	var trainGetaway_shooter:FlxSprite;

	var trainWreak_shooter:FlxSprite;

	function generateStage()
	{
		if (song?.id == 'train getaway' && song?.variation == defaultVariation)
		{
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
		}

		makeStage(song?.stage ?? 'stage');
	}

	function makeStage(?stage:String)
	{
		if (stageBackLayer == null || stageFrontLayer == null)
			return;

		for (layer in [stageBackLayer, stageFrontLayer,])
		{
			for (sprite in layer.members)
			{
				layer.members.remove(sprite);
				sprite.destroy();
			}

			layer.clear();
		}

		stageData = new Stage(stage);

		camGame.bgColor = FlxColor.fromString(stageData.config?.bgColor ?? '0xFFFFFFFF');

		function applyPlayerData()
		{
			if (stageData.config?.player?.scale != null)
			{
				var x = stageData.config?.player?.scale?.x;
				var y = stageData.config?.player?.scale?.y;

				player.setScale(stageData.applyFloatOrString(x) ?? 2, stageData.applyFloatOrString(y) ?? 2);
			}

			player.screenCenter();
			player.y = FlxG.height - player.height * 1.25;

			stageData.addExpressionVariable('player_width', player.width);
			stageData.addExpressionVariable('player_height', player.height);

			if (stageData.config?.player?.position != null)
			{
				var x = stageData.config?.player?.position?.x;
				var y = stageData.config?.player?.position?.y;

				player.setPosition(stageData.applyFloatOrString(x) ?? player.x, stageData.applyFloatOrString(y) ?? player.y);
			}

			stageData.addExpressionVariable('player_x', player.x);
			stageData.addExpressionVariable('player_y', player.y);
		}

		for (prop in stageBackLayerMap = stageData.createStageProps(back))
		{
			prop.camera = camGame;
			stageBackLayer.add(prop);
		}

		for (prop in stageFrontLayerMap = stageData.createStageProps(front))
		{
			prop.camera = camGame;
			stageFrontLayer.add(prop);
		}

		for (layer in [stageBackLayer, stageFrontLayer,])
			layer.sort((s, a, b) -> FlxSort.byValues(s, a.ID, b.ID), FlxSort.ASCENDING);

		applyPlayerData();

		switch ([song.id, song.variation])
		{
			case ['train getaway', defaultVariation]:
				trainGetaway_sky = cast(stageBackLayerMap.get('sky'), FlxBackdrop);
				trainGetaway_shooter = stageBackLayerMap.get('shooter');

				if (trainGetaway_shooter == null)
					return;

				trainGetaway_shooter.animation.play('idle');

				FlxTween.tween(trainGetaway_shooter, {x: FlxG.width - trainGetaway_shooter.width}, 2.75, {
					ease: FlxEase.sineInOut
				});

			default:
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
						if (sprite == null || sprite.isOnScreen(sprite.camera))
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
