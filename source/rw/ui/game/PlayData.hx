package rw.ui.game;

import rw.ui.game.song.SongVariation;

typedef PlayData =
{
	var song:String;

	@:optional
	@:default(defaultVariation)
	var variation:SongVariation;
}

enum abstract PlayModeData(String) from String to String
{
	var WALKER = 'WALKER';
	var RHYTHM_HEAVEN = 'RHYTHM_HEAVEN';
}
