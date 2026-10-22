package rw.ui.game.song;

import flixel.FlxG;
import flixel.util.FlxTimer;

class Song extends PlayableComponent
{
	public var song(default, null):String;
	public var variation(default, null):SongVariation;

	override public function new(song:String, variation:SongVariation)
	{
		super();

		this.song = song.toLowerCase();
		this.variation = variation;
	}

	public function gameIdleAndDamp()
	{
		game.playerPlayAnim('idle');
		new FlxTimer().start(1 / FlxG.updateFramerate, t -> game.playerVelocityDamping(), FlxG.updateFramerate);
	}

	function gameEndIntroCutscene() game.inIntroCutscene = game.inEndCutscene = false;

	function gameEndEndingCutscene()
	{
		game.inEndCutscene = false;
		game.onSongEnd();
	}

	public function introCutscene() return false;

	public function endingCutscene() return false;
}
