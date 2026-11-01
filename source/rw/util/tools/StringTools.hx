package rw.util.tools;

using StringTools;

class StringTools
{
	public static function splitByLinebreaks(str:String):Array<String>
	{
		if (str == null) return [];

		return [
			for (a in str.split('\n')) if (a != null && a.length > 0 && a.trim().length > 0) a.trim()
		];
	}
}
