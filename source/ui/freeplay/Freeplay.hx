package ui.freeplay;

import flixel.group.FlxSpriteGroup;
import util.Constants;
import flixel.math.FlxMath;
import ui.objects.RWSprite;
import ui.objects.mobile.CornerButton;
import flixel.util.FlxSort;
import openfl.media.Sound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.sound.FlxSound;
import ui.game.song.SongData;
import ui.game.dialogue.DialogueScene;
import ui.game.song.SongRank;
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

		for (filter in songList?.filters)
		{
			if (!list.contains(filter.toLowerCase()))
			{
				if (songs.filter(s -> return s.filters.contains(filter.toLowerCase())).length > 0) list.push(filter.toLowerCase());
			}
		}

		for (song in songs) for (filter in song?.filters) if (!list.contains(filter.toLowerCase())) list.push(filter.toLowerCase());

		list.insert(0, 'all');

		return list;
	}

	static var audioCache:Map<String, Sound> = [];

	#if FREEPLAY_VISUALIZER
	static var audioVizCache:Map<String, FlxWaveform> = [];

	static var curWaveforms:Array<FlxWaveform> = [];
	static var curWaveformsID:Array<String> = [];

	static function runOnWaveforms(func:FlxWaveform->String->Void)
	{
		if (func == null || curWaveforms == null) return;

		for (wf in curWaveforms) func(wf, curWaveformsID[wf.ID]);
	}
	#end

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

	var waveformLayer:FlxSpriteGroup;

	var playButton:CornerButton;

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

		#if FREEPLAY_VISUALIZER
		runOnWaveforms((wave, waveID) ->
		{
			wave.alpha = 0;
			waveformLayer.add(wave);
		});
		#end

		changeVolume(filterList.length);
		changeSel(0);
		filter('all');

		#if MOBILE_MODE
		playButton = new CornerButton('playBtn');

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

	override function finishTransIn()
	{
		super.finishTransIn();

		changeBGAudio();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (subState == null)
		{
			for (i => swipe in FlxG.swipes)
			{
				if (swipe.duration == 0) continue;

				if (i > 0) continue;

				if (swipe.distance == 0) continue;

				final up = FlxMath.roundDecimal(swipe.degrees / -90, 2);
				final down = FlxMath.roundDecimal(swipe.degrees / 90, 2);

				final left = FlxMath.roundDecimal(swipe.degrees / 180, 2);
				final right = FlxMath.roundDecimal(swipe.degrees / 45, 2);

				trace('dist: ${swipe.distance}', 'deg: ${swipe.degrees}', 'left: $left', 'down: $down', 'up: $up', 'right: $right');

				final range_vertical = [0.5, 1.5];

				final range_left_1 = [0.7, 1.5];
				final range_left_2 = [-0.7, -1.5];

				final range_right = [-0.2, 1.2];

				if (up >= range_vertical[0] && up <= range_vertical[1]) changeSel(1);
				else if (down >= range_vertical[0] && down <= range_vertical[1]) changeSel(-1);
				else if ((left >= range_left_1[0] && left <= range_left_1[1])
					|| (left <= range_left_2[0] && left >= range_left_2[1])) changeVolume(-1);
				else if (right >= range_right[0] && right <= range_right[1]) changeVolume(1);
			}

			if (FlxG.keys.anyJustPressed([W, UP])) changeSel(-1);
			if (FlxG.keys.anyJustPressed([S, DOWN])) changeSel(1);

			if (FlxG.keys.anyJustPressed([A, LEFT])) changeVolume(-1);
			if (FlxG.keys.anyJustPressed([D, RIGHT])) changeVolume(1);

			if (FlxG.keys.justPressed.ENTER) proceed();
		}

		if (bgAudio != null && bgAudio.volume > FlxG.sound.volume) bgAudio.volume = FlxG.sound.volume;

		FlxG.watch.addQuick('songCode', songCode);

		#if FREEPLAY_VISUALIZER
		runOnWaveforms((wave, waveID) ->
		{
			if (wave == null || wave.waveformBuffer == null) return;

			FlxG.watch.addQuick('waveform-${wave.ID}', waveID);

			if (waveID != songCode || bgAudio == null)
			{
				wave.active = wave.visible = false;
				return;
			}

			wave.visible = wave.active = true;

			@:privateAccess
			{
				if (wave.waveformTime != bgAudio._channel.position) wave.waveformTime = bgAudio._channel.position;
			}
		});
		#end
	}

	function proceed()
	{
		FlxG.sound.play(Paths.getAudio('sfx/menu/confirm'));

		var song = {
			song: songCode.substr(0, songCode.lastIndexOf('-')),
			variation: songCode.substr(songCode.lastIndexOf('-') + 1),
		}
		trace(song);

		if (bgAudio != null && bgAudio.playing) bgAudio.fadeOut(.25, 0, t ->
		{
			FlxG.sound.onVolumeChange.remove(onVolumeChange);

			bgAudio.stop();
			bgAudio.destroy();
			bgAudio = null;
		});

		DialogueScene.seenIntroCutscene = false;
		FlxG.switchState(() -> new DialogueScene(new SongData(song.song, song.variation)));
	}

	override function finishTransOut()
	{
		super.finishTransOut();

		#if FREEPLAY_VISUALIZER
		runOnWaveforms((wave, waveID) ->
		{
			waveformLayer.remove(wave);
			wave.active = false;

			#if !FREEPLAY_VISUALIZER_MULTICACHE
			curWaveforms.remove(wave);
			curWaveformsID.remove(waveID);
			wave.destroy();
			wave = null;
			#end
		});

		#if FREEPLAY_VISUALIZER_MULTICACHE
		for (id => waveform in audioVizCache)
		{
			audioVizCache.remove(id);
			waveform.destroy();
			waveform = null;
		}

		audioVizCache.clear();
		#end
		#end
	}

	function onVolumeChange(vol:Float) @:privateAccess
	{
		#if FREEPLAY_VISUALIZER
		runOnWaveforms((wave, waveID) -> wave.waveformGainMultiplier = FlxG.sound.volume);
		#end

		if (bgAudio == null) return;

		if (bgAudio.fadeTween?.active) bgAudio.fadeTween.cancel();

		bgAudio.volume = FlxG.sound.volume;
	}

	function fadeinVisualizer()
	{
		if (bgAudio?.volume < 0.1 || bgAudio == null || bgAudio.length < 1) return;

		#if FREEPLAY_VISUALIZER
		runOnWaveforms((wave, waveID) ->
		{
			if (waveID != songCode) return;
			wave.waveformTime = bgAudio.time;

			FlxTween.cancelTweensOf(wave);
			FlxTween.tween(wave, {alpha: 1}, .25, {ease: FlxEase.quartInOut});
		});
		#end
	}

	override function onFocusLost()
	{
		super.onFocusLost();

		if (bgAudio != null) bgAudio.pause();
	}

	override function onFocus()
	{
		super.onFocus();

		if (bgAudio == null) return;

		bgAudio.resume();

		#if FREEPLAY_VISUALIZER
		runOnWaveforms((wave, waveID) ->
		{
			if (wave != null) wave.waveformTime = bgAudio.time;
		});
		#end
	}

	function loadSongAudio() @:privateAccess
	{
		if (bgAudio != null) bgAudio.stop();
		else return;

		if (entries[selectedEntry] == null) return;

		if (!audioCache.exists(songCode))
		{
			bgAudio.load(Paths.getSong(entries[selectedEntry].song, entries[selectedEntry]?.variation ?? defaultVariation));
			audioCache.set(songCode, bgAudio._sound);
		}
		else bgAudio.load(audioCache.get(songCode));
		bgAudio.looped = true;

		#if (FREEPLAY_VISUALIZER && !FREEPLAY_VISUALIZER_MULTICACHE)
		runOnWaveforms((wave, waveID) ->
		{
			curWaveforms.remove(wave);
			curWaveformsID.remove(waveID);
			waveformLayer.remove(wave);
			wave.destroy();
		});

		makeWaveform(entries[selectedEntry]);
		#end

		#if FREEPLAY_VISUALIZER
		runOnWaveforms((wave, waveID) -> wave.scrollFactor.set());
		#end

		bgAudio.play();

		fadeinVisualizer();
		bgAudio.fadeIn(.25, bgAudio.volume, FlxG.sound.volume);
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

			if (i == selectedEntry)
			{
				text.color = #if FREEPLAY_DISPLAY_SCORE (textSongRank == NONE) ? FlxColor.ORANGE : #end
				FlxColor.YELLOW;
				camFollow.y = text.y;
			}
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

		if (selectedEntry != prevSel || amount == 0)
		{
			FlxG.sound.play(Paths.getAudio('sfx/menu/scroll'));
			changeBGAudio();
		}
	}

	function changeBGAudio()
	{
		if (bgAudio == null || !bgAudio.playing)
		{
			#if FREEPLAY_VISUALIZER
			runOnWaveforms((wave, waveID) -> wave.alpha = 0);
			#end

			loadSongAudio();

			return;
		}

		#if FREEPLAY_VISUALIZER
		runOnWaveforms((wave, waveID) ->
		{
			FlxTween.cancelTweensOf(wave);
			FlxTween.tween(wave, {alpha: 0}, .25, {ease: FlxEase.quartInOut});
		});
		#end

		bgAudio.fadeOut(.25, 0, t ->
		{
			loadSongAudio();
		});
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

		if (selectedVolume != prevVol || amount == 0)
		{
			FlxG.sound.play(Paths.getAudio('sfx/menu/scroll'));

			filter(filterList[selectedVolume]);
			changeBGAudio();
		}
	}

	function filter(f:String)
	{
		entries = [];

		switch (f.toLowerCase())
		{
			case 'all': entries = songs;

			default: entries = songs.filter(s -> return s.filters.contains(f.toLowerCase()));
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
			if (song.variation == null) song.variation = defaultVariation;

			var tXt:FlxText = new FlxText(0, i * Constants.TEXT_SIZE * 4, 0, '${song.song}', Constants.TEXT_SIZE * 2);
			var variationStr = song.variation.toString().toLowerCase();
			var curSongRank:SongRank = Save.scores.get('${song.song.toLowerCase()}-${variationStr}')?.rank ?? NONE;

			if (song.variation != defaultVariation) tXt.text += ' (${variationStr.substr(0, 1).toUpperCase()}${variationStr.substr(1)})';
			#if FREEPLAY_DISPLAY_SCORE
			if (curSongRank == NONE) tXt.text += ' (Unplayed)';
			#end

			#if (FREEPLAY_VISUALIZER && FREEPLAY_VISUALIZER_MULTICACHE)
			if (curWaveforms[i] == null) makeWaveform(song, i);
			#end

			#if FREEPLAY_CENTER_LAYOUT
			tXt.screenCenter(X);
			#elseif FREEPLAY_LEFT_LAYOUT
			tXt.alignment = LEFT;
			tXt.x += tXt.size;
			#elseif FREEPLAY_RIGHT_LAYOUT
			tXt.alignment = RIGHT;
			tXt.x = FlxG.width - tXt.width - tXt.size;
			#else
			trace('No freeplay layout defined, wtf');
			#end

			texts.add(tXt);
		}

		changeSel(entries.length);
	}

	#if FREEPLAY_VISUALIZER
	function makeWaveform(song:FreeplaySongData, ?i:Null<Int>) @:privateAccess
	{
		if (i == null) i = curWaveforms.length;

		var viz:String = '${song.song.toLowerCase()}-${(song.variation ?? defaultVariation).toString().toLowerCase()}';

		if (curWaveformsID.contains(viz))
		{
			runOnWaveforms((wave, waveID) ->
			{
				if (waveID != viz) return;

				wave.ID = i;
				curWaveformsID.remove(viz);
				curWaveformsID.insert(i, viz);
				waveformLayer.add(wave);
			});

			return;
		}

		var audio:FlxSound;
		if (audioCache.exists(viz)) audio = new FlxSound().load(audioCache.get(viz));
		else
		{
			audio = new FlxSound().load(Paths.getSong(song.song, song.variation));
			audio.looped = true;

			audioCache.set(viz, audio._sound);
		}

		if (audio == null) return;

		var bgAudioViz:FlxWaveform;

		if (audioVizCache.exists(viz) && audioVizCache.get(viz) != null) bgAudioViz = audioVizCache.get(viz);
		else
		{
			bgAudioViz = new FlxWaveform(0, 0, Math.floor(FlxG.width / 4), Math.floor(FlxG.height - topSegBG.height - btmSegBG.height), FlxColor.WHITE,
				FlxColor.TRANSPARENT);
			bgAudioViz.y = topSegBG.height;

			bgAudioViz.loadDataFromFlxSound(audio);

			if (bgAudioViz.waveformBuffer != null) bgAudioViz.waveformBuffer.autoDestroy = false;
			bgAudioViz.waveformDuration = 125;

			bgAudioViz.waveformOrientation = VERTICAL;
			bgAudioViz.waveformTime = bgAudio?.time ?? 0;

			bgAudioViz.alpha = 0;

			bgAudioViz.scrollFactor.set();
			bgAudioViz.onWaveformBufferSet.add(function()
			{
				audioVizCache.set(viz, bgAudioViz);
			});

			#if FREEPLAY_LEFT_LAYOUT
			bgAudioViz.x = FlxG.width - bgAudioViz.width;
			#end
		}
		bgAudioViz.scrollFactor.set();

		bgAudioViz.ID = i;
		waveformLayer.add(bgAudioViz);

		curWaveforms.push(bgAudioViz);
		curWaveformsID.push(viz);
	}
	#end
}
