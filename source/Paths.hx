import song.SongVariation;

class Paths
{
	public static function getPath(path:String)
		return 'assets/$path';

	public static function getAudio(path:String)
		return getPath('$path.ogg');

	public static function getSong(song:String, variation:SongVariation = defaultVariation)
		return getAudio('game/songs/${song.toLowerCase()}/${(variation ?? defaultVariation)?.toString()?.toLowerCase()}');

	public static function getImagePath(path:String)
		return getPath('$path.png');

	public static function json(path:String)
		return getPath('$path.json');

	public static function txt(path:String)
		return getPath('$path.txt');

	public static function frag(path:String)
		return getPath('shaders/$path.frag');

	public static function vert(path:String)
		return getPath('shaders/$path.vert');
}
