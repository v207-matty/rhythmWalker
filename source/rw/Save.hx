package rw;

import rw.ui.game.song.SongScore;
import flixel.util.FlxSave;
import flixel.math.FlxMath;
import lime.app.Application;
import flixel.FlxG;
import rw.ui.game.song.SongRank;

using StringTools;

typedef SaveData =
{
	?scores:Map<String, SongScore>,
}

class Save
{
	public static var scores:Map<String, SongScore> = [];

	public static var game(get, set):SaveData;

	static function get_game():SaveData return FlxG.save.data.game;

	static function set_game(value:SaveData):SaveData return FlxG.save.data.game = value;

	public static function init()
	{
		FlxG.save.bind('RhythmWalker', '.Matty');

		load();

		Application.current.onExit.add(function(l)
		{
			save();
		});
	}

	public static function load()
	{
		game ??= {};

		game.scores ??= [];

		#if !(SAVE_CLEAR || clear)
		scores = game.scores;
		#end

		trace(game);
	}

	public static function save()
	{
		game = {
			scores: game.scores
		};

		FlxG.save.flush();

		trace(game);
	}

	public static function saveSongScore(id:String, score:Int, totalScore:Int)
	{
		var song = scores.get(id);
		var songScore:Int = song?.score ?? 0;
		var songRank:SongRank = song?.rank ?? NONE;
		var songRankPercent:Float = song?.percent ?? 0;

		var newHS:Bool = false;

		if (score > songScore)
		{
			trace('NEW HIGHSCORE FOR "$id": $score');
			trace(' | $score / $totalScore');

			songScore = score;

			songRankPercent = FlxMath.roundDecimal(score / totalScore, 2);
			songRank = SongRank.getRankFromPercent(songRankPercent);

			newHS = true;
		}

		if (songRank == NONE) songRank = BAD;

		scores.set(id, {
			percent: FlxMath.roundDecimal(songRankPercent, 2),
			rank: songRank,
			score: songScore,
		});

		return newHS;
	}
}
