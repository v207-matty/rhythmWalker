package rw.ui.game.walker.stages;

class StageMain extends WalkerStage
{
	override function build()
	{
		super.build();

		game.back.add(new WalkerStageSprite(stage).scaleToScreen().setCamera(game.camGame));
	}
}
