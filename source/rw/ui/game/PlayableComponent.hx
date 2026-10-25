package rw.ui.game;

import rw.ui.game.song.SongEventData;

class PlayableComponent
{
	public function new() {}

	public function build() {}

	public function destroy() {}

	public function onEvent(event:SongEventRawData) {}

	public function onBeatHit(beat:Int, backward:Bool) {}

	public function onStepHit(step:Int, backward:Bool) {}

	public function update(elapsed:Float) {}
}
