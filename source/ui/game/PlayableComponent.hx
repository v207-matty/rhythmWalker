package ui.game;

import ui.game.song.SongEventData;

class PlayableComponent
{
	public var game(get, never):PlayState;

	function get_game():PlayState return PlayState.instance;

	public function new() {}
    
	public function build() {}

	public function onEvent(event:SongEventData) {}

	public function onBeatHit(beat:Int, backward:Bool) {}

	public function onStepHit(step:Int, backward:Bool) {}

	public function update(elapsed:Float) {}
}
