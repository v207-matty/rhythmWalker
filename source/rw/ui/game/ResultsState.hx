package rw.ui.game;

import rw.util.Constants;
import rw.ui.objects.RWSprite;
import rw.ui.menu.freeplay.Freeplay;
import rw.ui.menu.MainMenu;
import flixel.util.FlxTimer;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import rw.ui.game.song.SongRank;

class ResultsState extends ConductorState
{
	var songScore:Int;
	var songRank:SongRank;
	var songRankPercent:Float;

	var windupScore:Float = 0;
	var windupText:FlxText;

	var windupDone = false;

	var leaveTimer:FlxTimer;

	override public function new(songCode:String)
	{
		super();

		var score = Save.scores.get(songCode);

		songScore = score?.score ?? 0;
		songRank = score?.rank ?? NONE;
		songRankPercent = score?.percent ?? 0;
	}

	override function create()
	{
		transIn = null;

		super.create();

		beginResults();
	}

	function beginResults()
	{
		windupText = new FlxText(0, 0, 0, '', Constants.TEXT_SIZE * 2);
		add(windupText);
		windupText.color = FlxColor.WHITE;

		windupText.alignment = CENTER;

		FlxG.sound.play(Paths.getAudio('ui/results/results'));

		FlxTween.num(0, songScore, 4, {
			ease: FlxEase.quintInOut,
			onComplete: t ->
			{
				FlxTimer.wait(.5, () ->
				{
					FlxG.camera.flash(FlxColor.WHITE, 1);
					onWindupDone();
				});
			}
		}, v ->
		{
			final prev = Math.floor(windupScore);

			windupScore = v;

			if (Math.floor(windupScore) != prev) FlxG.sound.play(Paths.getAudio('ui/results/resultsTick'), 0.2);

			windupText.text = 'Score:\n${Math.floor(windupScore)}';
			windupText.screenCenter();
		});
	}

	function onWindupDone()
	{
		FlxG.sound.play(Paths.getAudio('ui/results/resultsTickDone'));

		windupText.size *= 2;
		windupText.screenCenter();
		windupText.x -= windupText.width * 1.25;

		var were:Bool = (songRank != BAD);

		var didWere = new RWSprite('ui/results/${(were) ? 'were' : 'did'}');
		add(didWere);
		didWere.setScale(2);
		didWere.screenCenter();

		var rank = new RWSprite('ui/results/ranks/$songRank');
		add(rank);
		rank.setScale(2);
		rank.screenCenter();

		windupDone = true;

		leaveTimer = new FlxTimer().start(2, t ->
		{
			leave(true);
		});

		#if MOBILE_MODE
		var leaveButton = new rw.ui.objects.mobile.CornerButton('backBtn');
		add(leaveButton);
		leaveButton.x = FlxG.width - leaveButton.width;
		leaveButton.onClicked.add(() -> leave(true));
		#end
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!leaveTimer?.finished && FlxG.keys.anyJustPressed([ENTER, ESCAPE])) leave();
	}

	function leave(forced = false)
	{
		if (!windupDone) return;
		if (!leaveTimer?.finished) leaveTimer.cancel();

		FlxG.switchState(() -> new MainMenu(true));
	}
}
