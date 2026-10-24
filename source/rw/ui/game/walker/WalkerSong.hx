package rw.ui.game.walker;

import rw.ui.game.song.SongVariation;
import rw.ui.game.walker.WalkerPlayableComponent;
import flixel.FlxG;
import flixel.util.FlxTimer;

class WalkerSong extends WalkerPlayableComponent
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
		game.onSongEnd(false);
	}

	public function introCutscene() return false;

	public function endingCutscene() return false;
}
