package rw.ui.game.rh.songs;

import rw.ui.game.rh.songs.first_steps_aria.FirstStepsAriaLCRSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import rw.ui.game.song.SongEventData.SongEventRawData;

class SongFirstStepsAria extends RHSong
{
	override public function new()
	{
		super('first steps', aria);
	}

	var bro:RHSprite;

	var lazers:Array<FirstStepsAriaLCRSprite> = [];

	override function build()
	{
		super.build();

		game.camGame.bgColor = 0xFF222034;

		game.back.add(new RHSprite('first-steps-aria/stage').scaleToScreen().setCamera(game.camGame));

		game.gameplayElements.add(bro = new RHSprite('first-steps-aria/bro', true, 1280, 720).scaleToScreen().setCamera(game.camGame));
		bro.addAnim('center', [0]);
		bro.addAnim('left', [1]);
		bro.addAnim('right', [2]);
	}

	override function onEvent(event:SongEventRawData)
	{
		super.onEvent(event);

		switch (event.id.toLowerCase())
		{
			case 'lazerseg':
				if (event.data == null || event.data.delay == null || event.data.side == null) return;

				var warning = new FirstStepsAriaLCRSprite('warnings').setCamera(game.camGame);
				lazers.push(warning);
				game.gameplayElements.add(warning);
				warning.playAnim(event.data.side);

				var lazer = new FirstStepsAriaLCRSprite('shots').setCamera(game.camGame);
				lazers.push(lazer);
				game.gameplayElements.add(lazer);

				lazer.alpha = 0;
				warning.alpha = 0;

				var time = Std.parseFloat('${event.data.delay}') / 1000;

				// trace('Lazer Seg Time: $time');
				// trace('Lazer Seg Side: ${event.data.side}');

				FlxTween.tween(warning, {alpha: 1}, time, {
					ease: FlxEase.sineIn,
					onComplete: t ->
					{
						game.remove(warning);
						lazers.remove(warning);

						warning.destroy();
						warning = null;
					}
				});

				FlxTimer.wait(time, () ->
				{
					lazer.playAnim(event.data.side);
					lazer.alpha = 1;

					FlxTween.tween(lazer, {alpha: 0}, ((game.conductor.stepLengthMs / 1000) * 2), {
						ease: FlxEase.sineIn,
						onComplete: t ->
						{
							game.remove(lazer);
							lazers.remove(lazer);

							lazer.destroy();
							lazer = null;
						}
					});
				});
		}
	}
}
