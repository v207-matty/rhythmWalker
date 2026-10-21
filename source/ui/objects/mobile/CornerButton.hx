package ui.objects.mobile;

import util.Flag;
import flixel.FlxG;
import flixel.util.FlxSignal;
import ui.objects.RWSprite;

class CornerButton extends RWSprite
{
	public var back(default, null):RWSprite;

	public var onClicked:FlxSignal;

	override public function new(cornerButton = 'pauseBtn')
	{
		super('ui/mobile/$cornerButton');

		back = new RWSprite('ui/mobile/cornerButtonBG');

		setScale(#if MOBILE_PLATFORM 1 #else 0.5 #end);

		onClicked = new FlxSignal();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.mouse.overlaps(this) && FlxG.mouse.justPressed)
			onClicked.dispatch();
	}

	override function draw()
	{
		if (back != null)
		{
			back.cameras = cameras;

			back.setScale(this.scale.x, this.scale.y);
			back.scrollFactor.set(this.scrollFactor.x, this.scrollFactor.y);

			back.x = this.x;
			back.y = this.y;

			back.draw();
		}

		super.draw();
	}
}
