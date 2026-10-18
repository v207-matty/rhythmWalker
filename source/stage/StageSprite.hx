package stage;

import ui.objects.RWSprite;

class StageSprite extends RWSprite
{
	override public function new(sprite:String, ?animated:Bool, ?fw:Int, ?fh:Int)
	{
		super((sprite == null) ? null : 'game/stages/$sprite', animated, fw, fh);
		this.sprite = sprite;
	}
}
