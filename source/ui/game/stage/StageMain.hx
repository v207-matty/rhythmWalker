package ui.game.stage;

import flixel.FlxG;

class StageMain extends Stage
{
	override function build()
	{
		super.build();

		var backdrop:StageSprite = new StageSprite(stage);
		backdrop.setGraphicSize(FlxG.width, FlxG.height);
		backdrop.updateHitbox();
		backdrop.screenCenter();
		game.stageBackLayer.add(backdrop);
		backdrop.setCamera(game.camGame);
	}
}
