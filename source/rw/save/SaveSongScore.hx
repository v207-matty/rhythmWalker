package rw.save;

import rw.ui.game.PlayData.PlayModeData;
import rw.ui.game.song.SongRank;

typedef SaveSongScore =
{
	var rank:SongRank;
	var score:Int;
	var percent:Float;

	var mode:PlayModeData;
	var version:SaveSongScoreVersion;
}

enum abstract SaveSongScoreVersion(Null<Int>) from Null<Int> to Null<Int>
{
	var _UNKNOWN = null;

	var BEFORE_BUNDLE_ONE = -1;

	var BUNDLE_ONE = 0;
}
