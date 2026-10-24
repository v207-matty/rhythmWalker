package rw.ui;

import rw.save.Save;
import flixel.FlxG;

class MenuState extends ConductorState
{
	public function playMenuMusic() if (!FlxG.sound.music?.playing && Save.options.menuMusic) FlxG.sound.playMusic(Paths.getAudio('ui/menu'));

	override function create()
	{
		super.create();

		playMenuMusic();
	}
}
