package rw.ui.game.stages;

import flixel.FlxG;

class StageSave extends Stage
{
	override public function new(stage:String)
	{
		super(stage);
	}

	override function build()
	{
		super.build();

		game.data.beatMonsters.scale = .5;

		game.player.setScale(1);
		game.player.screenCenter(X);
		game.player.y = FlxG.height - game.player.height * 2;

		// var backdrop:StageSprite = new StageSprite('save/$stage');
		// backdrop.setGraphicSize(FlxG.width, FlxG.height);
		// backdrop.updateHitbox();
		// backdrop.screenCenter();
		// game.stageBackLayer.add(backdrop);
		// backdrop.setCamera(game.camGame);
	}
}
