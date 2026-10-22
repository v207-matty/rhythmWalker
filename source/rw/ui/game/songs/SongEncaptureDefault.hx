package rw.ui.game.songs;

class SongEncaptureDefault extends Song
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
