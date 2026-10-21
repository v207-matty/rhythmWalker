package util;

class Constants
{
	public static final TEXT_SIZE:Int = #if MOBILE_PLATFORM 32; #else 16; #end
	public static final TEXT_OUTLINE_SIZE:Int = #if MOBILE_PLATFORM 4; #else 2; #end
}
