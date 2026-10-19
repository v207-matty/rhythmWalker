package ui.game.player;

typedef PlayerConfigData =
{
	var dimensions:PlayerConfigDimensionsData;

    @:optional
    @:default(200)
	var maxVelocityBase:Float;

    @:optional
    @:default(20)
	var speed:Float;
}
