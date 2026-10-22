package rw.ui.game.songs;

import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;

class SongLostMediaDefault extends Song
{
	override public function new()
	{
		super('lost media', defaultVariation);
	}

	override function introCutscene():Bool
	{
		game.camHUD.alpha = 0;

		game.camGameFollow.y -= FlxG.height * 2;
		game.camGame.focusOn(game.camGameFollow.getPosition());

		FlxTween.tween(game.camGameFollow, {y: FlxG.height / 2}, 1.5, {
			ease: FlxEase.backInOut,
		});

		FlxTween.tween(game.camHUD, {alpha: 1}, 1.5, {
			ease: FlxEase.backInOut
		});

		FlxTimer.wait(1.75, gameEndIntroCutscene);

		return true;
	}
}
