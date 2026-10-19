package ui.game.player;

typedef PlayerData =
{
    @:optional
    @:default({})
	var config:PlayerConfigData;

    @:optional
    @:default([])
	var animations:Array<PlayerAnimationData>;
}
