package rw.ui.game.walker.stage;

class WalkerStage extends WalkerPlayableComponent
{
	public var stage(default, null):String;

	override public function new(stage:String)
	{
		super();

		this.stage = stage;
	}
}
