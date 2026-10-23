package rw.ui.menu.freeplay;

import rw.util.TouchUtil;
import flixel.group.FlxSpriteGroup;
import rw.util.Constants;
import flixel.math.FlxMath;
import rw.ui.objects.RWSprite;
import flixel.util.FlxSort;
import openfl.media.Sound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.sound.FlxSound;
import rw.ui.game.song.SongData;
import rw.ui.game.dialogue.DialogueScene;
import rw.ui.game.song.SongRank;
import haxe.Json;
import flixel.FlxSprite;
import lime.utils.Assets;
import flixel.FlxObject;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
#if FREEPLAY_VISUALIZER
import flixel.addons.display.waveform.FlxWaveform;
import flixel.addons.display.waveform.FlxWaveformBuffer;
#end

using StringTools;

class Freeplay extends ConductorState
{
	public static var songList:FreeplaySongListData;

	public static var songs(get, never):Array<FreeplaySongData>;

	static function get_songs():Array<FreeplaySongData> return songList.songs;

	public static var tips:Array<String> = ['No tips'];

	public static var filterList(get, never):Array<String>;

	static function get_filterList():Array<String>
	{
		var list:Array<String> = [];

		for (filter in songList?.filters) if (!list.contains(filter.toLowerCase())) if (songs.filter(s -> return s.filters.contains(filter.toLowerCase()))
			.length > 0) list.push(filter.toLowerCase());
		for (song in songs) for (filter in song?.filters) if (!list.contains(filter.toLowerCase())) list.push(filter.toLowerCase());

		list.insert(0, 'all');

		return list;
	}

	static var audioCache:Map<String, Sound> = [];

	var randomTip:String = '';

	var entries:Array<FreeplaySongData> = [];

	var texts:FlxTypedSpriteGroup<FlxText>;

	var selectedVolume = 0;
	var selectedEntry = 0;

	var camFollow:FlxObject;

	var topSegBG:RWSprite;
	var topSegText:FlxText;

	var btmSegBG:RWSprite;
	var btmSegText:FlxText;

	var waveformLayer:FlxSpriteGroup;

	public var songCode(get, never):String;

	function get_songCode():String
	{
		var sng = entries[selectedEntry];
		if (sng == null) return null;
		return '${sng.song.toLowerCase()}-${(sng.variation ?? defaultVariation).toString().toLowerCase()}';
	}

	override function create()
	{
		super.create();

		trace('filters: ${filterList}');

		persistentUpdate = true;

		randomTip = tips[FlxG.random.int(0, tips.length - 1)].replace('\\n', '\n');

		texts = new FlxTypedSpriteGroup<FlxText>();
		add(texts);

		camFollow = new FlxObject();
		add(camFollow);

		camFollow.x = (FlxG.width / 2);

		FlxG.camera.follow(camFollow, LOCKON, .1);

		topSegText = new FlxText(0, 0, 0, 'Score & Rank go here', Constants.TEXT_SIZE);
		topSegText.alignment = CENTER;
		topSegText.scrollFactor.set();

		topSegBG = new RWSprite(null);
		topSegBG.makeGraphic(1, 1, FlxColor.BLACK);
		topSegBG.scrollFactor.set();

		add(topSegBG);
		add(topSegText);

		btmSegText = new FlxText(0, 0, 0, '', Constants.TEXT_SIZE * 2);
		btmSegText.alignment = CENTER;
		btmSegText.scrollFactor.set();

		btmSegBG = new RWSprite(null);
		btmSegBG.makeGraphic(1, 1, FlxColor.BLACK);
		btmSegBG.scrollFactor.set();

		add(btmSegBG);
		add(btmSegText);

		add(waveformLayer = new FlxSpriteGroup());

		changeVolume(filterList.length);
		changeSel(0);
		filter('all');

		#if MOBILE_MODE
		var playButton = new rw.ui.objects.mobile.CornerButton('playBtn');

		playButton.y = FlxG.height - playButton.height;
		playButton.x = FlxG.width - playButton.width;

		playButton.setScrollFactor(0);

		playButton.back.angle = 90;
		playButton.offsetBy(-16 * playButton.scale.x, -64 * playButton.scale.y);

		playButton.onClicked.add(proceed);

		add(playButton);
		#end

		if (transIn == null) finishTransIn();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (subState == null) controls();

		FlxG.watch.addQuick('songCode', songCode);
	}

	function controls()
	{
		if (FlxG.keys.anyJustPressed([W, UP]) || TouchUtil.swippedUp()) changeSel(-1);
		if (FlxG.keys.anyJustPressed([S, DOWN]) || TouchUtil.swippedDown()) changeSel(1);

		if (FlxG.keys.anyJustPressed([A, LEFT]) || TouchUtil.swippedLeft()) changeVolume(-1);
		if (FlxG.keys.anyJustPressed([D, RIGHT]) || TouchUtil.swippedRight()) changeVolume(1);

		if (FlxG.keys.justPressed.ENTER) proceed();
	}

	function proceed()
	{
		FlxG.sound.play(Paths.getAudio('sfx/menu/confirm'));

		var song = {
			song: songCode.substr(0, songCode.lastIndexOf('-')),
			variation: songCode.substr(songCode.lastIndexOf('-') + 1),
		}
		trace(song);

		DialogueScene.seenIntroCutscene = false;
		FlxG.switchState(() -> new DialogueScene(new SongData(song.song, song.variation)));
	}

	function changeSel(amount:Float)
	{
		var prevSel = selectedEntry;

		selectedEntry += Math.round(amount);

		if (selectedEntry < 0) selectedEntry = entries.length - 1;
		if (selectedEntry > entries.length - 1) selectedEntry = 0;

		var score = Save.scores.get(songCode);
		var curSongScore:Int = score?.score ?? 0;
		var curSongRank:SongRank = score?.rank ?? NONE;
		var curSongRankPercent:Float = score?.percent ?? 0;

		for (i => text in texts.members)
		{
			final code = '${entries[i].song}-${(entries[i].variation ?? defaultVariation)}'.toLowerCase();
			var textSongRank:SongRank = Save.scores.get(code)?.rank ?? NONE;

			text.color = #if FREEPLAY_DISPLAY_SCORE (textSongRank == NONE) ? FlxColor.RED : #end
			FlxColor.WHITE;

			if (i != selectedEntry) continue;

			text.color = #if FREEPLAY_DISPLAY_SCORE (textSongRank == NONE) ? FlxColor.ORANGE : #end
			FlxColor.YELLOW;
			camFollow.y = text.y;
		}

		topSegText.text = '';

		#if FREEPLAY_DISPLAY_SCORE
		topSegText.text += 'Score: ${curSongScore}';
		topSegText.text += ' | ';
		topSegText.text += 'Rank: ${curSongRank} (${Math.floor(curSongRankPercent * 100)}%)';
		topSegText.text += '\n\n';
		#end

		topSegText.text += 'Random Tip:\n$randomTip';

		topSegText.updateHitbox();
		topSegText.screenCenter(X);

		topSegBG.setScale(FlxG.width, topSegText.height);
		topSegBG.setPosition(0, topSegText.y);

		if (selectedEntry == prevSel) return;

		FlxG.sound.play(Paths.getAudio('sfx/menu/scroll'));
	}

	function changeVolume(amount:Int)
	{
		var prevVol = selectedVolume;

		selectedVolume += amount;

		if (selectedVolume < 0) selectedVolume = filterList.length - 1;
		if (selectedVolume > filterList.length - 1) selectedVolume = 0;

		btmSegText.text = 'Volume: ${filterList[selectedVolume]?.toUpperCase()}';
		btmSegText.screenCenter(X);
		btmSegText.y = FlxG.height - btmSegText.height;

		btmSegBG.setScale(FlxG.width, btmSegText.height);
		btmSegBG.setPosition(0, btmSegText.y);

		if (selectedVolume == prevVol) return;

		FlxG.sound.play(Paths.getAudio('sfx/menu/scroll'));

		filter(filterList[selectedVolume]);
	}

	function filter(f:String)
	{
		entries = songs.filter(s -> return s.filters.contains(f.toLowerCase()));
		if (entries.length < 1) entries = songs;

		if (texts.members.length > 0)
		{
			for (text in texts)
			{
				texts.remove(text);
				text.destroy();
			}

			texts.clear();
		}

		for (i => song in entries)
		{
			if (song.variation == null) song.variation = defaultVariation;

			var tXt:FlxText = new FlxText(0, i * Constants.TEXT_SIZE * 4, 0, '${song.song}', Constants.TEXT_SIZE * 2);
			var variationStr = song.variation.toString().toLowerCase();
			var curSongRank:SongRank = Save.scores.get('${song.song.toLowerCase()}-${variationStr}')?.rank ?? NONE;

			if (song.variation != defaultVariation) tXt.text += ' (${variationStr.substr(0, 1).toUpperCase()}${variationStr.substr(1)})';
			#if FREEPLAY_DISPLAY_SCORE
			if (curSongRank == NONE) tXt.text += ' (Unplayed)';
			#end

			tXt.screenCenter(X);

			texts.add(tXt);
		}

		changeSel(entries.length);
	}
}
