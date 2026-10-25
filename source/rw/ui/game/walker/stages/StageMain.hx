package rw.ui.game.walker.stages;

class StageMain extends WalkerStage
{
	var backdrop:WalkerStageSprite;

	override function build()
	{
		super.build();

		game.back.add(backdrop = new WalkerStageSprite(stage).scaleToScreen().setCamera(game.camGame));
	}

	override function destroy()
	{
		super.destroy();

		backdrop.destroy();
		backdrop = null;
	}
}
