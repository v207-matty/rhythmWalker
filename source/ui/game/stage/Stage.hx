package ui.game.stage;

class Stage
{
	public var stage:String;

	public var game(get, never):PlayState;
	
	function get_game():PlayState
		return PlayState.instance;

	public function new(stage:String) { this.stage = stage; }

	public function build() {}

	public function update(elapsed:Float) {}
}
