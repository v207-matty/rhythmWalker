import ui.objects.RWSprite;
import ui.freeplay.Freeplay;
import flixel.util.FlxTimer;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import song.SongRank;

class ResultsState extends ConductorState
{
	var songScore:Int;
	var songRank:SongRank;
	var songRankPercent:Float;

	override public function new(songCode:String)
	{
		super();

		var score = Save.scores.get(songCode);

		songScore = score?.score ?? 0;
		songRank = score?.rank ?? NONE;
		songRankPercent = score?.percent ?? 0;
	}

	var windupScore:Float = 0;
	var windupText:FlxText;

	override function create()
	{
		super.create();

		windupText = new FlxText(0, 0, 0, '', 32);
		add(windupText);

		windupText.alignment = CENTER;
		windupText.screenCenter();

		FlxG.sound.play(Paths.getAudio('game/results/results'));

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

			if (Math.floor(windupScore) != prev)
				FlxG.sound.play(Paths.getAudio('game/results/resultsTick'), 0.2);

			windupText.text = 'Score:\n${Math.floor(windupScore)}';
			windupText.screenCenter();
		});
	}

	function onWindupDone()
	{
		FlxG.sound.play(Paths.getAudio('game/results/resultsTickDone'));

		windupText.size *= 2;
		windupText.screenCenter();
		windupText.x -= windupText.width * 1.25;

		var were:Bool = (songRank != BAD);

		var didWere = new RWSprite('game/results/${(were) ? 'were' : 'did'}');
		add(didWere);
		didWere.setScale(2);
		didWere.screenCenter();

		var rank = new RWSprite('game/results/ranks/$songRank');
		add(rank);
		rank.setScale(2);
		rank.screenCenter();

		windupDone = true;

		leaveTimer = new FlxTimer().start(2, t ->
		{
			leave();
		});
	}

	var windupDone = false;

	var leaveTimer:FlxTimer;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (windupDone && !leaveTimer.finished && FlxG.keys.anyJustPressed([ENTER, ESCAPE]))
		{
			leaveTimer.cancel();
			leave();
		}
	}

	function leave()
	{
		FlxG.switchState(() -> new Freeplay());
	}
}
