package ui.freeplay;

import flixel.math.FlxMath;
import ui.objects.RWSprite;
import ui.mobile.CornerButton;
import util.Flag;
import flixel.util.FlxSort;
import openfl.media.Sound;
import flixel.addons.display.waveform.FlxWaveformBuffer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.addons.display.waveform.FlxWaveform;
import flixel.sound.FlxSound;
import song.Song;
import ui.dialogue.DialogueScene;
import song.SongRank;
import haxe.Json;
import flixel.FlxSprite;
import lime.utils.Assets;
import flixel.FlxObject;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

using StringTools;

class Freeplay extends ConductorState
{
	public static var songList:FreeplaySongListData;

	public static var songs(get, never):Array<FreeplaySongData>;

	static function get_songs():Array<FreeplaySongData>
		return songList.songs;

	public static var tips:Array<String> = ['No tips'];

	public static var filterList(get, never):Array<String>;

	static function get_filterList():Array<String>
	{
		var list:Array<String> = [];

		for (filter in songList?.filters)
		{
			if (!list.contains(filter.toLowerCase()))
			{
				if (songs.filter(s -> return s.filters.contains(filter.toLowerCase())).length > 0)
					list.push(filter.toLowerCase());
			}
		}

		for (song in songs)
			for (filter in song?.filters)
				if (!list.contains(filter.toLowerCase()))
					list.push(filter.toLowerCase());

		list.insert(0, 'all');

		return list;
	}

	public static var audioCache:Map<String, Sound> = [];
	public static var audioVizCache:Map<String, FlxWaveform> = [];

	public static var curWaveforms:Array<FlxWaveform> = [];
	public static var curWaveformsID:Array<String> = [];

	public static function runOnWaveforms(func:FlxWaveform->String->Void)
	{
		if (func != null)
			for (wf in curWaveforms)
				func(wf, curWaveformsID[wf.ID]);
	}

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

	var bgAudio:FlxSound;
	var bgAudioVizFade:FlxTween;

	var playButton:CornerButton;

	public var songCode(get, never):String;

	function get_songCode():String
	{
		var sng = entries[selectedEntry];

		if (sng == null)
			return null;

		return '${sng.song.toLowerCase()}-${(sng.variation ?? defaultVariation).toString().toLowerCase()}';
	}

	override function create()
	{
		super.create();

		trace('filters: ${filterList}');

		persistentUpdate = true;

		randomTip = tips[FlxG.random.int(0, tips.length - 1)].replace('\\n', '\n');

		bgAudio = new FlxSound();
		// FlxG.sound.list.add(bgAudio);
		FlxG.sound.onVolumeChange.add(onVolumeChange);
		onVolumeChange(FlxG.sound.volume);

		texts = new FlxTypedSpriteGroup<FlxText>();
		add(texts);

		camFollow = new FlxObject();
		add(camFollow);

		camFollow.x = (FlxG.width / 2);

		FlxG.camera.follow(camFollow, LOCKON, .1);

		topSegText = new FlxText(0, 0, 0, 'Score & Rank go here', 16);
		topSegText.alignment = CENTER;
		topSegText.scrollFactor.set();

		topSegBG = new RWSprite(null);
		topSegBG.makeGraphic(1, 1, FlxColor.BLACK);
		topSegBG.scrollFactor.set();

		add(topSegBG);
		add(topSegText);

		btmSegText = new FlxText(0, 0, 0, '', 32);
		btmSegText.alignment = CENTER;
		btmSegText.scrollFactor.set();

		btmSegBG = new RWSprite(null);
		btmSegBG.makeGraphic(1, 1, FlxColor.BLACK);
		btmSegBG.scrollFactor.set();

		add(btmSegBG);
		add(btmSegText);

		runOnWaveforms((wave, waveID) ->
		{
			wave.alpha = 0;
			add(wave);
		});

		changeVolume(filterList.length);
		changeSel(0);
		filter('all');

		if (Flag.IS_MOBILE_MODE)
		{
			playButton = new CornerButton('playBtn');

			playButton.y = FlxG.height - playButton.height;
			playButton.x = FlxG.width - playButton.width;

			playButton.setScrollFactor(0);

			playButton.back.angle = 90;
			playButton.offsetBy(-8, -32);

			playButton.onClicked.add(proceed);

			add(playButton);
		}

		if (transIn == null)
			finishTransIn();
	}

	override function finishTransIn()
	{
		super.finishTransIn();

		if (Flag.FREEPLAY_BGAUDIO)
			changeBGAudio();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (subState == null)
		{
			for (i => swipe in FlxG.swipes)
			{
				if (swipe.duration < 0.1)
					continue;

				if (i > 0)
					continue;

				if (swipe.distance == 0)
					continue;

				final up = FlxMath.roundDecimal(swipe.degrees / -90, 2);
				final down = FlxMath.roundDecimal(swipe.degrees / 90, 2);

				final left = FlxMath.roundDecimal(swipe.degrees / 180, 2);
				final right = FlxMath.roundDecimal(swipe.degrees / 45, 2);

				trace('dist: ${swipe.distance}', 'deg: ${swipe.degrees}', 'left: $left', 'down: $down', 'up: $up', 'right: $right');

				final range = [0.8, 1.2];

				final range_left_1 = [0.7, 1.5];
				final range_left_2 = [-0.7, -1.5];

				final range_right = [-0.2, 1.2];

				if (up >= range[0] && up <= range[1])
					changeSel(-1);
				else if (down >= range[0] && down <= range[1])
					changeSel(1);
				else if ((left >= range_left_1[0] && left <= range_left_1[1]) || (left <= range_left_2[0] && left >= range_left_2[1]))
					changeVolume(-1);
				else if (right >= range_right[0] && right <= range_right[1])
					changeVolume(1);
			}

			if (FlxG.keys.anyJustPressed([W, UP]))
				changeSel(-1);
			if (FlxG.keys.anyJustPressed([S, DOWN]))
				changeSel(1);

			if (FlxG.keys.anyJustPressed([A, LEFT]))
				changeVolume(-1);
			if (FlxG.keys.anyJustPressed([D, RIGHT]))
				changeVolume(1);

			if (FlxG.keys.justPressed.ENTER)
				proceed();
		}

		if (bgAudio != null && bgAudio.volume > FlxG.sound.volume)
			bgAudio.volume = FlxG.sound.volume;

		FlxG.watch.addQuick('songCode', songCode);
		runOnWaveforms((wave, waveID) ->
		{
			if (wave == null)
				return;
			if (wave.waveformBuffer == null)
				return;

			FlxG.watch.addQuick('waveform-${wave.ID}', waveID);

			if (waveID != songCode)
			{
				wave.active = false;
				return;
			}

			wave.active = true;
			wave.waveformTime += elapsed * 1000;

			if (bgAudio != null && wave.waveformTime > bgAudio.length)
				wave.waveformTime = 0;
		});
	}

	function proceed()
	{
		FlxG.sound.play(Paths.getAudio('sfx/menu/confirm'));

		var song = {
			song: songCode.substr(0, songCode.lastIndexOf('-')),
			variation: songCode.substr(songCode.lastIndexOf('-') + 1),
		}
		trace(song);

		if (bgAudio != null && bgAudio.playing)
			bgAudio.fadeOut(.25, 0, t ->
			{
				FlxG.sound.onVolumeChange.remove(onVolumeChange);

				bgAudio.stop();
				bgAudio.destroy();
				bgAudio = null;
			});

		DialogueScene.seenIntroCutscene = false;
		FlxG.switchState(() -> new DialogueScene(new Song(song.song, song.variation)));
	}

	override function finishTransOut()
	{
		super.finishTransOut();

		runOnWaveforms((wave, waveID) ->
		{
			remove(wave);
			wave.active = false;

			if (!Flag.FREEPLAY_VISUALIZER_MULTICACHE)
			{
				curWaveforms.remove(wave);
				curWaveformsID.remove(waveID);
				wave.destroy();
				wave = null;
			}
		});

		if (Flag.FREEPLAY_VISUALIZER_MULTICACHE && Flag.FREEPLAY_VISUALIZER)
		{
			for (id => waveform in audioVizCache)
			{
				audioVizCache.remove(id);
				waveform.destroy();
				waveform = null;
			}

			audioVizCache.clear();
		}
	}

	function onVolumeChange(vol:Float) @:privateAccess
	{
		if (bgAudio != null)
		{
			if (bgAudio.fadeTween?.active)
				bgAudio.fadeTween.cancel();

			bgAudio.volume = FlxG.sound.volume;
		}

		runOnWaveforms((wave, waveID) ->
		{
			wave.waveformGainMultiplier = FlxG.sound.volume;
		});
	}

	function fadeinVisualizer()
	{
		if (bgAudio?.volume < 0.1 || bgAudio == null || bgAudio.length < 1)
			return;

		runOnWaveforms((wave, waveID) ->
		{
			if (waveID == songCode)
			{
				wave.waveformTime = bgAudio.time;

				FlxTween.cancelTweensOf(wave);
				FlxTween.tween(wave, {alpha: 1}, .25, {ease: FlxEase.quartInOut});
			}
		});
	}

	override function onFocusLost()
	{
		super.onFocusLost();

		if (bgAudio != null)
			bgAudio.pause();
	}

	override function onFocus()
	{
		super.onFocus();

		if (bgAudio != null)
		{
			bgAudio.resume();
			// trace(bgAudio.time);

			runOnWaveforms((wave, waveID) ->
			{
				if (wave != null)
					wave.waveformTime = bgAudio.time;
			});
		}
	}

	function loadSongAudio() @:privateAccess
	{
		if (bgAudio != null)
			bgAudio.stop();
		else
			return;

		if (entries[selectedEntry] == null)
			return;

		if (!audioCache.exists(songCode))
		{
			bgAudio.load(Paths.getSong(entries[selectedEntry].song, entries[selectedEntry]?.variation ?? defaultVariation));
			audioCache.set(songCode, bgAudio._sound);
		}
		else
			bgAudio.load(audioCache.get(songCode));
		bgAudio.looped = true;

		if (!Flag.FREEPLAY_VISUALIZER_MULTICACHE)
		{
			runOnWaveforms((wave, waveID) ->
			{
				curWaveforms.remove(wave);
				curWaveformsID.remove(waveID);
				remove(wave);
				wave.destroy();
			});

			makeWaveform(entries[selectedEntry]);
		}

		bgAudio.play();

		fadeinVisualizer();
		bgAudio.fadeIn(.25, bgAudio.volume, FlxG.sound.volume);
	}

	function changeSel(amount:Float)
	{
		var prevSel = selectedEntry;

		selectedEntry += Math.round(amount);

		if (selectedEntry < 0)
			selectedEntry = entries.length - 1;
		if (selectedEntry > entries.length - 1)
			selectedEntry = 0;

		var score = Save.scores.get(songCode);
		var curSongScore:Int = score?.score ?? 0;
		var curSongRank:SongRank = score?.rank ?? NONE;
		var curSongRankPercent:Float = score?.percent ?? 0;

		for (i => text in texts.members)
		{
			final code = '${entries[i].song}-${(entries[i].variation ?? defaultVariation)}'.toLowerCase();
			var textSongRank:SongRank = Save.scores.get(code)?.rank ?? NONE;

			text.color = (textSongRank == NONE && Flag.FREEPLAY_DISPLAY_SONG_PLAYED) ? FlxColor.RED : FlxColor.WHITE;

			if (i == selectedEntry)
			{
				text.color = (textSongRank == NONE && Flag.FREEPLAY_DISPLAY_SONG_PLAYED) ? FlxColor.ORANGE : FlxColor.YELLOW;
				camFollow.y = text.y;
			}

			if (!Flag.FREEPLAY_VISUALIZER_MULTICACHE && curWaveforms[0] == null)
				text.screenCenter(X);
		}

		topSegText.text = '';

		if (Flag.FREEPLAY_DISPLAY_SONG_SCORE)
		{
			topSegText.text += 'Score: ${curSongScore}';

			if (Flag.FREEPLAY_DISPLAY_SONG_RANK)
				topSegText.text += ' | ';
		}

		if (Flag.FREEPLAY_DISPLAY_SONG_RANK)
			topSegText.text += 'Rank: ${curSongRank} (${Math.floor(curSongRankPercent * 100)}%)';

		if (Flag.FREEPLAY_DISPLAY_TIP)
		{
			if (Flag.FREEPLAY_DISPLAY_SONG_SCORE || Flag.FREEPLAY_DISPLAY_SONG_RANK)
				topSegText.text += '\n\n';

			topSegText.text += 'Random Tip:\n$randomTip';
		}

		topSegText.updateHitbox();
		topSegText.screenCenter(X);

		topSegBG.setScale(FlxG.width, topSegText.height);
		topSegBG.setPosition(0, topSegText.y);

		if (selectedEntry != prevSel || amount == 0)
		{
			FlxG.sound.play(Paths.getAudio('sfx/menu/scroll'));

			if (Flag.FREEPLAY_BGAUDIO)
				changeBGAudio();
		}
	}

	function changeBGAudio()
	{
		if (bgAudio == null || !bgAudio.playing)
		{
			runOnWaveforms((wave, waveID) ->
			{
				wave.alpha = 0;
			});

			loadSongAudio();
		}
		else
		{
			runOnWaveforms((wave, waveID) ->
			{
				FlxTween.cancelTweensOf(wave);
				FlxTween.tween(wave, {alpha: 0}, .25, {ease: FlxEase.quartInOut});
			});

			bgAudio.fadeOut(.25, 0, t ->
			{
				loadSongAudio();
			});
		}
	}

	function changeVolume(amount:Int)
	{
		var prevVol = selectedVolume;

		selectedVolume += amount;

		if (selectedVolume < 0)
			selectedVolume = filterList.length - 1;
		if (selectedVolume > filterList.length - 1)
			selectedVolume = 0;

		btmSegText.text = 'Volume: ${filterList[selectedVolume]?.toUpperCase()}';
		btmSegText.screenCenter(X);
		btmSegText.y = FlxG.height - btmSegText.height;

		btmSegBG.setScale(FlxG.width, btmSegText.height);
		btmSegBG.setPosition(0, btmSegText.y);

		if (selectedVolume != prevVol || amount == 0)
		{
			FlxG.sound.play(Paths.getAudio('sfx/menu/scroll'));

			filter(filterList[selectedVolume]);

			if (Flag.FREEPLAY_BGAUDIO)
				changeBGAudio();
		}
	}

	function filter(f:String)
	{
		entries = [];

		switch (f.toLowerCase())
		{
			case 'all':
				entries = songs;

			default:
				entries = songs.filter(s -> return s.filters.contains(f.toLowerCase()));
		}

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
			if (song.variation == null)
				song.variation = defaultVariation;

			var tXt:FlxText = new FlxText(0, i * 64, 0, '${song.song}', 32);
			var variationStr = song.variation.toString().toLowerCase();
			var curSongRank:SongRank = Save.scores.get('${song.song.toLowerCase()}-${variationStr}')?.rank ?? NONE;

			if (song.variation != defaultVariation)
				tXt.text += ' (${variationStr.substr(0, 1).toUpperCase()}${variationStr.substr(1)})';
			if (curSongRank == NONE && Flag.FREEPLAY_DISPLAY_SONG_PLAYED)
				tXt.text += ' (Unplayed)';

			if (curWaveforms[i] == null && Flag.FREEPLAY_VISUALIZER_MULTICACHE)
				makeWaveform(song, i);

			if (!(Flag.FREEPLAY_VISUALIZER && (curWaveforms[i] != null && Flag.FREEPLAY_VISUALIZER_MULTICACHE)))
				if (Flag.FREEPLAY_CENTER_LAYOUT)
					tXt.screenCenter(X);

			if (Flag.FREEPLAY_LEFT_LAYOUT)
				tXt.alignment = LEFT;
			else if (Flag.FREEPLAY_RIGHT_LAYOUT)
			{
				tXt.alignment = RIGHT;
				tXt.x = FlxG.width - tXt.width;
			}

			texts.add(tXt);
		}

		changeSel(entries.length);
	}

	function makeWaveform(song:FreeplaySongData, ?i:Null<Int>) @:privateAccess
	{
		if (!Flag.FREEPLAY_VISUALIZER)
			return;

		if (i == null)
			i = curWaveforms.length;

		var viz:String = '${song.song.toLowerCase()}-${(song.variation ?? defaultVariation).toString().toLowerCase()}';

		if (curWaveformsID.contains(viz))
		{
			runOnWaveforms((wave, waveID) ->
			{
				if (waveID == viz)
				{
					wave.ID = i;
					curWaveformsID.remove(viz);
					curWaveformsID.insert(i, viz);
					add(wave);
				}
			});

			return;
		}

		var audio:FlxSound;
		if (audioCache.exists(viz))
			audio = new FlxSound().load(audioCache.get(viz));
		else
		{
			audio = new FlxSound().load(Paths.getSong(song.song, song.variation));
			audio.looped = true;

			audioCache.set(viz, audio._sound);
		}

		if (audio == null)
			return;

		var bgAudioViz:FlxWaveform;

		if (audioVizCache.exists(viz) && audioVizCache.get(viz) != null)
		{
			bgAudioViz = audioVizCache.get(viz);
		}
		else
		{
			bgAudioViz = new FlxWaveform(0, 0, Math.floor(FlxG.width / 4), Math.floor(FlxG.height - topSegBG.height - btmSegBG.height), FlxColor.WHITE,
				FlxColor.TRANSPARENT);
			bgAudioViz.scrollFactor.set();
			bgAudioViz.y = topSegBG.height;

			bgAudioViz.loadDataFromFlxSound(audio);

			if (bgAudioViz.waveformBuffer != null)
				bgAudioViz.waveformBuffer.autoDestroy = false;
			bgAudioViz.waveformDuration = 125;

			bgAudioViz.waveformOrientation = VERTICAL;
			bgAudioViz.waveformTime = bgAudio?.time ?? 0;

			bgAudioViz.alpha = 0;

			bgAudioViz.onWaveformBufferSet.add(function()
			{
				audioVizCache.set(viz, bgAudioViz);
			});

			if (Flag.FREEPLAY_LEFT_LAYOUT)
				bgAudioViz.x = FlxG.width - bgAudioViz.width;
		}

		bgAudioViz.ID = i;
		add(bgAudioViz);

		curWaveforms.push(bgAudioViz);
		curWaveformsID.push(viz);
	}
}
