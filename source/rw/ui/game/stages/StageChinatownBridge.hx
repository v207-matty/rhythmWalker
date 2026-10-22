package rw.ui.game.stages;

import flixel.FlxG;
import flixel.addons.display.FlxBackdrop;

class StageChinatownBridge extends Stage
{
	override public function new()
	{
		super('chinatown-bridge');
	}

	override function build()
	{
		super.build();

		var sky:FlxBackdrop = new FlxBackdrop(Paths.getImagePath('game/stages/chinatown/bridge/sky'));
		sky.scale.set(4, 4);
		sky.updateHitbox();
		sky.camera = game.camGame;

		sky.velocity.x = 2;
		sky.screenCenter();
		game.stageBackLayer.add(sky);

		var bridge:FlxBackdrop = new FlxBackdrop(Paths.getImagePath('game/stages/chinatown/bridge/bridge'), X);
		bridge.scale.set(4, 4);
		bridge.updateHitbox();
		bridge.camera = game.camGame;
		bridge.y = FlxG.height - bridge.height;
		game.stageBackLayer.add(bridge);
	}
}
