package rw.ui.game.walker.songs;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import rw.ui.objects.RWSprite;

class SongChaseDefault extends WalkerSong
{
	override public function new()
	{
		super('chase', defaultVariation);
	}

	function toggleGameplayScene(on:Bool)
	{
		game.camGame.visible = game.camHUD.visible = on;
		game.inIntroCutscene = !on;

		game.playerPlayAnim('idle');

		if (on)
		{
			game.move(0);

			game.player.flipX = true;
			game.playerPlayAnim('move');

			game.player.x = game.player.width;
			game.player.velocity.x = game.player.maxVelocity.x;
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
		cutscene.camera = game.transitionCam;

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

	override function onEvent(event:SongEventRawData)
	{
		super.onEvent(event);

		switch (event.id.toLowerCase())
		{
			case 'chase-moving':
				switch (event.data)
				{
					case 1, 3:
						toggleGameplayScene(false);
					case 2, 4:
						toggleGameplayScene(true);
					case 5:
						toggleGameplayScene(false);

						game.inIntroCutscene = false;

					default:
				}
		}
	}
}
