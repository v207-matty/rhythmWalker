package rw.ui.menu.freeplay;

import rw.ui.menu.freeplay.FreeplaySongData;

typedef FreeplaySongListData =
{
	@:optional
	var filters:Array<String>;

	var songs:Array<FreeplaySongData>;
}
