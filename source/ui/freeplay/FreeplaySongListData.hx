package ui.freeplay;

import ui.freeplay.FreeplaySongData;

typedef FreeplaySongListData =
{
	@:optional
	var filters:Array<String>;

	var songs:Array<FreeplaySongData>;
}
