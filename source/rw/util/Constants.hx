package rw.util;

class Constants
{
	public static final TEXT_SIZE:Int = #if MOBILE_PLATFORM 32; #else 16; #end
	public static final TEXT_OUTLINE_SIZE:Int = #if MOBILE_PLATFORM 4; #else 2; #end

	public static final MOBILE_PLATFORM:Bool = #if MOBILE_PLATFORM true #else false #end;
	public static final MOBILE_MODE:Bool = #if MOBILE_MODE true #else false #end;
}
