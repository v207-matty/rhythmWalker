package rw.ui.menu.options;

import rw.save.Save;
import flixel.FlxObject;
import flixel.FlxCamera;
import flixel.util.FlxColor;
import rw.util.mobile.TouchUtil;
import rw.util.Constants;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.group.FlxSpriteContainer.FlxTypedSpriteContainer;

class OptionsMenu extends ConductorState
{
	var cam:FlxCamera;
	var camFollow:FlxObject;

	var options:Array<Option> = [];
	var optionTexts:FlxTypedSpriteContainer<FlxText>;

	var previousSelection = 0;
	var selection = 0;

	override public function new()
	{
		super();

		options = [
			new Option(() -> return 'Quality Warning : ${Save.options.qualityWarning}', () -> Save.options.qualityWarning = !Save.options.qualityWarning),
			new Option(() -> return 'Shaders : ${Save.options.shaders}', () -> Save.options.shaders = !Save.options.shaders),
		];
	}

	override function create()
	{
		FlxG.cameras.reset(cam = new FlxCamera());

		add(camFollow = new FlxObject((FlxG.width / 2)));
		cam.follow(camFollow, LOCKON, .1);

		add(optionTexts = new FlxTypedSpriteContainer<FlxText>());

		for (i => option in options)
		{
			var text = new FlxText(0, 0, 0, option.text(), Constants.TEXT_SIZE);
			text.alignment = CENTER;
			text.ID = i;
			optionTexts.add(text);
		}

		#if MOBILE_MODE
		var backBtn = new rw.ui.objects.mobile.CornerButton('backBtn');

		backBtn.y = FlxG.height - backBtn.height;

		backBtn.setScrollFactor(0);

		backBtn.back.angle = -180;
		backBtn.offsetBy(48 * backBtn.scale.x, -48 * backBtn.scale.y);

		backBtn.onClicked.add(leave);

		add(backBtn);

		var proceedBtn = new rw.ui.objects.mobile.CornerButton('proceedBtn');

		proceedBtn.y = FlxG.height - proceedBtn.height;
		proceedBtn.x = FlxG.width - proceedBtn.width;

		proceedBtn.setScrollFactor(0);

		proceedBtn.back.angle = 90;
		proceedBtn.offsetBy(-16 * proceedBtn.scale.x, -64 * proceedBtn.scale.y);

		proceedBtn.onClicked.add(proceed);

		add(proceedBtn);
		#end

		changeSelection(0);

		if (!FlxG.sound.music?.playing) FlxG.sound.playMusic(Paths.getAudio('ui/menu'));

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
		if (FlxG.keys.anyJustPressed([ESCAPE])) leave();
	}

	function proceed()
	{
		if (options[selection] == null) return;

		var method = options[selection].onClick;
		if (method != null) method();

		changeSelection(0);
	}

	function leave() FlxG.switchState(() -> new MainMenu());

	function changeSelection(by:Int)
	{
		previousSelection = selection;
		selection += by;

		if (selection < 0) selection = options.length - 1;
		if (selection > options.length - 1) selection = 0;

		for (option in optionTexts)
		{
			option.text = options[option.ID].text();
			option.y = option.ID * (4 * option.size);
			option.screenCenter(X);
			option.color = (selection == option.ID) ? FlxColor.YELLOW : FlxColor.WHITE;
		}

		if (selection != previousSelection) FlxG.sound.play(Paths.getAudio('sfx/menu/scroll'));
	}
}
