package rw.ui.game.stages;

import rw.util.CustomShader;
import rw.save.Save;
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
		game.player.y = FlxG.height - game.player.height * ((stage == 'chase-2') ? 0.5 : 2);

		var backdrop:StageSprite = new StageSprite('chase/$stage');
		backdrop.setGraphicSize(FlxG.width, FlxG.height);
		backdrop.updateHitbox();
		backdrop.screenCenter();
		game.stageBackLayer.add(backdrop);
		backdrop.setCamera(game.camGame);

		if (!Save.options.shaders) return;

		var charShader = new CustomShader('dropshadow');

		charShader.setFloat('hue', -9.0);
		charShader.setFloat('saturation', -15.0);
		charShader.setFloat('brightness', -22.0);
		charShader.setFloat('contrast', 0.0);

		game.player.shader = game.beatMonsters.shader = charShader;
	}
}
