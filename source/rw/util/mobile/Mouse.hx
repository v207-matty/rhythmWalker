package rw.util.mobile;

import flixel.input.mouse.FlxMouse;

/**
 * Code yoinked from fnf's flixel
**/
class Mouse extends FlxMouse
{
	/**
	 * Check to see if mouse has just been moved upwards.
	 */
	public var justMovedUp(get, never):Bool;

	/**
	 * Check to see if mouse has just been moved downwards.
	 */
	public var justMovedDown(get, never):Bool;

	/**
	 * Check to see if mouse has just been moved leftwards.
	 */
	public var justMovedLeft(get, never):Bool;

	/**
	 * Check to see if mouse has just been moved rightwards.
	 */
	public var justMovedRight(get, never):Bool;

	@:noCompletion
	function get_justMovedUp():Bool
	{
		var swiped:Bool = _swipeDeltaY < -swipeThreshold.y;
		if (swiped) _startY = viewY;
		return swiped;
	}

	@:noCompletion
	function get_justMovedDown():Bool
	{
		var swiped:Bool = _swipeDeltaY > swipeThreshold.y;
		if (swiped) _startY = viewY;
		return swiped;
	}

	@:noCompletion
	function get_justMovedLeft():Bool
	{
		var swiped:Bool = _swipeDeltaX < -swipeThreshold.x;
		if (swiped) _startX = viewX;
		return swiped;
	}

	@:noCompletion
	function get_justMovedRight():Bool
	{
		var swiped:Bool = _swipeDeltaX > swipeThreshold.x;
		if (swiped) _startX = viewX;
		return swiped;
	}
}
