package rw.ui.game.walker.songs;

class SongTrainGetawayDefault extends WalkerSong
{
	override public function new()
	{
		super('train getaway', defaultVariation);
	}

	override function build()
	{
		super.build();

		var fireSegs:Array<Float> = [];
		var jammedSegs:Array<Float> = [];

		function addIncrementSeg(start:Float, inc:Int, skip:Array<Int>, ?jammed:Bool)
		{
			var incs = [0, 0.187, 0.375, 0.562, 0.750, 0.937, 1.125,];

			for (i in 0...inc)
			{
				if (skip.contains(i)) continue;

				if (jammed) jammedSegs.push(start + incs[i]);
				else fireSegs.push(start + incs[i]);
			}
		}

		function addSeg(seg:Array<Float>) for (thing in seg) fireSegs.push(thing);

		addIncrementSeg(3, 7, []);
		addSeg([4.500, 4.781, 5.062, 5.343, 5.625]);
		addIncrementSeg(6, 7, [3]);
		addIncrementSeg(9, 7, [3]);
		addIncrementSeg(12, 7, [3]);
		addIncrementSeg(15, 7, [3]);
		addIncrementSeg(18, 7, [3]);
		addIncrementSeg(21, 7, [3]);
		addIncrementSeg(22.5, 7, [3], true);

		addIncrementSeg(27, 7, [3]);
		addIncrementSeg(30, 7, [3]);
		addIncrementSeg(33, 7, [3]);

		for (time in fireSegs) game.addEvent({
			time: time * 1000,
			id: 'traingetaway-gun'
		});

		for (time in jammedSegs) game.addEvent({
			time: time * 1000,
			id: 'traingetaway-gunJammed'
		});
	}
}
