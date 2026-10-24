package rw.ui.game.walker.stages;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import rw.ui.game.song.SongEventData;
import flixel.math.FlxPoint;
import rw.ui.objects.Floor;
import flixel.FlxG;
import flixel.addons.display.FlxBackdrop;

class StageContainment04 extends Stage
{
	override public function new()
	{
		super('containment-04');
	}

	var containment04_tubeSubject:StageSprite;

	override function build()
	{
		super.build();

		game.camGame.bgColor = 0xFF595652;

		var floor:FlxBackdrop = new FlxBackdrop(Paths.getImagePath('game/walker/stages/$stage/floor'), X);
		floor.scale.set(2, 2);
		floor.scrollFactor.set();
		floor.updateHitbox();
		floor.camera = game.camGame;
		floor.y = FlxG.height - floor.height;

		game.stageBackLayer.add(new Floor(floor, 0xFF696A6A, game.camGame, FlxPoint.weak(1, 0)));
		game.stageBackLayer.add(floor);

		var label = new StageSprite('$stage/label');
		label.setScale(2);
		label.screenCenter(X);
		label.y = FlxG.height - label.height;
		game.stageBackLayer.add(label);

		var tubes = 2 * Math.round(FlxG.width / 1280);

		for (i in 0...tubes)
		{
			var tube = new StageSprite('$stage/tube');
			tube.setScale(2);

			tube.y = FlxG.height - tube.height * 1.4 - 4;
			tube.x = ((tube.width * 2.75) * i) + 32;

			game.stageBackLayer.add(tube);

			if (i != tubes - 1) continue;

			containment04_tubeSubject = tube;
			containment04_tubeSubject.loadGraphic(Paths.getImagePath('game/walker/stages/$stage/subject'), true, 128, 128);
			containment04_tubeSubject.addAnim('idle', [0, 1], 2, true);
			containment04_tubeSubject.addAnim('bang', [2, 3], 6, false);
			containment04_tubeSubject.animation.play('idle');
		}
	}

	override function onEvent(event:SongEventRawData)
	{
		super.onEvent(event);

		switch (event.id.toLowerCase())
		{
			case 'encapture-subjectbang':
				containment04_tubeSubject.animation.play('bang');

				if (game.inEndCutscene) return;

				game.camGame.followLerp *= 0.1;
				game.camGameFollow.setPosition(containment04_tubeSubject.getGraphicMidpoint().x, containment04_tubeSubject.getGraphicMidpoint().y);

				FlxTween.tween(game.camGame, {zoom: 1.5}, (FlxG.sound.music.length - FlxG.sound.music.time) / 1000, {
					ease: FlxEase.quartOut,
				});

				game.inEndCutscene = true;
		}
	}
}
