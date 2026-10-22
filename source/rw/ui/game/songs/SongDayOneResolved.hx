package rw.ui.game.songs;

class SongDayOneResolved extends Song
{
	override public function new(song:String)
	{
		super(song, resolved);
	}

	override function build()
	{
		super.build();

		game.beatMonsters.alpha = 0.5;
	}
}
