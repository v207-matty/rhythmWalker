package rw.util.macro;

#if sys
import sys.io.Process;
import haxe.macro.Context;

using StringTools;
#end

class GitMacro
{
	public static macro function getGitHash()
	{
		#if sys
		if (Context.defined('display')) return macro $v{''};

		var process = new Process('git', ['rev-parse', 'HEAD']);
		var output = process.stdout?.readAll()?.toString() ?? null;

		process.close();

		if (output == null) return macro $v{''};
		else return macro $v{output.trim().substr(0, 6)};
		#else
		return macro $v{''};
		#end
	}

	public static macro function getGitBranch()
	{
		#if sys
		if (Context.defined('display')) return macro $v{''};

		var process = new Process('git', ['rev-parse', '--abbrev-ref', 'HEAD']);
		var output = process.stdout?.readAll()?.toString() ?? null;

		process.close();

		if (output == null) return macro $v{''};
		else return macro $v{output.trim()};
		#else
		return macro $v{''};
		#end
	}
}
