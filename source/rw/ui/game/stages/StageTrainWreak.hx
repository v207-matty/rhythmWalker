package rw.ui.game.stages;

import rw.ui.game.stages.train_wreak.*;
import rw.ui.game.song.SongEventData;
import rw.ui.objects.Floor;
import flixel.addons.display.FlxBackdrop;
import flixel.FlxG;

using StringTools;

class StageTrainWreak extends Stage
{
	override public function new()
	{
		super('train-wreak');
	}

	var trainWreak_shooter:TrainWreakShooter;

	override function build()
	{
		super.build();

		var sky:FlxBackdrop = new FlxBackdrop(Paths.getImagePath('game/stages/$stage/sky'));
		sky.scale.set(2, 2);
		sky.updateHitbox();
		sky.velocity.x = 10;
		sky.screenCenter(X);
		sky.scrollFactor.set(.25, .25);
		game.stageBackLayer.add(sky);
		sky.camera = game.camGame;

		var city:FlxBackdrop = new FlxBackdrop(Paths.getImagePath('game/stages/$stage/city'), X);
		city.scale.set(2, 2);
		city.updateHitbox();
		city.screenCenter(X);
		city.scrollFactor.set(.5, .5);
		game.stageBackLayer.add(city);
		city.camera = game.camGame;

		var ground:FlxBackdrop = new FlxBackdrop(Paths.getImagePath('game/stages/$stage/ground'), X);
		ground.scale.set(2, 2);
		ground.updateHitbox();
		ground.screenCenter(X);
		ground.scrollFactor.set(.75, .75);
		ground.camera = game.camGame;

		game.stageBackLayer.add(new Floor(ground, 0xFF3B3E44, game.camGame));
		game.stageBackLayer.add(ground);

		var pieceList:Array<Dynamic> = [
			['crowds/randoms-left', 0.75],
			['crowds/randoms-right', 0.75],

			['crowds/center', 0.8],

			['smoke', 1],
			['trainSegment', 1],
			['trainGround', 1],
		];

		for (piece in pieceList)
		{
			var isRandom:Bool = Std.string(piece[0]).startsWith('crowds/randoms-');
			var isCrowd:Bool = Std.string(piece[0]).startsWith('crowds/');

			var pspr = new TrainWreakPiece(piece[0], game.camGame, piece[1]);
			game.stageBackLayer.add(pspr);

			if (isCrowd)
			{
				pspr.setScale(1.75);
				pspr.screenCenter();
			}

			if (isRandom)
			{
				pspr.x -= pspr.width * (0.5 * ((Std.string(piece[0]).endsWith('left')) ? 1 : -1.25));
				continue;
			}

			if (piece[0] == 'smoke')
			{
				pspr.blend = OVERLAY;
				pspr.alpha = 0.5;
			}
		}

		trainWreak_shooter = new TrainWreakShooter(game.camGame);
		trainWreak_shooter.screenCenter();
		trainWreak_shooter.x -= trainWreak_shooter.width * 0.25;
		trainWreak_shooter.y -= trainWreak_shooter.width * 0.5;
		game.stageBackLayer.add(trainWreak_shooter);

		game.player.screenCenter();
		game.player.y = FlxG.height - game.player.height * 1.15;
	}

	override function onEvent(event:SongEventData)
	{
		super.onEvent(event);

		switch (event.id.toLowerCase())
		{
			case 'trainwreak-gun': trainWreak_shooter.animation.play('shoot', true);
		}
	}
}
