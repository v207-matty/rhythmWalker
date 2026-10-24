package rw.ui.game.songs;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;

class SongScrollDownChinatownDefault extends Song
{
	override public function new()
	{
		super('scroll down chinatown', defaultVariation);
	}

	override function introCutscene():Bool
	{
		game.camHUD.alpha = 0;

		game.playerPlayAnim('chinatown-bridge', false);
		game.player.y -= game.player.height * 0.5;

		function partTwo()
		{
			game.spawnBeatMonster();
			game.beatMonsterSpawner.alpha += .5;

			FlxTween.tween(game.camHUD, {alpha: 1}, .4, {
				ease: FlxEase.sineOut
			});

			FlxTween.tween(game.player, {x: game.player.x - 128, y: game.player.y + game.player.height * 0.5}, .4, {
				ease: FlxEase.sineOut,
				startDelay: .2,
				onStart: t -> game.playerPlayAnim('chinatown-bridge-jump', false),
				onComplete: t ->
				{
					game.playerPlayAnim('idle');
					gameEndIntroCutscene();
				}
			});
		}

		function partOne()
		{
			game.inEndCutscene = true;

			game.playerPlayAnim('chinatown-bridge-lookup', false);
			game.player.animation.onFinish.add(animName -> if (animName == 'chinatown-bridge-lookup') partTwo());
		}

		FlxTimer.wait(7.5, partOne);

		return true;
	}
}
