package;

import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.addons.transition.FlxTransitionSprite;
import flixel.graphics.FlxGraphic;
import flixel.addons.transition.TransitionData;
import haxe.Json;
import freeplay.Freeplay;
import lime.utils.Assets;
import util.Flag;
import util.WindowUtil;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import openfl.events.Event;
import flixel.FlxGame;

using StringTools;

class Main extends FlxGame
{
	public function new()
	{
		super(0, 0, InitState);
	}

	override function create(_:Event)
	{
		FlxTransitionableState.defaultTransIn = getDefaultTransition();
		FlxTransitionableState.defaultTransOut = getDefaultTransition();

		FlxG.sound.soundTray.volumeUpSound = Paths.getAudio('sfx/volume');
		FlxG.sound.soundTray.volumeDownSound = Paths.getAudio('sfx/volume');

		Save.init();

		loadAssets();

		WindowUtil.resetTitle(true);

		if (Flag.IS_DEBUG)
			WindowUtil.appendToTitle('(Debug)');

		for (id => flag in Flag.list)
			trace('Flag "${id}" : $flag');

		super.create(_);
	}

	function loadAssets()
	{
		var songList = Paths.json('game/songs/list');
		var tipsList = Paths.txt('game/tips');

		if (Assets.exists(songList))
		{
			Freeplay.songList = Json.parse(Assets.getText(songList));
		}
		else
		{
			FlxG.stage.window.alert('SONG LIST IS MISSING, GAME WILL DIE NOW.');
			FlxG.stage.window.close();
		}

		if (Assets.exists(tipsList))
		{
			Freeplay.tips = [
				for (line in Assets.getText(tipsList).split('\n'))
					if (line.trim().length > 0) line.trim()
			];
		}
	}

	function getDefaultTransition():TransitionData
	{
		var transGraphic = FlxGraphic.fromClass(cast GraphicTransTileDiamond);
		transGraphic.persist = true;
		transGraphic.destroyOnNoUse = false;

		return new TransitionData(TILES, FlxColor.BLACK, 1, FlxPoint.get(0, -1), {
			asset: transGraphic,
			width: 32,
			height: 32
		},);
	}
}
