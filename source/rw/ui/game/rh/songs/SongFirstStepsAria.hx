package rw.ui.game.rh.songs;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import rw.save.Save;
import rw.util.mobile.TouchUtil;
import flixel.FlxG;
import rw.ui.game.rh.songs.first_steps_aria.FirstStepsAriaLCRSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import rw.ui.game.song.SongEventData;

using StringTools;

class SongFirstStepsAria extends RHSong
{
	override public function new()
	{
		super('first steps', aria);
	}

	var bro:FirstStepsAriaLCRSprite;
	var broPoint:String = 'center';

	var tutorial:FirstStepsAriaLCRSprite;

	var lazers:FlxTypedSpriteGroup<FirstStepsAriaLCRSprite>;

	override function build()
	{
		super.build();

		game.camGame.bgColor = 0xFF222034;

		game.back.add(new RHSprite('first-steps-aria/stage').scaleToScreen().setCamera(game.camGame));

		game.gameplayElements.add(bro = new FirstStepsAriaLCRSprite('bro').setCamera(game.camGame));
		bro.addAnim('center-hit', [3]);
		bro.addAnim('left-hit', [4]);
		bro.addAnim('right-hit', [5]);

		game.gameplayElements.add(lazers = new FlxTypedSpriteGroup<FirstStepsAriaLCRSprite>());

		if (Save.scores.exists(game.songData.toString())) return;

		game.gameplayElements.add(tutorial = new FirstStepsAriaLCRSprite('tutorial').setCamera(game.camGame));
		tutorial.visible = false;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (TouchUtil.mouse.justPressed) controls();
	}

	function controls()
	{
		if (TouchUtil.mouse.x < (FlxG.width / 2))
		{
			moveTo('left', 'center');
			moveTo('center', 'right');
		}

		if (TouchUtil.mouse.x > (FlxG.width / 2))
		{
			moveTo('right', 'center');
			moveTo('center', 'left');
		}
	}

	function moveTo(point:String, ifPoint:String)
	{
		if (broPoint != ifPoint) return;

		broPoint = point;
		bro.playAnim(point);
	}

	override function onEvent(event:SongEventRawData)
	{
		super.onEvent(event);

		switch (event.id.toLowerCase())
		{
			case 'lazerseg':
				if (event.data == null || event.data.delay == null || event.data.side == null) return;

				var warning = new FirstStepsAriaLCRSprite('warnings').setCamera(game.camGame);
				lazers.add(warning);

				var lazer = new FirstStepsAriaLCRSprite('shots').setCamera(game.camGame);
				lazers.add(lazer);

				warning.playAnim(event.data.side);

				lazer.alpha = warning.alpha = 0;

				var time = Std.parseFloat('${event.data.delay}') / 1000;

				FlxTween.tween(warning, {alpha: 1}, time, {
					ease: FlxEase.sineIn,
					onComplete: t ->
					{
						lazers.remove(warning);

						warning.destroy();
						warning = null;
					}
				});

				if (tutorial != null) FlxTween.tween(tutorial, {alpha: 1}, time * 0.75, {
					ease: FlxEase.sineIn,
					onComplete: t ->
					{
						if (tutorial == null) return;

						tutorial.visible = true;
						tutorial.playAnim(event.data.side);
					}
				});

				FlxTimer.wait(time, () ->
				{
					lazer.playAnim(event.data.side);
					lazer.alpha = 1;

					var dodged = broPoint != event.data.side;
					game.applyScore(dodged);

					if (!dodged) bro.playAnim('$broPoint-hit');

					FlxTween.tween(lazer, {alpha: 0}, ((game.conductor.stepLengthMs / 1000) * 2), {
						ease: FlxEase.sineIn,
						onComplete: t ->
						{
							lazers.remove(lazer);

							lazer.destroy();
							lazer = null;
						}
					});

					if (tutorial == null) return;

					game.gameplayElements.remove(tutorial);
					tutorial.destroy();
					tutorial = null;
				});
		}
	}
}
