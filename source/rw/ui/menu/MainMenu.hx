package rw.ui.menu;

import rw.save.Save;
import lime.app.Application;
import rw.util.macro.GitMacro;
import rw.ui.menu.options.OptionsMenu;
import flixel.math.FlxPoint;
import flixel.FlxCamera;
import rw.ui.menu.freeplay.Freeplay;
import flixel.FlxSprite;
import rw.util.Constants;
import rw.util.mobile.TouchUtil;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.group.FlxSpriteContainer.FlxTypedSpriteContainer;
import flixel.FlxG;
import rw.ui.objects.RWSprite;

class MainMenu extends MenuState
{
	var logo:RWSprite;
	var enterFreeplay = false;

	var options:Array<Dynamic> = [];
	var optionTexts:FlxTypedSpriteContainer<FlxText>;

	var previousSelection = 0;
	var selection = 0;

	var cover:FlxSprite;

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

	function openFreeplay() FlxG.switchState(() -> new Freeplay());

	function openOptions() FlxG.switchState(() -> new OptionsMenu());

	override function create()
	{
		FlxG.cameras.reset();

		if (enterFreeplay)
		{
			bgColor = Constants.TRANSITION_COLOR;
			transIn = transOut = null;
			proceed();
			return;
		}

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

		var versionText = new FlxText(0, 0, FlxG.width, 'v${Application.current.meta.get('version')}', Math.floor(Constants.TEXT_SIZE / 2));
		versionText.text += ' (${GitMacro.getGitBranch()}/${GitMacro.getGitHash()})';
		add(versionText);
		versionText.setPosition(versionText.size, FlxG.height - versionText.height - versionText.size);
		versionText.alpha = .25;

		#if MOBILE_MODE
		versionText.y = versionText.size;

		var proceedBtn = new rw.ui.objects.mobile.CornerButton('proceedBtn');

		proceedBtn.y = FlxG.height - proceedBtn.height;

		proceedBtn.setScrollFactor(0);

		proceedBtn.back.angle = -180;
		proceedBtn.offsetBy(48 * proceedBtn.scale.x, -48 * proceedBtn.scale.y);

		proceedBtn.onClicked.add(() -> if (subState == null) proceed());

		add(proceedBtn);
		#end

		changeSelection(0);

		super.create();
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
