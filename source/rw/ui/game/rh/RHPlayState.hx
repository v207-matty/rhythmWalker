package rw.ui.game.rh;

import rw.ui.menu.freeplay.Freeplay;
import rw.save.Save;
import flixel.FlxG;
import flixel.addons.sound.FlxRhythmConductorUtil;
import rw.ui.game.song.SongData;
import rw.ui.game.song.SongVariation;

class RHPlayState extends ConductorState
{
	public static var instance:RHPlayState;

	public var songData(default, null):SongData;

	public var timeBar:PlayTimeBar;

	override public function new(song:String, ?variation:SongVariation = defaultVariation)
	{
		super(null, null);

		this.songData = new SongData(song, variation ?? defaultVariation);
	}

	override function destroy()
	{
		super.destroy();

		instance = null;
	}

	override function create()
	{
		instance = null;
		instance = this;

		resetConductor();

		FlxG.sound.playMusic(Paths.getSong(songData.id, songData.variation), 1, false);
		FlxG.sound.music.onComplete = () -> onSongEnd(false);

		if (FlxG.sound.music.length < 1)
		{
			onSongEnd(true);
			return;
		}

		FlxRhythmConductorUtil.loadMeta(conductor, FlxRhythmConductorUtil.parseTimeChanges(songData.bpmChanges));

		add(timeBar = new PlayTimeBar());

		#if MOBILE_MODE
		var backBtn = new rw.ui.objects.mobile.CornerButton('backBtn');
		add(backBtn);
		backBtn.x = FlxG.width - backBtn.width;
		backBtn.onClicked.add(leave);
		#end

		persistentUpdate = true;

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		conductor.update(null);

		if (FlxG.keys.justPressed.ESCAPE) leave();

		timeBar.target = FlxG.width * (conductor.musicPosition / conductor.musicLength);
	}

	public function onSongEnd(skipping:Bool)
	{
		FlxG.sound.music.stop();

		timeBar.linked = false;

		trace('Yay we done');

		if (!skipping) if (Save.saveSongScore(songData.toString(), 0, 0))
		{
			FlxG.switchState(() -> new ResultsState(songData.toString()));
			return;
		}

		FlxG.switchState(() -> new Freeplay());
	}

	public function leave() onSongEnd(true);
}
