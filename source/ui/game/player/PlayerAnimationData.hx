package ui.game.player;

typedef PlayerAnimationData =
{
	> ui.game.stage.StageData.StageObjectAnimationData,

	@:optional
	@:default(false)
	var createFlippedVarients:Bool;
}
