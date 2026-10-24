package rw.ui.game.rh;

import rw.ui.game.song.SongVariation;

class RHSong extends RHPlayableComponent
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
