package rw.ui.game.walker.stages;

import flixel.addons.display.FlxBackdrop;
import flixel.FlxG;

class StageChinatown extends WalkerStage
{
	override public function new()
	{
		super('chinatown');
	}

	override function build()
	{
		super.build();

		var sky = new FlxBackdrop(Paths.getImagePath('game/walker/stages/chinatown/town/sky'));
		sky.scale.set(2, 2);
		sky.updateHitbox();
		sky.camera = game.camGame;

		sky.velocity.x = 2;
		sky.screenCenter();
		game.back.add(sky);

		game.back.add(new WalkerStageSprite('chinatown/town/town').scaleToScreen());
	}
}
