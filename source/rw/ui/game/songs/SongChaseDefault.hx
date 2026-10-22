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

	function toggleGameplayScene(on:Bool) game.inIntroCutscene = game.camGame.visible = game.camHUD.visible = on;

	var togglePoints:Array<Dynamic>;

	function togglePointOne() toggleGameplayScene(false);
	function togglePointOneEnd() toggleGameplayScene(true);

	function togglePointTwo() toggleGameplayScene(false);
	function togglePointTwoEnd() toggleGameplayScene(true);

	function togglePointThree() toggleGameplayScene(false);

	override function build()
	{
		super.build();

		// TODO: have the fuckass shit just change bgs

		togglePoints = [
			{time: 8.0, method: togglePointOne},
			{time: 12.0, method: togglePointOneEnd},
			{time: 16.0, method: togglePointTwo},
			{time: 20.0, method: togglePointTwoEnd},
			{time: 24.0, method: togglePointThree},
		];
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		for (point in togglePoints)
		{
			if (game.conductor.musicPosition < point.time) continue;

			if (point.method != null) point.method();
			togglePoints.remove(point);
		}
	}
}
