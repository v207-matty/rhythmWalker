package rw.util.macro;

import sys.io.Process;
import haxe.macro.Context;

class GitMacro
{
	public static macro function getGitHash()
	{
		if (Context.defined('display')) return macro $v{''};

		var process = new Process('git', ['rev-parse', 'HEAD']);
		var output = process.stdout?.readAll()?.toString() ?? null;

		process.close();

		if (output == null) return macro $v{''};
		else return macro $v{output.substr(0, 6)};
	}

	public static macro function getGitBranch()
	{
		if (Context.defined('display')) return macro $v{''};

		var process = new Process('git', ['rev-parse', '--abbrev-ref', 'HEAD']);
		var output = process.stdout?.readAll()?.toString() ?? null;

		process.close();

		if (output == null) return macro $v{''};
		else return macro $v{output};
	}
}
