package rw.ui.game.walker.stage;

import flixel.FlxCamera;
import rw.ui.objects.RWSprite;

class StageSprite extends RWSprite
{
	override public function new(sprite:String, ?animated:Bool, ?fw:Int, ?fh:Int)
	{
		super((sprite == null) ? null : 'game/walker/stages/$sprite', animated, fw, fh);
		this.sprite = sprite;
	}

	override function setScale(?x:Float, ?y:Float):StageSprite return cast super.setScale(x, y);

	override function scaleToScreen():StageSprite return cast super.scaleToScreen();

	override function setCamera(cam:FlxCamera):StageSprite return cast super.setCamera(cam);

	override function setScrollFactor(?x:Float, ?y:Float):StageSprite return cast super.setScrollFactor(x, y);
}
