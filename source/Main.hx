package;

import ui.game.song.SongRank;
#if sys
import sys.io.File;
import sys.FileSystem;
#end
import haxe.CallStack;
import openfl.Lib;
import openfl.events.UncaughtErrorEvent;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.addons.transition.FlxTransitionSprite;
import flixel.graphics.FlxGraphic;
import flixel.addons.transition.TransitionData;
import haxe.Json;
import ui.freeplay.Freeplay;
import lime.utils.Assets;
import util.Flag;
import util.WindowUtil;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import openfl.events.Event;
import flixel.FlxGame;
import ui.*;

using StringTools;

class Main extends FlxGame
{
	public function new()
	{
		super(0, 0, QualityWarning);
	}

	override function create(_:Event)
	{
		Save.init();

		loadAssets();

		WindowUtil.resetTitle(true);

		#if debug
		WindowUtil.appendToTitle('(Debug)');
		#end

		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrashing);

		FlxG.sound.applySoundCurve = (volume:Float) ->
		{
			final clampedVolume = Math.max(0, Math.min(1, volume));
			return Math.exp(Math.log(0.001) * (1 - clampedVolume));
		}
		FlxG.sound.reverseSoundCurve = (volume:Float) ->
		{
			final clampedVolume = Math.max(0.001, Math.min(1, volume));
			return 1 - (Math.log(clampedVolume) / Math.log(0.001));
		}

		super.create(_);

		FlxG.console.registerClass(Paths);
		FlxG.console.registerClass(Save);
		FlxG.console.registerClass(Freeplay);
		FlxG.console.registerClass(WindowUtil);

		FlxTransitionableState.defaultTransIn = FlxTransitionableState.defaultTransOut = getDefaultTransition();
		FlxG.sound.soundTray.volumeUpSound = FlxG.sound.soundTray.volumeDownSound = Paths.getAudio('sfx/volume');
	}

	override function update()
	{
		super.update();

		if (FlxG.keys.pressed.F4)
			throw 'Debug Crash';
	}

	function onCrashing(e:UncaughtErrorEvent)
	{
		e.preventDefault();

		Save.save();

		var stack = CallStack.exceptionStack(true);

		var error:String = 'Error: ${e.error}\n\nCall Stack:\n';
		@:privateAccess stack.reverse();

		function pushStack(stackItem:StackItem)
		{
			switch (stackItem)
			{
				case FilePos(innerStackItem, file, line, column):
					error += ' in ${file}#${line}';
					if (column != null)
						error += ':${column}';
				case CFunction:
					error += '[Function] ';
				case Module(m):
					error += '[Module(${m})] ';
				case Method(classname, method):
					error += '[Function(${classname}.${method})] ';
				case LocalFunction(v):
					error += '[LocalFunction(${v})] ';
			}
			error += '\n';
		}

		for (stackItem in stack)
			pushStack(stackItem);

		error += '\n\nPlease report this on the github: https://github.com/v207-matty/rhythmWalker/issues';

		#if sys
		var timestamp = Date.now().getTime();

		if (!FileSystem.exists('crash'))
			FileSystem.createDirectory('crash');

		File.saveContent('crash/$timestamp.txt', error);

		error += '\nThe crash log is saved to "crash/$timestamp.txt"';
		#end

		trace(error);

		WindowUtil.alert('Crash Handler', error);

		#if sys
		Sys.exit(0);
		#end

		FlxG.stage.window.close();
	}

	function loadAssets()
	{
		var songList = Paths.json('game/songs/list');
		var tipsList = Paths.txt('game/tips');

		if (Assets.exists(songList))
			Freeplay.songList = Json.parse(Assets.getText(songList));
		else
			throw 'SONG LIST IS MISSING, GAME WILL DIE NOW.';

		if (Assets.exists(tipsList))
			Freeplay.tips = [
				for (line in Assets.getText(tipsList).split('\n'))
					if (line.trim().length > 0) line.trim()
			];
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
