package rw.ui.game.stages;

import flixel.tweens.FlxTween;
import flixel.FlxG;
import rw.util.CustomShader;

class StageCrashLanding extends Stage
{
	override public function new()
	{
		super('crash landing');
	}

	override function build()
	{
		super.build();

		game.camGame.bgColor = 0xFF0D0712;

		var ship = new StageSprite('$stage/ship');
		var mountains = new StageSprite('$stage/mountains');
		var hills = new StageSprite('$stage/hills');
		var ground = new StageSprite('$stage/ground');
		var frontHills = new StageSprite('$stage/frontHills');

		ship.setScrollFactor(0.05);
		mountains.setScrollFactor(0.1);
		hills.setScrollFactor(0.25);
		ground.setScrollFactor(0.75);
		frontHills.setScrollFactor(0.9);

		for (spr in [ship, mountains, hills, ground, frontHills])
		{
			spr.setGraphicSize(FlxG.width, FlxG.height);
			spr.updateHitbox();
			spr.screenCenter();

			spr.setCamera(game.camGame);

			if (spr != frontHills) game.stageBackLayer.add(spr);
		}
		game.stageFrontLayer.add(frontHills);

		ship.setScale(Math.floor(FlxG.width / 1280));
		ship.alpha = .5;

		ship.x += FlxG.width * 2;
		ship.y += -FlxG.height * 2;

		FlxTween.tween(ship, {x: -FlxG.width * 2, y: FlxG.height * 2}, 6, {
			onComplete: t ->
			{
				game.stageBackLayer.remove(ship);
				ship.destroy();
			}
		});

		game.player.setScale(1.5);
		game.player.screenCenter();
		game.player.y = FlxG.height - game.player.height * 1.3;

		game.data.beatMonsters.scale = 0.75;

		var charShader = new CustomShader('dropshadow');

		charShader.setFloat('hue', -9.0);
		charShader.setFloat('saturation', -15.0);
		charShader.setFloat('brightness', -22.0);
		charShader.setFloat('contrast', 0.0);

		game.player.shader = game.beatMonsters.shader = charShader;
	}
}
