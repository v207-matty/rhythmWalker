package rw.ui.game.rh;

class RHPlayableComponent extends PlayableComponent
{
	public var game(get, never):RHPlayState;

	function get_game():RHPlayState return RHPlayState.instance;
}
