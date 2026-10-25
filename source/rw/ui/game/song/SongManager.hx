package rw.ui.game.song;

import rw.ui.game.rh.songs.*;
import rw.ui.game.rh.*;
import rw.ui.game.walker.*;
import rw.ui.game.walker.songs.*;

class SongManager
{
	public static function getRhythmHeaven(song:String, variation:SongVariation):RHSong
	{
		return switch ([song.toLowerCase(), variation])
		{
			case ['first steps', aria]:
				return new SongFirstStepsAria();

			default:
				trace('Unimplemented song case : $song ($variation)');
				return new RHSong(song, variation);
		}
	}

	public static function getWalker(song:String, variation:SongVariation):WalkerSong
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
				trace('Unimplemented song case : $song ($variation)');
				new WalkerSong(song, variation);
		}
	}
}
