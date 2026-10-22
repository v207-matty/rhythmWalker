package rw.ui.game.song;

typedef SongEventData =
{
	> SongEventRawData,

	var time:Float;

	@:optional
	var entries:Array<SongEventRawData>;
}

typedef SongEventRawData =
{
	var id:String;

	@:optional
	var data:Dynamic;
}
