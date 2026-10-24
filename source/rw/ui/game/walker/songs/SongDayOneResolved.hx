package rw.ui.game.walker.songs;

class SongDayOneResolved extends WalkerSong
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
