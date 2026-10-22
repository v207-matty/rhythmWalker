package rw.ui.game.player;

typedef PlayerConfigDimensionsData =
{
	@:optional
	@:default([64, 64])
	var sprite:Array<Int>;

	@:optional
	@:default([32, 32])
	var hitbox:Array<Int>;
}
