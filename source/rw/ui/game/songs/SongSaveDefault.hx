package rw.ui.game.songs;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import rw.ui.objects.RWSprite;
import flixel.text.FlxText;
import flixel.util.FlxTimer;

class SongSaveDefault extends Song
{
	override public function new()
	{
		super('save', defaultVariation);
	}

	var getReadyIMG:RWSprite;
	var getReadyTEXT:FlxText;

	override function introCutscene():Bool
	{
		toggleGameplayScene(false);

		game.add(getReadyIMG = new RWSprite('game/cutscenes/scene/save/getready'));
		getReadyIMG.setScale(1);
		getReadyIMG.screenCenter();

		game.add(getReadyTEXT = new FlxText(0, 0, 0, 'GET READY TO MOVE', 32));
		getReadyTEXT.screenCenter(X);
		getReadyTEXT.y = getReadyTEXT.size;

		getReadyIMG.camera = getReadyTEXT.camera = game.transitionCam;
		getReadyIMG.alpha = getReadyTEXT.alpha = 0;

		FlxTween.tween(getReadyIMG, {alpha: 1}, 3.6, {
			ease: FlxEase.sineIn
		});

		FlxTween.tween(getReadyTEXT, {alpha: 1}, 3.6, {
			ease: FlxEase.sineIn
		});

		FlxTimer.wait(3.692, () ->
		{
			game.remove(getReadyIMG);
			game.remove(getReadyTEXT);

			getReadyIMG.destroy();
			getReadyTEXT.destroy();

			getReadyIMG = null;
			getReadyTEXT = null;

			toggleGameplayScene(true);
			gameEndIntroCutscene();
		});

		return true;
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

	override function onEvent(event:SongEventRawData)
	{
		super.onEvent(event);
		switch (event.id.toLowerCase())
		{
			case 'save-moving':
				switch (event.data)
				{
					case 1, 3, 5:
						toggleGameplayScene(false);
					case 2, 4, 6:
						toggleGameplayScene(true);

					default:
				}
		}
	}
}
