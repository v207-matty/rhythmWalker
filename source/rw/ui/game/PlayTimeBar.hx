package rw.ui.game;

import flixel.math.FlxMath;
import flixel.util.FlxColor;
import rw.util.Constants;
import flixel.FlxG;
import rw.ui.objects.RWSprite;
import flixel.FlxSprite;

class PlayTimeBar extends RWSprite
{
	public var linked:Bool = true;

	public var target(default, set):Float = 0;

	function set_target(newTarget):Float
	{
		if (!linked) return target;
		return target = newTarget;
	}

    public var lerpRate:Float = 0.04;

	override public function new()
	{
		super(null);

		makeGraphic(1, 1);
		setScale(FlxG.width, Math.floor(Constants.TEXT_SIZE / 2));
		y = FlxG.height - height;
		color = FlxColor.LIME;
		scale.x = 0;
	}

    override function update(elapsed:Float) {
        super.update(elapsed);

		scale.x = FlxMath.lerp(scale.x, target, lerpRate);
    }
}
