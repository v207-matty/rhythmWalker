package rw.util.mobile;

import flixel.input.mouse.FlxMouse;
import flixel.input.touch.FlxTouch;
import flixel.input.FlxSwipe;
import flixel.math.FlxMath;
import flixel.FlxG;

class TouchUtil
{
	public static var touch(get, never):FlxTouch;

	static function get_touch() return FlxG.touches.getFirst();

	public static var mouse(get, never):FlxMouse;

	static function get_mouse() return FlxG.mouse;

	public static function swippedLeft()
	{
		return (touch?.justMovedLeft ?? false) || (mouse.pressed && mouse.justMovedLeft);
	}

	public static function swippedDown()
	{
		return (touch?.justMovedDown ?? false) || (mouse.pressed && mouse.justMovedDown);
	}

	public static function swippedUp()
	{
		return (touch?.justMovedUp ?? false) || (mouse.pressed && mouse.justMovedUp);
	}

	public static function swippedRight()
	{
		return (touch?.justMovedRight ?? false) || (mouse.pressed && mouse.justMovedRight);
	}
}
