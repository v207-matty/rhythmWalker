package rw.ui.game.walker.beatmonster;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import rw.ui.objects.RWSprite;

class BeatMonster extends RWSprite
{
	public var avoided:Bool = false;

	override public function new(scale:Float)
	{
		super(null);

		makeGraphic(1, 1, FlxColor.RED);
		setScale(32 * scale);
	}
}
