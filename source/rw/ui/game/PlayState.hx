package rw.ui.game;

import flixel.util.typeLimit.NextState;
import rw.ui.game.walker.WalkerPlayState;
import rw.ui.game.PlayData.PlayModeData;

class PlayState
{
	public static function create(mode:PlayModeData, data:PlayData):NextState
	{
		switch (mode)
		{
			case WALKER: return () -> new WalkerPlayState(data.song, data.variation);

			case RHYTHM_HEAVEN: return null;
		}

		return null;
	}
}
