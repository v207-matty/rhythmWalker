package rw.util.mobile;

import flixel.input.touch.FlxTouch;

/**
 * Code yoinked from fnf's flixel
**/
class Touch extends FlxTouch
{
	/**
	 * Check to see if this touch has just been moved upwards.
	 */
	public var justMovedUp(get, never):Bool;

	/**
	 * Check to see if this touch has just been moved downwards.
	 */
	public var justMovedDown(get, never):Bool;

	/**
	 * Check to see if this touch has just been moved leftwards.
	 */
	public var justMovedLeft(get, never):Bool;

	/**
	 * Check to see if this touch has just been moved rightwards.
	 */
	public var justMovedRight(get, never):Bool;

	@:noCompletion
	inline function get_justMovedUp():Bool
	{
		var swiped:Bool = _swipeDeltaY > FlxG.touches.swipeThreshold.y;
		if (swiped) _startY = viewY;
		return swiped;
	}

	@:noCompletion
	inline function get_justMovedDown():Bool
	{
		var swiped:Bool = _swipeDeltaY < -FlxG.touches.swipeThreshold.y;
		if (swiped) _startY = viewY;
		return swiped;
	}

	@:noCompletion
	inline function get_justMovedLeft():Bool
	{
		var swiped:Bool = _swipeDeltaX > FlxG.touches.swipeThreshold.x;
		if (swiped) _startX = viewX;
		return swiped;
	}

	@:noCompletion
	inline function get_justMovedRight():Bool
	{
		var swiped:Bool = _swipeDeltaX < -FlxG.touches.swipeThreshold.x;
		if (swiped) _startX = viewX;
		return swiped;
	}
}
