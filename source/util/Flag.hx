package util;

import util.macro.DefineMacro;

enum abstract Flag(Bool) from Bool to Bool
{
	public static var list:Map<String, Flag> = [];

	public static final FREEPLAY_DISPLAY_SCORE = new Flag('FREEPLAY_DISPLAY_SCORE', [#if web false #else true #end]);

	public function new(id:String, conditionals:Array<Bool>)
	{
		set(conditionals);

		if (!list.exists(id))
			list.set(id, this);
	}

	public inline function set(conditionals:Array<Bool>)
		this = (conditionals == [] || conditionals.filter(b -> return b).length == conditionals.length);
}
