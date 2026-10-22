package rw.ui.game.song;

class Song extends PlayableComponent
{
	public var song(default, null):String;
	public var variation(default, null):SongVariation;

	override public function new(song:String, variation:SongVariation)
	{
		super();

		this.song = song.toLowerCase();
		this.variation = variation;
	}
}
