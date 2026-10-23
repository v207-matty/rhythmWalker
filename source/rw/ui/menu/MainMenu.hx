package rw.ui.menu;

import flixel.text.FlxText;
import flixel.group.FlxSpriteContainer.FlxTypedSpriteContainer;
import flixel.FlxG;
import rw.ui.objects.RWSprite;

class MainMenu extends ConductorState
{
	var logo:RWSprite;
	var enterFreeplay = false;

	var options:Array<Dynamic> = [
		['freeplay', () -> {}],
		['options', () -> {}],
		#if sys
		['exit', () -> Sys.exit(0)],
		#end
	];
	var optionTexts:FlxTypedSpriteContainer<FlxText>;

	override public function new(enterFreeplay = false)
	{
		super();

		this.enterFreeplay = enterFreeplay;
	}

	override function create()
	{
		super.create();

		FlxG.sound.playMusic(Paths.getAudio('ui/menu'));

		add(optionTexts = new FlxTypedSpriteContainer<FlxText>());

		for (i => option in options)
		{
			var text = new FlxText(0, 0, 0, option[0], 16);
            text.ID = i;
			optionTexts.add(text);
		}

		add(logo = new RWSprite('ui/logo'));
		logo.setScale(1);
		logo.screenCenter(X);
		logo.y = logo.height * 0.1;
	}
}
