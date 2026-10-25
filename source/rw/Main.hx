package rw;

import rw.util.mobile.TouchUtil;
import flixel.input.mouse.FlxMouse;
import lime.app.Application;
import flixel.FlxState;
import rw.save.Save;
import rw.util.Constants;
import rw.ui.game.song.SongRank;
import haxe.CallStack;
import openfl.Lib;
import openfl.events.UncaughtErrorEvent;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.addons.transition.FlxTransitionSprite;
import flixel.graphics.FlxGraphic;
import flixel.addons.transition.TransitionData;
import haxe.Json;
import rw.ui.menu.freeplay.Freeplay;
import lime.utils.Assets;
import rw.util.WindowUtil;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import openfl.events.Event;
import flixel.FlxGame;
import rw.ui.*;
#if sys
import sys.io.File;
import sys.FileSystem;
#end
#if (android || ios)
import haxe.io.Path;
#end
#if android
import extension.androidtools.content.Context;
#end
#if ios
import lime.system.System;
#end

using StringTools;

class Main extends FlxGame
{
	public function new()
	{
		// Set the current working directory for Android and iOS devices
		#if android
		// On Android use External Files Dir.
		Sys.setCwd(Path.addTrailingSlash(Context.getExternalFilesDir()));
		#elseif ios
		// On iOS use Documents Dir.
		Sys.setCwd(Path.addTrailingSlash(System.documentsDirectory));
		#end

		super(0, 0, null, 60, 60, true);
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
		#if !mobile
		FlxG.sound.soundTray.volumeUpSound = FlxG.sound.soundTray.volumeDownSound = Paths.getAudio('ui/sfx/volume');
		#end

		TouchUtil.mouse.swipeThreshold.set(500, 400);
		FlxG.touches.swipeThreshold.set(200, 300);

		FlxG.switchState(() -> new QualityWarning());
	}

	override function update()
	{
		super.update();

		if (FlxG.keys.pressed.F5) throw 'Debug Crash';

		#if android
		if (FlxG.android.justPressed.ANY) Save.save();
		#end
	}

	function onCrashing(e:UncaughtErrorEvent)
	{
		e.preventDefault();

		Save.save();

		var stack = CallStack.exceptionStack(true);

		var shortDisplayError:String = 'Error: ${e.error}';
		var error:String = '$shortDisplayError\n\nCall Stack:\n';
		@:privateAccess stack.reverse();

		function pushStack(stackItem:StackItem)
		{
			switch (stackItem)
			{
				case FilePos(innerStackItem, file, line, column):
					error += ' in ${file}#${line}';
					if (column != null) error += ':${column}';
				case CFunction: error += '[Function] ';
				case Module(m): error += '[Module(${m})] ';
				case Method(classname, method): error += '[Function(${classname}.${method})] ';
				case LocalFunction(v): error += '[LocalFunction(${v})] ';
			}
			error += '\n';
		}

		for (stackItem in stack) pushStack(stackItem);

		shortDisplayError += '\n\n${stack.length} CallStack entry / entries';

		var plzReport = '\n\nPlease report this on the github: https://github.com/v207-matty/rhythmWalker/issues';

		shortDisplayError += plzReport;
		error += plzReport;

		#if sys
		var timestamp = Date.now().getTime();

		if (!FileSystem.exists('crash')) FileSystem.createDirectory('crash');

		File.saveContent('crash/$timestamp.txt', error);

		var path = 'crash/$timestamp.txt';

		#if android
		path = 'Android/data/${Application.current.meta.get('packageName')}/files/$path';
		#end

		var savedTo = '\nThe crash log is saved to "$path"';

		#if android
		savedTo += ' (Most likely...)';
		#end

		shortDisplayError += savedTo;

		#if android
		shortDisplayError += '\n(You may need to install an app that can view files in there to get the file)';
		#end

		error += savedTo;
		#end

		trace(error);

		WindowUtil.alert('Crash Handling', shortDisplayError);

		#if sys
		Sys.exit(0);
		#end

		WindowUtil.close();
	}

	function loadAssets()
	{
		var songList = Paths.json('game/songs/list');
		var tipsList = Paths.txt('game/tips');

		if (Assets.exists(songList)) Freeplay.songList = Json.parse(Assets.getText(songList));
		else throw 'SONG LIST IS MISSING, GAME WILL DIE NOW.';

		if (Assets.exists(tipsList)) Freeplay.tips = [
			for (line in Assets.getText(tipsList).split('\n')) if (line.trim().length > 0) line.trim()
		];
	}

	function getDefaultTransition():TransitionData
	{
		var transGraphic = FlxGraphic.fromClass(cast GraphicTransTileDiamond);
		transGraphic.persist = true;
		transGraphic.destroyOnNoUse = false;

		return new TransitionData(TILES, Constants.TRANSITION_COLOR, 1, FlxPoint.get(0, -1), {
			asset: transGraphic,
			width: 32,
			height: 32
		},);
	}
}
