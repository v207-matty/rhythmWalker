package rw.ui.game.walker.stages;

import flixel.FlxG;
import flixel.addons.display.FlxBackdrop;

class StageChinatownBridge extends WalkerStage
{
	override public function new()
	{
		super('chinatown-bridge');
	}

	override function build()
	{
		super.build();

		var sky = new FlxBackdrop(Paths.getImagePath('game/walker/stages/chinatown/bridge/sky'));
		sky.scale.set(4, 4);
		sky.updateHitbox();
		sky.camera = game.camGame;

		sky.velocity.x = 2;
		sky.screenCenter();
		game.back.add(sky);

		var bridge = new FlxBackdrop(Paths.getImagePath('game/walker/stages/chinatown/bridge/bridge'), X);
		bridge.scale.set(4, 4);
		bridge.updateHitbox();
		bridge.camera = game.camGame;
		bridge.y = FlxG.height - bridge.height;
		game.back.add(bridge);
	}
}
