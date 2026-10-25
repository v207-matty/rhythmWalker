package rw.util;

import flixel.FlxG;
import flixel.util.FlxColor;

class Constants
{
	public static final TEXT_SIZE:Int = #if MOBILE_MODE 32; #else 16; #end
	public static final TEXT_OUTLINE_SIZE:Int = #if MOBILE_MODE 4; #else 2; #end

	public static final MOBILE_PLATFORM:Bool = #if MOBILE_PLATFORM true #else false #end;
	public static final MOBILE_MODE:Bool = #if MOBILE_MODE true #else false #end;

	public static final TRANSITION_COLOR:FlxColor = FlxColor.WHITE;

	public static var GAMEPLAY_SCORE_AVOID(get, null):Float;

	static function get_GAMEPLAY_SCORE_AVOID():Float
	{
		return 100 * (FlxG.height / 720);
	}

	public static var GAMEPLAY_SCORE_HIT(get, null):Float;

	static function get_GAMEPLAY_SCORE_HIT():Float
	{
		return -10 * (FlxG.height / 720);
	}
}
