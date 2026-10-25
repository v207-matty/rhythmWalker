package rw.ui.game.walker.stages;

import rw.save.Save;
import rw.util.CustomShader;

class StageMainWithered extends StageMain
{
	override public function new()
	{
		super('stage-withered');
	}

	override function build()
	{
		super.build();

		if (!Save.options.shaders) return;

		var bgShader = new CustomShader('dropshadow');
		var charShader = new CustomShader('dropshadow');
		var monsterShader = new CustomShader('dropshadow');

		bgShader.setFloat('hue', -24.0);
		bgShader.setFloat('saturation', -24.0);
		bgShader.setFloat('brightness', -36.0);
		bgShader.setFloat('contrast', 0.0);

		charShader.setFloat('hue', -3.0);
		charShader.setFloat('saturation', 7.0);
		charShader.setFloat('brightness', -75.0);
		charShader.setFloat('contrast', 0.0);

		monsterShader.setFloat('hue', -43.0);
		monsterShader.setFloat('saturation', -51.0);
		monsterShader.setFloat('brightness', -73.0);
		monsterShader.setFloat('contrast', 0.0);

		game.back.members[0].shader = bgShader;
		game.player.shader = charShader;
		game.beatMonsters.shader = monsterShader;
	}
}
