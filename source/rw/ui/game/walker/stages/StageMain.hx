package rw.ui.game.walker.stages;

class StageMain extends Stage
{
	override function build()
	{
		super.build();

		game.stageBackLayer.add(new StageSprite(stage).scaleToScreen().setCamera(game.camGame));
	}
}
