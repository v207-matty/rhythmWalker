package ui.game.stage;

import ui.game.song.SongEventData;

class Stage
{
	public var stage:String;

	public var game(get, never):PlayState;

	function get_game():PlayState return PlayState.instance;

	public function new(stage:String)
	{
		this.stage = stage;
	}

	public function build() {}

	public function onEvent(event:SongEventData) {}

	public function onBeatHit(beat:Int, backward:Bool) {}

	public function onStepHit(step:Int, backward:Bool) {}

	public function update(elapsed:Float) {}
}
