package rw.ui.freeplay;

import rw.ui.freeplay.FreeplaySongData;

typedef FreeplaySongListData =
{
	@:optional
	var filters:Array<String>;

	var songs:Array<FreeplaySongData>;
}
