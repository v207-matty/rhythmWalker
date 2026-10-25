package rw.ui.game.rh.stage;

import flixel.FlxCamera;
import rw.ui.objects.RWSprite;

class RHStageSprite extends RWSprite
{
	override public function new(sprite:String, ?animated:Bool, ?fw:Int, ?fh:Int)
	{
		super((sprite == null) ? null : 'game/walker/stages/$sprite', animated, fw, fh);
		this.sprite = sprite;
	}

	override function setScale(?x:Float, ?y:Float):RHStageSprite return cast super.setScale(x, y);

	override function scaleToScreen():RHStageSprite return cast super.scaleToScreen();

	override function setCamera(cam:FlxCamera):RHStageSprite return cast super.setCamera(cam);

	override function setScrollFactor(?x:Float, ?y:Float):RHStageSprite return cast super.setScrollFactor(x, y);
}
