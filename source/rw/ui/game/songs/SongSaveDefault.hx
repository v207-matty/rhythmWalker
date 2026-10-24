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
		game.camGame.visible = game.camHUD.visible = false;

		FlxTimer.wait(3.692, () ->
		{
			game.camGame.visible = game.camHUD.visible = true;
			gameEndIntroCutscene();
		});

		return true;
	}
}
