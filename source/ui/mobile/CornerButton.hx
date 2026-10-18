package ui.mobile;

import ui.objects.RWSprite;

class CornerButton extends RWSprite
{
	public var back(default, null):RWSprite;

	override public function new(cornerButton = 'pauseBtn')
	{
		super('ui/mobile/$cornerButton');

		back = new RWSprite('ui/mobile/cornerButtonBG');

		setScale(0.5);
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
