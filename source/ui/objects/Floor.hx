package ui.objects;

import flixel.math.FlxPoint;
import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.util.FlxColor;

class Floor extends RWSprite
{
	override public function new(positionObject:FlxObject, color:FlxColor, ?cam:FlxCamera, ?sf:FlxPoint)
	{
		super(null);

		makeGraphic(1, 1);

		setScale(FlxG.width, FlxG.height);

		screenCenter();

		this.color = color;

		if (positionObject != null)
			this.y = positionObject.y + positionObject.height;

		if (cam != null)
			setCamera(cam);
		
		setScrollFactor(sf?.x ?? 0, sf?.y ?? 0);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		setScale(this.camera.viewWidth, scale.y);
	}
}
