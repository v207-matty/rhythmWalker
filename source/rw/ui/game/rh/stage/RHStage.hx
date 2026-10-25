package rw.ui.game.rh.stage;

class RHStage extends RHPlayableComponent
{
	public var stage(default, null):String;

	override public function new(stage:String)
	{
		super();

		this.stage = stage;
	}
}
