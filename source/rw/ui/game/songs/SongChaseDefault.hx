package rw.ui.game.songs;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import rw.ui.objects.RWSprite;

class SongChaseDefault extends Song
{
	override public function new()
	{
		super('chase', defaultVariation);
	}

	var cutscene:RWSprite;

	override function introCutscene():Bool
	{
		game.camGame.alpha = game.camHUD.alpha = 0;

		cutscene = new RWSprite('game/cutscenes/scene/chase/bro-wakeup');
		cutscene.setScale(1);
		cutscene.screenCenter();
		game.add(cutscene);

		FlxTimer.wait(2, () ->
		{
			cutscene.loadGraphic(Paths.getImagePath('game/cutscenes/scene/chase/bro-runnin'));
			cutscene.setScale(1);
			cutscene.screenCenter();

			FlxTween.tween(cutscene, {alpha: 0}, 1, {startDelay: 1, ease: FlxEase.quadOut});
			FlxTween.tween(game.camGame, {alpha: 1}, 1, {startDelay: 1, ease: FlxEase.quadOut});
			FlxTween.tween(game.camHUD, {alpha: 1}, 1, {startDelay: 1, ease: FlxEase.quadOut});
		});

		FlxTimer.wait(4, () ->
		{
			gameEndIntroCutscene();

			game.remove(cutscene);
			cutscene.destroy();
			cutscene = null;
		});

		return true;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (game.camGame.alpha <= 0) return;

		game.move(-.1, false);

		if (game.control_right && !game.player_onRightEdge) game.data.beatMonsters.padding = game.player.width * -0.5;
		else if (game.control_left && !game.player_onLeftEdge) game.data.beatMonsters.padding = game.player.width * 0.5;
		else game.data.beatMonsters.padding = 0;
	}
}
