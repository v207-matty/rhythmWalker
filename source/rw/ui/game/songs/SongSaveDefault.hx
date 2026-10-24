package rw.ui.game.songs;

import flixel.util.FlxTimer;

class SongSaveDefault extends Song
{
	override public function new()
	{
		super('save', defaultVariation);
	}

	override function introCutscene():Bool
	{
		toggleGameplayScene(false);
		FlxTimer.wait(3.692, () ->
		{
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
