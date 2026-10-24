package rw.ui.game.walker.songs;

import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

class SongShiftAroundDefault extends WalkerSong
{
	override public function new()
	{
		super('shift around', defaultVariation);
	}

	override function endingCutscene():Bool
	{
		gameIdleAndDamp();

		FlxTimer.wait(1, () ->
		{
			game.player.flipX = true;

			game.playerPlayAnim('move');
			game.player.animation.curAnim.looped = true;

			FlxTween.tween(game.player, {x: FlxG.width + (game.player.width * 2)}, 3, {
				ease: FlxEase.sineIn,
			});
		});

		FlxTimer.wait(4, gameEndEndingCutscene);
		FlxTween.tween(game.camHUD, {alpha: 0}, 4, {ease: FlxEase.quintOut});

		return true;
	}
}
