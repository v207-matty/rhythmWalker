package rw.util.tools;

class MapTool
{
	public static function length<A, B>(map:Null<Map<A, B>>):Int return (map == null) ? 0 : [for (x in map) x].length;

	public static function idList<A, B>(map:Null<Map<A, B>>):Array<A> return (map == null) ? [] : [for (x => y in map) x];

	public static function valueList<A, B>(map:Null<Map<A, B>>):Array<B> return (map == null) ? [] : [for (x => y in map) y];
}
