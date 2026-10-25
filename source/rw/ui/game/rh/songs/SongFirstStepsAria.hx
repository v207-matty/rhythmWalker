package rw.ui.game.rh.songs;

class SongFirstStepsAria extends RHSong
{
	override public function new()
	{
		super('first steps', aria);
	}

	override function build()
	{
		super.build();

		game.camGame.bgColor = 0xFF222034;
	}
}
