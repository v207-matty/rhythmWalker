package rw.ui.game.walker;

import flixel.math.FlxPoint;
import flixel.util.FlxGradient;
import rw.util.Constants;
import rw.ui.game.walker.stage.WalkerStageSprite;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.FlxSprite;
import flixel.text.FlxText;
import rw.ui.game.walker.player.Player;
import flixel.group.FlxSpriteGroup;
import flixel.FlxG;
import rw.ui.game.song.SongEventData.SongEventRawData;
import rw.ui.game.walker.stage.WalkerStage;

using StringTools;

class WalkerPlayState extends PlayState<WalkerPlayableComponent, WalkerSong, WalkerStage>
{
	public static var instance:WalkerPlayState;

	public var player(default, null):Player;
	public var beatMonsters(default, null):FlxSpriteGroup;
	public var beatMonsterSpawner(default, null):FlxSprite;
	public var scoreText(default, null):FlxText;
	public var hits:Int = 0;

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

	override function destroy()
	{
		super.destroy();

		instance = null;
	}

	override function create()
	{
		instance = null;
		instance = this;

		super.create();
	}

	override function generateState()
	{
		createPlayer();

		gameplayElements.add(player);
		gameplayElements.add(beatMonsters = new FlxSpriteGroup());
		gameplayElements.add(beatMonsterSpawner = FlxGradient.createGradientFlxSprite(Math.floor(FlxG.width * 1.1), Math.floor(FlxG.height * 0.2),
			[FlxColor.RED, FlxColor.TRANSPARENT]));

		add(scoreText = new FlxText(0, 0, FlxG.width, 'BOB', Constants.TEXT_SIZE));

		scoreText.setBorderStyle(OUTLINE, FlxColor.BLACK, Constants.TEXT_OUTLINE_SIZE);
		scoreText.camera = camHUD;
		scoreText.alignment = CENTER;

		generateSong();

		beatMonsterSpawner.shader = beatMonsters.shader;
	}

	override function generateSong()
	{
		this.song = SongManager.getWalker(songData?.id, songData?.variation);

		super.generateSong();
	}

	override function makeStage(stage:String)
	{
		super.makeStage(stage);

		this.stage = StageManager.getWalker(stage);
		this.stage?.build();
	}

	override function onStepHit(step:Int, backward:Bool)
	{
		if (!inCutscene && ((canSpawnMonster || !inEndCutscene && beatMonsters.members.length > 0) && data.beatMonsters.stepRate > 0))
		{
			var scoreInc:Int = 25;

			totalScore += scoreInc;
			if (!player.stunned) score += scoreInc;
		}

		if (canSpawnMonster && Math.floor(step % data.beatMonsters.stepRate) == 0) spawnBeatMonster();

		super.onStepHit(step, backward);
	}

	override function onBeatHit(beat:Int, backward:Bool)
	{
		runOnLayers(l -> for (sprite in l.members)
		{
			if (!Std.isOfType(sprite, WalkerStageSprite)) return;

			var stageSprite = cast(sprite, WalkerStageSprite);
			if (stageSprite == null) return;

			stageSprite.dance();
		});

		super.onBeatHit(beat, backward);
	}

	override function parseEvent(event:SongEventRawData)
	{
		switch (event.id.toLowerCase())
		{
			case 'player-idle': playerPlayAnim('idle');

			case 'player-switch', 'player-change': if (event.data != null) makePlayer(Std.string(event.data));

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

		super.parseEvent(event);
	}

	override function updateState(elapsed:Float)
	{
		super.updateState(elapsed);

		if (!inCutscene) managePlayer();
		else if (data.player.cutsceneVelocityDamping) playerVelocityDamping();

		if (beatMonsters != null) manageBeatMonsters();

		if (scoreText != null)
		{
			scoreText.text = 'Score: $score | Hits Taken: $hits';
			scoreText.screenCenter(X);
		}
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

	function get_control_left():Bool
	{
		return FlxG.keys.anyPressed([A, LEFT]) || (FlxG.mouse.pressed && FlxG.mouse.x < player.x);
	}

	public var control_right(get, never):Bool;

	function get_control_right():Bool
	{
		return FlxG.keys.anyPressed([D, RIGHT]) || (FlxG.mouse.pressed && FlxG.mouse.x > player.x);
	}

	public var player_onLeftEdge(default, null):Bool = false;
	public var player_onRightEdge(default, null):Bool = false;

	function managePlayer()
	{
		@:privateAccess
		if (player.maxVelocity == null) player.initMotionVars();

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

	public var canSpawnMonster(get, never):Bool;

	function get_canSpawnMonster():Bool return !inEndCutscene && data.beatMonsters.spawn;

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

	public function createPlayer()
	{
		makePlayer(songData?.player ?? 'bro-regular');

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

	public function makePlayer(newplayer:String)
	{
		if (player == null) player = new Player(newplayer);
		else player.load(newplayer);
	}
}
