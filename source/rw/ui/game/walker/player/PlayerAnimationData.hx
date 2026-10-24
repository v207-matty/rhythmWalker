package rw.ui.game.walker.player;

typedef PlayerAnimationData =
{
	var name:String;
	var frames:Array<Int>;

	@:optional
	@:default(24)
	var fps:Int;

	@:optional
	@:default(false)
	var createFlippedVarients:Bool;

	@:optional
	@:default(false)
	var flipX:Bool;

	@:optional
	@:default(false)
	var flipY:Bool;

	@:optional
	@:default(false)
	var looped:Bool;
}
