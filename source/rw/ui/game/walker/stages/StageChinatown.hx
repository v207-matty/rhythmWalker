package rw.ui.game.walker.stages;

import flixel.addons.display.FlxBackdrop;
import flixel.FlxG;

class StageChinatown extends WalkerStage
{
	override public function new()
	{
		super('chinatown');
	}

	var sky:FlxBackdrop;
	var town:WalkerStageSprite;

	override function build()
	{
		super.build();

		sky = new FlxBackdrop(Paths.getImagePath('game/walker/stages/chinatown/town/sky'));
		sky.scale.set(2, 2);
		sky.updateHitbox();
		sky.camera = game.camGame;

		sky.velocity.x = 2;
		sky.screenCenter();
		game.back.add(sky);

		game.back.add(town = new WalkerStageSprite('chinatown/town/town').scaleToScreen());
	}

	override function destroy()
	{
		super.destroy();

		sky.destroy();
		town.destroy();

		sky = null;
		town = null;
	}
}
