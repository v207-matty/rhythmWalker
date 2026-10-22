package rw.ui.game.song;

class Song extends PlayableComponent
{
	public var song(default, null):String;

	override public function new(song:String)
	{
		super();

		this.song = song;
	}
}
