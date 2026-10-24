package rw.ui.game.walker.songs;

class SongEncaptureDefault extends WalkerSong
{
	override public function new()
	{
		super('encapture', defaultVariation);
	}

	override function build()
	{
		super.build();

		game.data.player.cutsceneVelocityDamping = true;
	}
}
