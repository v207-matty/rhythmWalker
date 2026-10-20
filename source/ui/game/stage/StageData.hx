package ui.game.stage;

import flixel.util.typeLimit.OneOfTwo;
import flixel.util.typeLimit.OneOfThree;

typedef StageData =
{
	var objects:Array<StageObjectData>;

	@:optional
	var shaders:StageShadersData;

	@:optional
	var config:StageConfigData;
}

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
	@:default('back')
	var layer:StageObjectLayerData;

	var type:StageObjectTypeData;

	@:optional
	@:default(false)
	var scaleToScreen:Bool;

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
	var center:OneOfTwo<Bool, String>;

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
	var alpha:Float;

	@:optional
	@:default('NORMAL')
	var blend:String;

	@:optional
	@:default(false)
	var animated:Bool;

	@:optional
	var frame:StageObjectFrameData;

	@:optional
	@:default([])
	var animations:Array<StageObjectAnimationData>;
}

typedef StageXYParam =
{
	@:optional
	var x:OneOfTwo<String, Float>;
	@:optional
	var y:OneOfTwo<String, Float>;
}

typedef StageObjectFrameData =
{
	var width:Int;
	var height:Int;
}

typedef StageObjectAnimationData =
{
	var name:String;
	var frames:Array<Int>;

	@:optional
	@:default(24)
	var fps:Int;

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

typedef StageShadersData =
{
	@:optional
	var bg:StageShaderConfigData;
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
	@:default('0x00000000')
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
	var scale:Float;
}
