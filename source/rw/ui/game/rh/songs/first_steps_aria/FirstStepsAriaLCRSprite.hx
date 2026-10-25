package rw.ui.game.rh.songs.first_steps_aria;

import flixel.FlxCamera;
import rw.ui.game.rh.RHSprite;

class FirstStepsAriaLCRSprite extends RHSprite
{
	override public function new(file:String)
	{
		super('first-steps-aria/$file', true, 1280, 720);
		scaleToScreen();

		addAnim('center', [0]);
		addAnim('left', [1]);
		addAnim('right', [2]);
	}

	override function setCamera(cam:FlxCamera):FirstStepsAriaLCRSprite return cast super.setCamera(cam);
}
