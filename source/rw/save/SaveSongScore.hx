package rw.save;

import rw.ui.game.PlayData.PlayModeData;
import rw.ui.game.song.SongRank;

typedef SaveSongScore =
{
	var rank:SongRank;
	var score:Int;
	var percent:Float;

	var mode:PlayModeData;
	var version:Null<Int>;
}
