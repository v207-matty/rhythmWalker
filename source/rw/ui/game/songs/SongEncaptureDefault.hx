package rw.ui.game.songs;

class SongEncaptureDefault extends Song
{
	override public function new()
	{
		super('encapture', defaultVariation);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (game.inCutscene) game.playerVelocityDamping();
	}
}
