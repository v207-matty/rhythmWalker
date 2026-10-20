package util;

import flixel.FlxG;
import flixel.addons.display.FlxRuntimeShader;
import lime.utils.Assets;

class CustomShader extends FlxRuntimeShader
{
	public var shaderFound(default, null):Bool = true;

	public function new(name:String)
	{
		var fragPath:String = Paths.frag(name);
		var vertPath:String = Paths.vert(name);

		var fragCode:String = (Assets.exists(fragPath)) ? Assets.getText(fragPath) : null;
		var vertCode:String = (Assets.exists(vertPath)) ? Assets.getText(vertPath) : null;

		var shaderFound = fragCode == null && vertCode == null;

		if (!shaderFound)
			FlxG.stage.window.alert('Shader "$name" couldn\'t be found.');

		super(fragCode, vertCode);
	}
}
