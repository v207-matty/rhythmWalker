package rw.ui.game.song;

import rw.ui.game.songs.*;

class SongManager
{
	public static function get(song:String, variation:SongVariation)
	{
		return switch ([song.toLowerCase(), variation])
		{
			case ['chase', defaultVariation]:
				new SongChase();

			case ['first steps', resolved] | ['shift around', resolved]:
				new SongDayOneResolved(song.toLowerCase());

			case ['train getaway', defaultVariation]:
				new SongTrainGetawayDefault();

			default:
				trace('Unimplemented song case : $song');
				new Song(song, variation);
		}
	}
}
