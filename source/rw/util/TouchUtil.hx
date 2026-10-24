package rw.util;

import flixel.input.FlxSwipe;
import flixel.math.FlxMath;
import flixel.FlxG;

class TouchUtil
{
	public static function getSwipes() return FlxG.swipes;

	public static function getSwipe() return getSwipes()[0] ?? null;

	public static function validSwipe(swipe:FlxSwipe) return swipe != null && swipe.duration > 0 && swipe.distance > 0;

	static final swipe_range_vertical = [0.5, 1.5];

	static final swipe_range_left = [-1.0, 1.0];
	static final swipe_range_right = [-0.2, 1.2];

	public static function swippedUp()
	{
		var swipe = getSwipe();
		if (!validSwipe(swipe)) return false;

		final up = FlxMath.roundDecimal(swipe.degrees / -90, 2);
		return (up >= swipe_range_vertical[0] && up <= swipe_range_vertical[1]);
	}

	public static function swippedDown()
	{
		var swipe = getSwipe();
		if (!validSwipe(swipe)) return false;

		final down = FlxMath.roundDecimal(swipe.degrees / 90, 2);
		trace('down ', swipe.degrees, down);
		return (down >= swipe_range_vertical[0] && down <= swipe_range_vertical[1]);
	}

	public static function swippedLeft()
	{
		var swipe = getSwipe();
		if (!validSwipe(swipe)) return false;

		final left = FlxMath.roundDecimal(swipe.degrees / 180, 2);
		trace('left ', swipe.degrees, left);
		return (left >= swipe_range_left[0] && left <= swipe_range_left[1]);
	}

	public static function swippedRight()
	{
		var swipe = getSwipe();
		if (!validSwipe(swipe)) return false;

		final right = FlxMath.roundDecimal(swipe.degrees / 180, 2);
		return (right >= swipe_range_right[0] && right <= swipe_range_right[1]);
	}
}
