package ui.objects;

import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.util.FlxColor;

class Floor extends RWSprite
{
	override public function new(positionObject:FlxObject, color:FlxColor, ?cam:FlxCamera)
	{
		super(null);

		makeGraphic(1, 1);

		setScale(FlxG.width, FlxG.height);
        setScrollFactor(0);

		screenCenter();

        this.color = color;

		if (positionObject != null)
			this.y = positionObject.y + positionObject.height;

		if (cam != null)
			setCamera(cam);
	}
}
