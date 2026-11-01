package rw.ui.game.rh;

class RHPlayState extends PlayState<RHPlayableComponent, RHSong>
{
	public static var instance:RHPlayState;

	override public function new(data:PlayData)
	{
		super(data);

		mode = RHYTHM_HEAVEN;
	}

	override function destroy()
	{
		super.destroy();

		instance = null;
	}

	override function create()
	{
		instance = null;
		instance = this;

		super.create();
	}

	override function generateState()
	{
		super.generateState();

		mouseEnabled = true;
		mouseVisible = #if !mobile true #else false #end;
	}

	override function generateSong()
	{
		this.song = SongManager.getRhythmHeaven(songData?.id, songData?.variation);
		this.song?.build();

		super.generateSong();
	}
}
