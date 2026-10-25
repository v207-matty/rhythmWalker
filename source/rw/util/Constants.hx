package rw.util;

import flixel.util.FlxColor;

class Constants
{
	public static final TEXT_SIZE:Int = #if MOBILE_MODE 32; #else 16; #end
	public static final TEXT_OUTLINE_SIZE:Int = #if MOBILE_MODE 4; #else 2; #end

	public static final MOBILE_PLATFORM:Bool = #if MOBILE_PLATFORM true #else false #end;
	public static final MOBILE_MODE:Bool = #if MOBILE_MODE true #else false #end;

	public static final TRANSITION_COLOR:FlxColor = FlxColor.WHITE;

	public static final GAMEPLAY_WALKER_SCORE_AVOID:Int = 100;
	public static final GAMEPLAY_WALKER_SCORE_HIT:Int = -10;
}
