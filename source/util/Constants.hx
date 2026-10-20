package util;

import openfl.display.BlendMode;

class Constants
{
	public static final TEXT_SIZE:Int = Flag.PLATFORM_MOBILE ? 32 : 16;
	public static final TEXT_OUTLINE_SIZE:Int = Flag.PLATFORM_MOBILE ? 4 : 2;

	public static final BLENDMODE_MAP:Map<String, BlendMode> = [
		'ADD'.toLowerCase() => BlendMode.ADD,
		'ALPHA'.toLowerCase() => BlendMode.ALPHA,
		'DARKEN'.toLowerCase() => BlendMode.DARKEN,
		'DIFFERENCE'.toLowerCase() => BlendMode.DIFFERENCE,
		'ERASE'.toLowerCase() => BlendMode.ERASE,
		'HARDLIGHT'.toLowerCase() => BlendMode.HARDLIGHT,
		'INVERT'.toLowerCase() => BlendMode.INVERT,
		'LAYER'.toLowerCase() => BlendMode.LAYER,
		'LIGHTEN'.toLowerCase() => BlendMode.LIGHTEN,
		'MULTIPLY'.toLowerCase() => BlendMode.MULTIPLY,
		'NORMAL'.toLowerCase() => BlendMode.NORMAL,
		'OVERLAY'.toLowerCase() => BlendMode.OVERLAY,
		'SCREEN'.toLowerCase() => BlendMode.SCREEN,
		'SHADER'.toLowerCase() => BlendMode.SHADER,
		'SUBTRACT'.toLowerCase() => BlendMode.SUBTRACT,
	];
}
