package rw.ui.game.walker.stage;

class Stage extends PlayableComponent
{
	public var stage(default, null):String;

	override public function new(stage:String)
	{
		super();

		this.stage = stage;
	}
}
