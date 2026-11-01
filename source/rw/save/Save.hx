package rw.save;

import rw.ui.game.PlayData.PlayModeData;
import haxe.Json;
import flixel.util.FlxSave;
import flixel.math.FlxMath;
import lime.app.Application;
import flixel.FlxG;
import rw.ui.game.song.SongRank;

using StringTools;

class Save
{
	public static final LATEST_VERSION:Null<Int> = 1;
	public static final LATEST_VERSION_SONG:Null<Int> = 0;

	public static var version:Null<Int>;
	public static var scores:Map<String, SaveSongScore> = [];
	public static var options:SaveOptionsData = {};
	public static var gamejoly:SaveGameJoltData = {};

	public static var game(get, set):SaveData;

	static function get_game():SaveData return FlxG.save.data.game;

	static function set_game(value:SaveData):SaveData return FlxG.save.data.game = value;

	public static function init()
	{
		FlxG.save.bind('RhythmWalker', '.Matty');

		load();

		Application.current.onExit.add((l) -> save());
	}

	public static function load()
	{
		initData();

		#if !(SAVE_CLEAR || clear)
		forceLoad();
		#end
	}

	public static function forceLoad()
	{
		version = game.version;
		scores = game.scores;
		options = game.options;
		gamejoly = game.gamejoly;

		saveConvert();

		trace(game);
	}

	static function saveConvert()
	{
		for (song => score in scores) if (score.version == null || score.version <= LATEST_VERSION_SONG) score.version = -1;

		version = LATEST_VERSION;
	}

	public static function clear()
	{
		game = null;

		init();
		forceLoad();
	}

	public static function initData()
	{
		game ??= {
			version: null,
		};

		game.version ??= null;
		game.scores ??= [];
		game.options ??= {};
		game.gamejoly ??= {};

		game.options.shaders ??= true;
		game.options.qualityWarning ??= true;
		game.options.menuMusic ??= true;
		game.options.dialogue ??= true;

		game.gamejoly.username ??= null;
		game.gamejoly.user_token ??= null;
	}

	public static function save()
	{
		game = {
			version: LATEST_VERSION,
			scores: scores,
			options: options,
			gamejoly: gamejoly,
		};

		FlxG.save.flush();
	}

	public static function saveSongScore(id:String, score:Int, totalScore:Int, mode:PlayModeData)
	{
		var song = scores.get(id);

		var songScore:Int = song?.score ?? 0;
		var songRank:SongRank = song?.rank ?? NONE;
		var songRankPercent:Float = song?.percent ?? 0;
		var songVersion = song?.version ?? null;
		var songMode:PlayModeData = song?.mode ?? null;

		var newHS:Bool = false;

		trace('saved score: $songScore', 'current score : $score', 'total score: $totalScore');

		final newPercent = FlxMath.roundDecimal(score / totalScore, 2);

		if (newPercent > songRankPercent || score > songScore || songVersion != LATEST_VERSION_SONG || songMode != mode)
		{
			trace('NEW HIGHSCORE FOR "$id": $score');
			trace(' | $score / $totalScore');

			songScore = score;
			songRankPercent = newPercent;
			songRank = SongRank.getRankFromPercent(songRankPercent);

			newHS = true;
		}

		if (songRank == NONE) songRank = BAD;

		scores.set(id, {
			percent: FlxMath.roundDecimal(songRankPercent, 2),
			rank: songRank,
			score: songScore,
			version: LATEST_VERSION_SONG,
			mode: mode
		});

		save();

		return newHS;
	}
}
