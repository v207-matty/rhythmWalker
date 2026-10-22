package rw.ui.game.player;

typedef PlayerConfigData =
{
	@:default({
		sprite: [64, 64],
		hitbox: [32, 32],
	})
	var dimensions:PlayerConfigDimensionsData;

	@:default(200)
	var maxVelocityBase:Null<Float>;

	@:default(20)
	var speed:Null<Float>;
}
