package rw.ui.game.stages;

import rw.ui.game.stages.train_getaway.*;
import rw.ui.game.song.SongEventData;
import flixel.tweens.FlxEase;
import flixel.FlxG;
import flixel.addons.display.FlxBackdrop;
import flixel.tweens.FlxTween;

class StageTrainGetaway extends Stage
{
	override public function new()
	{
		super('train-getaway');
	}

	var trainGetaway_i:Float = 1;
	var trainGetaway_sky:FlxBackdrop;
	var trainGetaway_shooter:TrainGetawayShooter;

	override function build()
	{
		super.build();

		trainGetaway_sky = new FlxBackdrop(Paths.getImagePath('game/stages/$stage/sky'));
		trainGetaway_sky.scale.set(2, 2);
		trainGetaway_sky.velocity.x = 256 * -5;
		trainGetaway_sky.screenCenter(X);
		game.stageBackLayer.add(trainGetaway_sky);
		trainGetaway_sky.camera = game.camGame;

		var train = new FlxBackdrop(Paths.getImagePath('game/stages/$stage/train'), X);
		train.scale.set(2, 2);
		train.updateHitbox();
		train.screenCenter(X);
		train.y = FlxG.height - train.height;
		game.stageBackLayer.add(train);
		train.camera = game.camGame;

		game.player.setScale(1);
		game.player.screenCenter();
		game.player.y = train.y - game.player.height * 0.95;

		game.data.beatMonsters.scale = 0.5;

		trainGetaway_shooter = new TrainGetawayShooter();
		game.stageBackLayer.add(trainGetaway_shooter);
		trainGetaway_shooter.camera = game.camGame;

		trainGetaway_shooter.screenCenter();
		trainGetaway_shooter.x = trainGetaway_shooter.width * -5;

		FlxTween.tween(trainGetaway_shooter, {x: FlxG.width - trainGetaway_shooter.width}, 2.75, {
			ease: FlxEase.sineInOut
		});
	}

	override function onBeatHit(beat:Int, backward:Bool)
	{
		super.onBeatHit(beat, backward);

		if (trainGetaway_sky != null && FlxG.sound.music.playing)
		{
			trainGetaway_sky.velocity.x -= trainGetaway_i;
			trainGetaway_i += 0.25;
		}
	}

	override function onEvent(event:SongEventRawData)
	{
		super.onEvent(event);

		switch (event.id.toLowerCase())
		{
			case 'traingetaway-reload': trainGetaway_shooter.animation.play('reload', true);

			case 'traingetaway-gunjammed': trainGetaway_shooter.animation.play('jammed', true);

			case 'traingetaway-gun': trainGetaway_shooter.animation.play('shoot${FlxG.random.int(1, 2)}', true);
		}
	}
}
