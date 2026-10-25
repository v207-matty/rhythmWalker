package rw.ui.game.rh;

import rw.ui.game.song.SongVariation;
import rw.ui.game.rh.stage.RHStage;

class RHPlayState extends PlayState<RHPlayableComponent, RHSong, RHStage>
{
	public static var instance:RHPlayState;

	override public function new(song:String, ?variation:SongVariation = defaultVariation)
	{
		super(song, variation);

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
	}

	override function generateSong()
	{
		this.song = SongManager.getRhythmHeaven(songData?.id, songData?.variation);

		super.generateSong();
	}

	override function makeStage(stage:String)
	{
		super.makeStage(stage);

		this.stage = StageManager.getRhythmHeaven(stage);
		this.stage?.build();
	}
}
