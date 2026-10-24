package rw.ui.game.stages;

import flixel.FlxG;

class StageChase extends Stage
{
	override public function new(stage:String)
	{
		super(stage);
	}

	override function build()
	{
		super.build();

		game.camGame.bgColor = 0xFF0D0712;
		
		game.data.beatMonsters.scale = .5;

		game.player.setScale(1);
		game.player.screenCenter(X);
		game.player.y = FlxG.height - game.player.height * ((stage == 'case-2') ? 1.25 : 2);

		var backdrop:StageSprite = new StageSprite('chase/$stage');
		backdrop.setGraphicSize(FlxG.width, FlxG.height);
		backdrop.updateHitbox();
		backdrop.screenCenter();
		game.stageBackLayer.add(backdrop);
		backdrop.setCamera(game.camGame);
	}
}
