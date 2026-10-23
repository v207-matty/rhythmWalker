package rw.ui.menu;

import flixel.math.FlxMath;
import flixel.util.FlxColor;
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

	var previousSelection = 0;
	var selection = 0;

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
			var text = new FlxText(0, 0, 0, option[0].toUpperCase(), 16);
			text.alignment = CENTER;
			text.ID = i;
			optionTexts.add(text);
		}

		add(logo = new RWSprite('ui/logo'));
		logo.setScale(1);
		logo.screenCenter(X);
		logo.y = logo.height * 0.1;

		changeSelection(0);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (subState == null) controls();
	}

	function controls()
	{
		for (i => swipe in FlxG.swipes)
		{
			if (swipe.duration == 0 || i > 0 || swipe.distance == 0) continue;

			final up = FlxMath.roundDecimal(swipe.degrees / -90, 2);
			final down = FlxMath.roundDecimal(swipe.degrees / 90, 2);

			trace('dist: ${swipe.distance}', 'deg: ${swipe.degrees}', 'down: $down', 'up: $up');

			final range_vertical = [0.5, 1.5];

			if (up >= range_vertical[0] && up <= range_vertical[1]) changeSelection(1);
			else if (down >= range_vertical[0] && down <= range_vertical[1]) changeSelection(-1);
		}

		if (FlxG.keys.anyJustPressed([W, UP])) changeSelection(-1);
		if (FlxG.keys.anyJustPressed([S, DOWN])) changeSelection(1);
	}

	function changeSelection(by:Int)
	{
		previousSelection = selection;
		selection += by;

		if (selection < 0) selection = options.length - 1;
		if (selection > options.length - 1) selection = 0;

		for (option in optionTexts)
		{
			option.y = (logo.y + logo.height + 16) + option.ID * (2 * option.size);
			option.screenCenter(X);

			option.color = (selection == option.ID) ? FlxColor.YELLOW : FlxColor.WHITE;
		}

		if (selection != previousSelection) FlxG.sound.play(Paths.getAudio('sfx/menu/scroll'));
	}
}
