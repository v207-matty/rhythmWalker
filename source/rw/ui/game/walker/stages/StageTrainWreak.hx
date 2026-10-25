package rw.ui.game.walker.stages;

import rw.ui.game.walker.stages.train_wreak.*;
import rw.ui.game.song.SongEventData;
import rw.ui.objects.Floor;
import flixel.addons.display.FlxBackdrop;
import flixel.FlxG;

using StringTools;

class StageTrainWreak extends WalkerStage
{
	override public function new()
	{
		super('train-wreak');
	}

	var trainWreak_shooter:TrainWreakShooter;

	override function build()
	{
		super.build();

		var sky = new FlxBackdrop(Paths.getImagePath('game/walker/stages/$stage/sky'));
		sky.velocity.x = 10;
		sky.scrollFactor.set(.25, .25);
		game.back.add(sky);

		var city = new FlxBackdrop(Paths.getImagePath('game/walker/stages/$stage/city'), X);
		city.scrollFactor.set(.5, .5);
		game.back.add(city);

		var ground = new FlxBackdrop(Paths.getImagePath('game/walker/stages/$stage/ground'), X);
		ground.scrollFactor.set(.75, .75);

		game.back.add(new Floor(ground, 0xFF3B3E44, game.camGame));
		game.back.add(ground);

		for (backdrop in [sky,city,ground])
		{
			backdrop.scale.set(2,2);
			backdrop.updateHitbox();
			backdrop.screenCenter(X);
			backdrop.camera = game.camGame;
		}

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
			game.back.add(pspr);

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
		game.back.add(trainWreak_shooter);

		game.player.screenCenter();
		game.player.y = FlxG.height - game.player.height * 1.15;
	}

	override function onEvent(event:SongEventRawData)
	{
		super.onEvent(event);

		switch (event.id.toLowerCase())
		{
			case 'trainwreak-gun': trainWreak_shooter.animation.play('shoot', true);
		}
	}
}
