package util;

import util.macro.DefineMacro;

enum abstract Flag(Bool) from Bool to Bool
{
	public static var list:Map<String, Flag> = [];

	public static final PLATFORM_LINUX = new Flag('PLATFORM_LINUX', [DefineMacro.isDefined('linux')]);
	public static final PLATFORM_WEB = new Flag('PLATFORM_WEB', [DefineMacro.isDefined('web')]);
	public static final PLATFORM_HASHLINK = new Flag('PLATFORM_HASHLINK', [DefineMacro.isDefined('hl')]);
	public static final PLATFORM_ANDROID = new Flag('PLATFORM_ANDROID', [DefineMacro.isDefined('android')]);
	public static final PLATFORM_IOS = new Flag('PLATFORM_IOS', [DefineMacro.isDefined('ios')]);
	public static final PLATFORM_MOBILE = new Flag('PLATFORM_MOBILE', [PLATFORM_ANDROID || PLATFORM_IOS]);

	public static final IS_32BIT = new Flag('IS_32BIT', [DefineMacro.isDefined('_32bit'),]);
	public static final IS_DEBUG = new Flag('IS_DEBUG', [DefineMacro.isDefined('debug'),]);

	public static final IS_MOBILE_MODE = new Flag('IS_MOBILE_MODE', [DefineMacro.isDefined('MOBILE_MODE')
		|| PLATFORM_WEB
		|| PLATFORM_MOBILE]);

	public static final PLAY_SHADERS = new Flag('PLAY_SHADERS', [!DefineMacro.isDefined('DISABLE_PLAY_SHADERS')]);
	public static final PLAY_IMMORTAL = new Flag('PLAY_IMMORTAL', [DefineMacro.isDefined('immortal') || DefineMacro.isDefined('IMMORTAL')]);

	public static final FREEPLAY_BGAUDIO = new Flag('FREEPLAY_BGAUDIO', [!PLATFORM_LINUX, !DefineMacro.isDefined('DISABLE_FREEPLAY_BGAUDIO')]);

	public static final FREEPLAY_DISPLAY_TIP = new Flag('FREEPLAY_DISPLAY_TIP', []);
	public static final FREEPLAY_DISPLAY_SONG_SCORE = new Flag('FREEPLAY_DISPLAY_SONG_SCORE', [!PLATFORM_WEB]);
	public static final FREEPLAY_DISPLAY_SONG_RANK = new Flag('FREEPLAY_DISPLAY_SONG_RANK', [!PLATFORM_WEB]);
	public static final FREEPLAY_DISPLAY_SONG_PLAYED = new Flag('FREEPLAY_DISPLAY_TIP', [!PLATFORM_WEB, FREEPLAY_DISPLAY_SONG_RANK]);

	public static final FREEPLAY_VISUALIZER = new Flag('FREEPLAY_VISUALIZER', [
		!PLATFORM_WEB,
		!PLATFORM_LINUX,
		!DefineMacro.isDefined('DISABLE_FREEPLAY_VISUALIZER'),
		!DefineMacro.isDefined('FREEPLAY_CENTER_LAYOUT'),
	]);
	public static final FREEPLAY_VISUALIZER_MULTICACHE = new Flag('FREEPLAY_VISUALIZER_MULTICACHE',
		[FREEPLAY_VISUALIZER, !PLATFORM_LINUX, !IS_32BIT, !IS_MOBILE_MODE]);

	public static final FREEPLAY_CENTER_LAYOUT = new Flag('FREEPLAY_CENTER_LAYOUT', [DefineMacro.isDefined('FREEPLAY_CENTER_LAYOUT')
		|| !FREEPLAY_VISUALIZER]);

	public static final FREEPLAY_LEFT_LAYOUT = new Flag('FREEPLAY_LEFT_LAYOUT', [
		DefineMacro.isDefined('FREEPLAY_LEFT_LAYOUT') || IS_MOBILE_MODE,
		!FREEPLAY_CENTER_LAYOUT
	]);
	public static final FREEPLAY_RIGHT_LAYOUT = new Flag('FREEPLAY_RIGHT_LAYOUT', [!FREEPLAY_LEFT_LAYOUT, !FREEPLAY_CENTER_LAYOUT]);

	public static final STARTINGSTATE_GAMEPLAY = new Flag('STARTINGSTATE_GAMEPLAY', [DefineMacro.isDefined('GAMEPLAY')]);
	public static final STARTINGSTATE_DIALOGUE = new Flag('STARTINGSTATE_DIALOGUE', [DefineMacro.isDefined('DIALOGUE')]);
	public static final STARTINGSTATE_RESULTS = new Flag('STARTINGSTATE_RESULTS', [DefineMacro.isDefined('RESULTS')]);

	public static final SAVE_CLEAR = new Flag('SAVE_CLEAR', [DefineMacro.isDefined('clear') || DefineMacro.isDefined('SAVE_CLEAR')]);

	public function new(id:String, conditionals:Array<Bool>)
	{
		set(conditionals);

		if (!list.exists(id))
			list.set(id, this);
	}

	public inline function set(conditionals:Array<Bool>)
		this = (conditionals == [] || conditionals.filter(b -> return b).length == conditionals.length);
}
