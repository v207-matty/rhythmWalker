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

	var togglePoints:Array<Dynamic>;

	function togglePointOne() toggleGameplayScene(false);

	function togglePointOneEnd() toggleGameplayScene(true);

	function togglePointTwo() toggleGameplayScene(false);

	function togglePointTwoEnd() toggleGameplayScene(true);

	function togglePointThree()
	{
		toggleGameplayScene(false);

		game.inIntroCutscene = false;
	}

	function toggleGameplayScene(on:Bool)
	{
		game.camGame.visible = game.camHUD.visible = on;
		game.inIntroCutscene = !on;

		if (on)
		{
			game.playerPlayAnim('idle');
			game.player.velocity.x = 0;
			game.player.screenCenter(X);
		}
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

	override function build()
	{
		super.build();

		game.data.player.cutsceneVelocityDamping = true;
	}

	override function onEvent(event:SongEventData)
	{
		super.onEvent(event);

		switch (event.id.toLowerCase())
		{
			case 'chase-moving':
				switch (event.data)
				{
					case 1:
						togglePointOne();
					case 2:
						togglePointOneEnd();
					case 3:
						togglePointTwo();
					case 4:
						togglePointTwoEnd();
					case 5:
						togglePointThree();

					default:
				}
		}
	}
}
