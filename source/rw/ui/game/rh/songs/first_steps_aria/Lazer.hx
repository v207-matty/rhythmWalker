package rw.ui.game.rh.songs.first_steps_aria;

import flixel.FlxCamera;
import rw.ui.game.rh.RHSprite;

class Lazer extends RHSprite
{
	override public function new()
	{
		super('first-steps-aria/shots', true, 1280, 720);
		scaleToScreen();

		addAnim('center', [0]);
		addAnim('left', [1]);
		addAnim('right', [2]);
	}

	override function setCamera(cam:FlxCamera):Lazer return cast super.setCamera(cam);
}
