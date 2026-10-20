package ui.game.stage;

import flixel.util.typeLimit.OneOfTwo;

enum abstract StageObjectLayerData(String) from String to String
{
	var back = 'back';
	var front = 'front';
}

enum abstract StageObjectTypeData(String) from String to String
{
	var backdrop = 'backdrop';
	var floor = 'floor';
	var sprite = 'sprite';
}

typedef StageObjectData =
{
	@:default(back)
	var layer:StageObjectLayerData;

	var type:StageObjectTypeData;

	@:optional
	@:default(false)
	var scaleToScreen:Null<Bool>;

	@:optional
	var id:String;

	@:optional
	var graphic:String;

	@:optional
	@:default({x: 1, y: 1})
	var scale:StageXYParam;

	@:optional
	@:default({x: 0, y: 0})
	var velocity:StageXYParam;

	@:optional
	@:default({x: 1, y: 1})
	var scrollFactor:StageXYParam;

	@:optional
	@:default(false)
	var center:OneOfTwo<Null<Bool>, String>;

	@:optional
	@:default(false)
	var repeatAxes:String;

	@:optional
	@:default('0xFFFFFFFF')
	var color:String;

	@:optional
	var parent:String;

	@:optional
	@:default({x: 0, y: 0})
	var position:StageXYParam;

	@:optional
	@:default(1.0)
	var alpha:Null<Float>;

	@:optional
	@:default('NORMAL')
	var blend:String;

	@:optional
	@:default(false)
	var animated:Null<Bool>;

	@:optional
	var frame:StageObjectFrameData;

	@:optional
	@:default([])
	var animations:Array<StageObjectAnimationData>;

	@:optional
	var shader:StageShaderConfigData;
}

typedef StageXYParam =
{
	@:optional
	var x:OneOfTwo<String, Null<Float>>;
	@:optional
	var y:OneOfTwo<String, Null<Float>>;
}

typedef StageObjectFrameData =
{
	var width:Null<Int>;
	var height:Null<Int>;
}

typedef StageObjectAnimationData =
{
	var name:String;
	var frames:Array<Int>;

	@:optional
	@:default(24)
	var fps:Null<Int>;

	@:optional
	@:default(false)
	var flipX:Null<Bool>;

	@:optional
	@:default(false)
	var flipY:Null<Bool>;

	@:optional
	@:default(false)
	var looped:Null<Bool>;
}

typedef StageShadersData =
{
	@:optional
	var char:StageShaderConfigData;
	@:optional
	var monster:StageShaderConfigData;
}

typedef StageShaderConfigData =
{
	var shader:String;

	@:optional
	var config:Dynamic;
}

typedef StageConfigData =
{
	@:optional
	var player:StageConfigPlayerData;

	@:optional
	var beatmonsters:StageConfigBMData;

	@:optional
	@:default('0xFF000000')
	var bgColor:String;
}

typedef StageConfigPlayerData =
{
	@:optional
	var scale:StageXYParam;

	@:optional
	var position:StageXYParam;
}

typedef StageConfigBMData =
{
	@:optional
	@:default(1.0)
	var scale:Null<Float>;
}
