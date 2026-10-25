package rw.ui.game.walker.stages;

import lime.tools.SplashScreen;
import rw.save.Save;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import rw.util.CustomShader;

class StageCrashLanding extends WalkerStage
{
	override public function new()
	{
		super('crash landing');
	}

	var ship:WalkerStageSprite;

	override function build()
	{
		super.build();

		game.camGame.bgColor = 0xFF0D0712;

		game.back.add(ship = new WalkerStageSprite('$stage/ship').setScrollFactor(0.05).scaleToScreen().setCamera(game.camGame));
		game.back.add(new WalkerStageSprite('$stage/mountains').setScrollFactor(0.1).scaleToScreen().setCamera(game.camGame));
		game.back.add(new WalkerStageSprite('$stage/hills').setScrollFactor(0.1).scaleToScreen().setCamera(game.camGame));
		game.back.add(new WalkerStageSprite('$stage/ground').setScrollFactor(0.75).scaleToScreen().setCamera(game.camGame));
		game.front.add(new WalkerStageSprite('$stage/frontHills').setScrollFactor(0.9).scaleToScreen().setCamera(game.camGame));

		ship.setScale(Math.floor(FlxG.width / 1280));
		ship.alpha = .5;

		ship.x += FlxG.width * 2;
		ship.y += -FlxG.height * 2;

		FlxTween.tween(ship, {x: -FlxG.width * 2, y: FlxG.height * 2}, 6, {
			onComplete: t ->
			{
				game.back.remove(ship);
				ship.destroy();
				ship = null;
			}
		});

		game.player.setScale(1.5);
		game.player.screenCenter();
		game.player.y = FlxG.height - game.player.height * 1.3;

		game.data.beatMonsters.scale = 0.75;

		if (!Save.options.shaders) return;

		var charShader = new CustomShader('dropshadow');

		charShader.setFloat('hue', -9.0);
		charShader.setFloat('saturation', -15.0);
		charShader.setFloat('brightness', -22.0);
		charShader.setFloat('contrast', 0.0);

		game.player.shader = game.beatMonsters.shader = charShader;
	}
}
