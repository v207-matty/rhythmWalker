package ui;

import util.Constants;
import util.Flag;
import ui.game.*;
import ui.game.song.*;
import ui.game.dialogue.*;
import ui.freeplay.*;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxState;

using StringTools;

class QualityWarning extends FlxUIState
{
	override function create()
	{
		super.create();

		var warning:FlxText = new FlxText(0, 0, 0,
			'HELLO THERE!'
			+ '\nWELCOME TO RHYTHM WALKER!'
			+ '\n\nSorry to say this but if you actually think the songs are gonna sound good or that the gameplay will be good, you are mistaken :('
			+ '\nI don\'t know much on making music and I\'m too stubborn to go through the effort of tutorials,'
			+ '\nso I\'m legit just winging it with Kira Studio.'
			+ '\n\nNevertheless I hope you atleast have some bit of fun.'
			+ '\n\n(Click anywhere to proceed)',
			Constants.TEXT_SIZE);
		add(warning);
		warning.screenCenter();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.mouse.justPressed)
			proceed();
	}

	function proceed()
	{
		if (Flag.STARTINGSTATE_GAMEPLAY)
			FlxG.switchState(() -> new PlayState('train wreak'));
		else if (Flag.STARTINGSTATE_DIALOGUE)
			FlxG.switchState(() -> new DialogueScene(new Song('encapture')));
		else if (Flag.STARTINGSTATE_RESULTS)
			FlxG.switchState(() -> new ResultsState('train wreak-default'));
		else
			FlxG.switchState(() -> new Freeplay());
	}
}
