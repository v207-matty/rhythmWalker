package rw.ui.menu;

import flixel.FlxG;
import rw.ui.objects.RWSprite;

class MainMenu extends ConductorState
{
    var logo:RWSprite;

	override function create()
	{
		super.create();

        FlxG.sound.playMusic(Paths.getAudio('ui/menu'));

        add(logo = new RWSprite('ui/logo'));
        logo.setScale(1);
        logo.screenCenter();
	}
}
