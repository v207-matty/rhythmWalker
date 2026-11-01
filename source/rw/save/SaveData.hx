package rw.save;

typedef SaveData =
{
	var version:Null<Int>;

	@:optional
	var scores:Map<String, SaveSongScore>;

	@:optional
	var options:SaveOptionsData;

	@:optional
	var gamejoly:SaveGameJoltData;
}
