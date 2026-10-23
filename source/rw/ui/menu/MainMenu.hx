package rw.ui.menu;

import flixel.math.FlxPoint;
import flixel.FlxCamera;
import rw.ui.menu.freeplay.Freeplay;
import flixel.FlxSprite;
import rw.util.Constants;
import rw.util.TouchUtil;
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

	var options:Array<Dynamic> = [];
	var optionTexts:FlxTypedSpriteContainer<FlxText>;

	var previousSelection = 0;
	var selection = 0;

	var cover:FlxSprite;

	var cam:FlxCamera;

	override public function new(enterFreeplay = false)
	{
		super();

		this.enterFreeplay = enterFreeplay;

		options = [
			['freeplay', openFreeplay],
			['options', openOptions],
			#if sys
			['exit', () -> Sys.exit(0)],
			#end
		];
	}

	function openFreeplay() openSubState(new Freeplay());

	function openOptions() {}

	override function create()
	{
		super.create();

		FlxG.sound.playMusic(Paths.getAudio('ui/menu'));

		FlxG.cameras.reset(cam = new FlxCamera());

		add(optionTexts = new FlxTypedSpriteContainer<FlxText>());

		for (i => option in options)
		{
			var text = new FlxText(0, 0, 0, option[0].toUpperCase(), Constants.TEXT_SIZE);
			text.alignment = CENTER;
			text.ID = i;
			optionTexts.add(text);
		}

		add(logo = new RWSprite('ui/logo'));
		logo.setScale(1);
		logo.screenCenter(X);
		logo.y = logo.height * 0.1;

		#if MOBILE_MODE
		var playButton = new rw.ui.objects.mobile.CornerButton('playBtn');

		playButton.y = FlxG.height - playButton.height;

		playButton.setScrollFactor(0);

		playButton.back.angle = -180;
		playButton.offsetBy(48 * playButton.scale.x, -48 * playButton.scale.y);

		playButton.onClicked.add(() -> if (subState == null) proceed());

		add(playButton);
		#end

		changeSelection(0);

		if (enterFreeplay) proceed();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (subState == null) controls();
	}

	function controls()
	{
		if (FlxG.keys.anyJustPressed([W, UP]) || TouchUtil.swippedUp()) changeSelection(-1);
		if (FlxG.keys.anyJustPressed([S, DOWN]) || TouchUtil.swippedDown()) changeSelection(1);

		if (FlxG.keys.anyJustPressed([ENTER])) proceed();
	}

	function proceed()
	{
		if (options[selection] == null) return;

		var method = options[selection][1];
		if (method != null) method();
	}

	function changeSelection(by:Int)
	{
		previousSelection = selection;
		selection += by;

		if (selection < 0) selection = options.length - 1;
		if (selection > options.length - 1) selection = 0;

		for (option in optionTexts)
		{
			option.y = (logo.y + logo.height + Constants.TEXT_SIZE) + option.ID * (4 * option.size);
			option.screenCenter(X);
			option.color = (selection == option.ID) ? FlxColor.YELLOW : FlxColor.WHITE;
		}

		if (selection != previousSelection) FlxG.sound.play(Paths.getAudio('sfx/menu/scroll'));
	}
}
