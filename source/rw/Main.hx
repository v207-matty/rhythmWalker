package rw;

import rw.util.CrashUtil;
import rw.util.mobile.TouchUtil;
import rw.save.Save;
import rw.util.Constants;
import openfl.Lib;
import openfl.events.UncaughtErrorEvent;
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

		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, CrashUtil.onCrashing);

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
