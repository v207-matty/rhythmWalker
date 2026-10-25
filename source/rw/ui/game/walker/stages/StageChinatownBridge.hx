package rw.ui.game.walker.stages;

import flixel.FlxG;
import flixel.addons.display.FlxBackdrop;

class StageChinatownBridge extends WalkerStage
{
	override public function new()
	{
		super('chinatown-bridge');
	}

	var sky:FlxBackdrop;
	var bridge:FlxBackdrop;

	override function build()
	{
		super.build();

		sky = new FlxBackdrop(Paths.getImagePath('game/walker/stages/chinatown/bridge/sky'));
		sky.scale.set(4, 4);
		sky.updateHitbox();
		sky.camera = game.camGame;

		sky.velocity.x = 2;
		sky.screenCenter();
		game.back.add(sky);

		bridge = new FlxBackdrop(Paths.getImagePath('game/walker/stages/chinatown/bridge/bridge'), X);
		bridge.scale.set(4, 4);
		bridge.updateHitbox();
		bridge.camera = game.camGame;
		bridge.y = FlxG.height - bridge.height;
		game.back.add(bridge);
	}

	override function destroy()
	{
		super.destroy();

		sky.destroy();
		bridge.destroy();

		sky = bridge = null;
	}
}
