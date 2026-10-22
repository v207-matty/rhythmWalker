package rw.ui;

import flixel.addons.ui.FlxUIState;
import rw.util.Constants;
import rw.ui.debug.*;
import rw.ui.game.*;
import rw.ui.game.song.*;
import rw.ui.game.dialogue.*;
import rw.ui.freeplay.*;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxState;

using StringTools;

class QualityWarning extends FlxUIState
{
	override function create()
	{
		super.create();

		var warning:FlxText = new FlxText(0, 0, FlxG.width,
			'HELLO THERE!'
			+ '\nWELCOME TO RHYTHM WALKER!'
			+ '\n\nSorry to say this but if you actually think the songs are gonna sound good or that the gameplay will be good, you are mistaken :('
			+ '\nI don\'t know much on making music and I\'m too stubborn to go through the effort of tutorials,'
			+ '\nso I\'m legit just winging it with Kira Studio.'
			+ '\n\nNevertheless I hope you atleast have some bit of fun.'
			+ '\n\n(Click anywhere to proceed)',
			Constants.TEXT_SIZE);
		warning.alignment = CENTER;
		add(warning);
		warning.screenCenter();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.mouse.justPressed) proceed();
	}

	function proceed()
	{
		#if GAMEPLAY
		FlxG.switchState(() -> new PlayState('chase'));
		#elseif DIALOGUE
		FlxG.switchState(() -> new DialogueScene(new SongData('encapture')));
		#elseif RESULTS
		FlxG.switchState(() -> new ResultsState('train wreak-default'));
		#elseif PLAYER_VIEWER
		FlxG.switchState(() -> new PlayerViewer());
		#else
		FlxG.switchState(() -> new Freeplay());
		#end
	}
}
