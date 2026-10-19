package ui.freeplay;

import ui.game.song.SongVariation;

typedef FreeplaySongData =
{
	var song:String;

	@:optional
	var filters:Array<String>;

	@:optional
	var variation:SongVariation;
}
