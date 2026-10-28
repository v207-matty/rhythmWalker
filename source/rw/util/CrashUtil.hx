package rw.util;

import lime.app.Application;
#if sys
import sys.io.File;
import sys.FileSystem;
#end
import haxe.CallStack;
import rw.save.Save;
import openfl.events.UncaughtErrorEvent;

class CrashUtil
{
	static function pushStack(stackItem:StackItem)
	{
		var str = '';

		switch (stackItem)
		{
			case FilePos(innerStackItem, file, line, column):
				str += ' in ${file}#${line}';
				if (column != null) str += ':${column}';
			case CFunction: str += '[Function] ';
			case Module(m): str += '[Module(${m})] ';
			case Method(classname, method): str += '[Function(${classname}.${method})] ';
			case LocalFunction(v): str += '[LocalFunction(${v})] ';
		}
		str += '\n';

		return str;
	}

	static var plzReport = '\n\nPlease report this on the github: https://github.com/v207-matty/rhythmWalker/issues';

	static function exceptionStack():Array<StackItem>
	{
		var stack = CallStack.exceptionStack(true);

		@:privateAccess
		stack.reverse();

		return stack;
	}

	public static function onCrashing(e:UncaughtErrorEvent) @:privateAccess
	{
		e.preventDefault();

		var stack = exceptionStack();

		Save.save();

		var shortDisplayError:String = 'Error: ${e.error}';
		var error:String = '$shortDisplayError\n\nCall Stack:\n';

		for (stackItem in stack) error += pushStack(stackItem);

		shortDisplayError += '\n\n${stack.length} CallStack ${(stack.length == 1) ? 'entry' : 'entries'}';

		shortDisplayError += plzReport;
		error += plzReport;

		#if sys
		var timestamp = Date.now().getTime();
		var path = 'crash/$timestamp.txt';

		if (!FileSystem.exists('crash')) FileSystem.createDirectory('crash');

		File.saveContent(path, error);

		var savedTo = '\nThe crash log is saved to "$path"';

		shortDisplayError += savedTo;
		error += savedTo;
		#end

		trace(error);

		WindowUtil.alert('Crash Handling', shortDisplayError);
		WindowUtil.close();
	}
}
