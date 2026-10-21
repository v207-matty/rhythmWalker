package ui.game.stages;

import flixel.addons.display.FlxBackdrop;
import flixel.FlxG;

class StageChinatown extends Stage
{
	override public function new()
	{
		super('chinatown');
	}

	override function build()
	{
		super.build();

		var sky:FlxBackdrop = new FlxBackdrop(Paths.getImagePath('game/stages/chinatown/town/sky'));
		sky.scale.set(2, 2);
		sky.updateHitbox();
		sky.camera = game.camGame;

		sky.velocity.x = 2;
		sky.screenCenter();
		game.stageBackLayer.add(sky);

		var spr = new StageSprite('chinatown/town/town');
		spr.setGraphicSize(FlxG.width, FlxG.height);
		spr.updateHitbox();
		spr.screenCenter();
		game.stageBackLayer.add(spr);
	}
}
