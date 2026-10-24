package rw.ui.game.song;

import rw.ui.game.walker.*;
import rw.ui.game.walker.songs.*;

class SongManager
{
	public static function get(song:String, variation:SongVariation):WalkerSong
	{
		return switch ([song.toLowerCase(), variation])
		{
			case ['chase', defaultVariation]:
				new SongChaseDefault();

			case ['first steps', resolved] | ['shift around', resolved]:
				new SongDayOneResolved(song.toLowerCase());

			case ['encapture', defaultVariation]:
				new SongEncaptureDefault();

			case ['lost media', defaultVariation]:
				new SongLostMediaDefault();

			case ['save', defaultVariation]:
				new SongSaveDefault();

			case ['scroll down chinatown', defaultVariation]:
				new SongScrollDownChinatownDefault();

			case ['shift around', defaultVariation]:
				new SongShiftAroundDefault();

			case ['train getaway', defaultVariation]:
				new SongTrainGetawayDefault();

			case ['train wreak', defaultVariation]:
				new SongTrainWreakDefault();

			default:
				trace('Unimplemented song case : $song');
				new WalkerSong(song, variation);
		}
	}
}
