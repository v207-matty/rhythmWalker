package rw.util.macro;

class FileMacro
{
	public static macro function getFile(file:String) return macro $v{(FileSystem.exists(file)) ? File.getContent(file) ?? null : null};
}
