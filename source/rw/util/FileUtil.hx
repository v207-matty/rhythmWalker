package rw.util;

import haxe.io.Path;
import lime.utils.Assets;

using StringTools;

class FileUtil
{
	public static function readDirectory(directory:String):Array<String>
	{
		directory = Path.removeTrailingSlashes(directory);

		#if sys
		return [
			for (file in FileSystem.readDirectory(directory))
			{
				var path = '$directory/$file';
				if (!FileSystem.isDirectory(path)) path;
			}
		];
		#else
		var path:Path;

		return Assets.list().filter(f ->
		{
			path = new Path(f);
			return path.dir == directory;
		});
		#end
	}

	public static function readDirectoryRecursive(directory:String):Array<String>
	{
		directory = Path.removeTrailingSlashes(directory);

		#if sys
		var files:Array<String> = [];

		for (file in readDirectory(directory))
		{
			var path:String = '$directory/$file';

			if (FileSystem.isDirectory(path)) for (file in readDirectoryRecursive(path)) files.push(file);
			else files.push(path);
		}

		return files;
		#else
		var path:Path;

		return Assets.list().filter(f ->
		{
			path = new Path(f);
			return path.dir.startsWith(directory);
		});
		#end
	}
}
