package rw.util.mobile.android;

#if android
class DataFolderUtil
{
	public static function openDataFolder():Void
	{
		final openDataFolderJNI:Null<Dynamic> = JNIUtil.createStaticMethod('rw/util/mobile/android/DataFolderUtil', 'openDataFolder', '(I)V');
		if (openDataFolderJNI != null) openDataFolderJNI(CallbackUtil.DATA_FOLDER_CLOSED);
	}
}
#end
