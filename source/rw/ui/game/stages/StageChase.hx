package rw.ui.game.stages;

import flixel.FlxG;

class StageChase extends Stage
{
	override public function new()
	{
		super('chase');
	}

	override function build()
	{
		super.build();

		game.data.beatMonsters.scale = .5;

		game.player.setScale(1);
		game.player.screenCenter(X);
		game.player.y = FlxG.height - game.player.height * 2;
	}
}
