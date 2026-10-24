package rw.util;

import lime.ui.Window;
import lime.app.Application;
import flixel.FlxG;

using StringTools;

class WindowUtil
{
	public static var window(get, never):Window;

	static function get_window() return Application.current.window;

	public static function resetTitle(?includeVersion:Bool)
	{
		window.title = 'Rhythm Walker';
		if (includeVersion) appendVersion();
	}

	public static function appendToTitle(str:String)
	{
		if (str.trim().length < 1) return;
		window.title += ' $str';
	}

	public static function appendVersion() appendToTitle('(v${Application.current.meta.get('version')})');

	public static function alert(title:String, message:String) window.alert(message, title);

	public static function close() window.close();
}
