package rw.util;

#if sys
import sys.thread.Thread;
#end

class ThreadUtil
{
	public static function create(job:Void->Void)
	{
		#if sys
		Thread.create(job);
		#else
		job();
		#end
	}
}
