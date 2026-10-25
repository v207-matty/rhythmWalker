package rw.ui.game.rh.stages;

class RHStageMain extends RHStage
{
	override function build()
	{
		super.build();

        game.back.add(new RHStageSprite(stage).scaleToScreen().setCamera(game.camGame));
	}
}
