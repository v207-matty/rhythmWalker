package rw.ui.game.songs;

import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import rw.ui.game.stage.StageSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;

class SongTrainWreakDefault extends Song
{
	override public function new()
	{
		super('train wreak', defaultVariation);
	}

	override function introCutscene():Bool
	{
		game.camHUD.alpha = 0;

		game.camGameFollow.y -= FlxG.height * 2;
		game.camGame.zoom = 0.5;
		game.camGame.focusOn(game.camGameFollow.getPosition());

		FlxTween.tween(game.camGameFollow, {y: FlxG.height / 2}, 6, {
			ease: FlxEase.backInOut,
		});

		FlxTween.tween(game.camHUD, {alpha: 1}, 6, {
			ease: FlxEase.backInOut
		});

		function onZoomed(t)
		{
			game.stageBackLayer.forEach(sprite ->
			{
				if (!Std.isOfType(sprite, StageSprite) || sprite == null || sprite.isOnScreen(sprite.camera)) return;

				game.stageBackLayer.remove(sprite);
				sprite.destroy();
			});
		}

		FlxTween.tween(game.camGame, {zoom: 1}, 6, {
			startDelay: 5,
			ease: FlxEase.backInOut,
			onComplete: onZoomed,
		});

		FlxTimer.wait(12, gameEndIntroCutscene);

		return true;
	}

	override function endingCutscene():Bool
	{
		gameIdleAndDamp();

		FlxTween.tween(game.camGame, {zoom: 1.1}, 4, {ease: FlxEase.quintOut});
		FlxTween.tween(game.camHUD, {alpha: 0}, 4, {ease: FlxEase.quintOut});

		FlxG.sound.play(Paths.getAudio('game/cutscenes/fuse'));

		FlxTimer.wait(1, () ->
		{
			game.camGame.flash(FlxColor.ORANGE, 10);
			FlxG.sound.play(Paths.getAudio('game/cutscenes/explosion'));

			game.visible = false;
		});

		FlxTimer.wait(2, gameEndEndingCutscene);

		return true;
	}
}
