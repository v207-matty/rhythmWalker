package rw.ui.game.rh;

import flixel.util.FlxColor;
import flixel.FlxCamera;
import rw.ui.objects.RWSprite;

class RHSprite extends RWSprite
{
	override public function new(sprite:String, ?animated:Bool, ?fw:Int, ?fh:Int)
	{
		super((sprite == null) ? null : 'game/rh/$sprite', animated, fw, fh);
		this.sprite = sprite;
	}

	override function makeGraphic(width:Int, height:Int, color:FlxColor = FlxColor.WHITE, unique:Bool = false,
			?key:String):RHSprite return cast super.makeGraphic(width, height, color, unique, key);

	override function setScale(?x:Float, ?y:Float):RHSprite return cast super.setScale(x, y);

	override function scaleToScreen():RHSprite return cast super.scaleToScreen();

	override function setCamera(cam:FlxCamera):RHSprite return cast super.setCamera(cam);

	override function setScrollFactor(?x:Float, ?y:Float):RHSprite return cast super.setScrollFactor(x, y);
}
