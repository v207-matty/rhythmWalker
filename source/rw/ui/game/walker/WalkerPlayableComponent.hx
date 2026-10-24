package rw.ui.game.walker;

class WalkerPlayableComponent extends PlayableComponent
{
	public var game(get, never):WalkerPlayState;

	function get_game():WalkerPlayState return WalkerPlayState.instance;
}
