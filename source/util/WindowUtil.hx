package util;

import flixel.FlxG;

using StringTools;

class WindowUtil
{
	public static function resetTitle(?includeVersion:Bool)
	{
		FlxG.stage.window.title = 'Rhythm Walker';

		if (includeVersion) appendVersion();
	}

	public static function appendToTitle(str:String)
	{
		if (str.trim().length < 1) return;

		FlxG.stage.window.title += ' $str';
	}

	public static function appendVersion()
	{
		appendToTitle('(v${FlxG.stage.application.meta.get('version')})');
	}

	public static function alert(title:String, message:String)
	{
		FlxG.stage.window.alert(message, title);
	}
}
