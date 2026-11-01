package rw.ui.game;

import rw.ui.game.rh.RHPlayState;
import flixel.FlxState;
import flixel.util.typeLimit.NextState;
import rw.ui.game.walker.WalkerPlayState;
import rw.ui.game.PlayData.PlayModeData;

class GameManager
{
	public static function load(mode:PlayModeData, data:PlayData):NextState
	{
		switch (mode)
		{
			case WALKER: return () -> new WalkerPlayState(data);

			case RHYTHM_HEAVEN: return () -> new RHPlayState(data);
		}

		trace('Invalid : $mode');
		return () -> new FlxState();
	}
}
