package rw.ui.objects;

import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxSprite;

class RWSprite extends FlxSprite
{
	public var sprite:String;

	override public function new(sprite:String, ?animated:Bool, ?fw:Int, ?fh:Int)
	{
		super();

		if (sprite == null) return;

		this.sprite = sprite;
		loadGraphic(Paths.getImagePath(sprite), animated, fw, fh);

		setScale(4);
	}

	override function makeGraphic(width:Int, height:Int, color:FlxColor = FlxColor.WHITE, unique:Bool = false,
			?key:String):RWSprite return cast super.makeGraphic(width, height, color, unique, key);

	public function setScale(?x:Float, ?y:Float):RWSprite
	{
		scale.set(x ?? y ?? 1, y ?? x ?? 1);
		updateHitbox();

		return this;
	}

	public function addAnim(anim:String, frames:Array<Int>, fps:Int = 24, ?looped:Bool = false, flipX = false,
			flipY = false) animation.add(anim, frames, fps, looped, flipX, flipY);

	public function playAnim(name:String, forced = false, reversed = false, frame = 0)
	{
		if (animation.name == name && !forced) return;
		animation.play(name, forced, reversed, frame);
	}

	public function dance() {}

	public function setCamera(cam:FlxCamera):RWSprite
	{
		camera = cam;
		return this;
	}

	public function setScrollFactor(?x:Float, ?y:Float):RWSprite
	{
		scrollFactor.set(x ?? y ?? 1, y ?? x ?? 1);
		return this;
	}

	public function offsetBy(?x:Float, ?y:Float):RWSprite
	{
		offset.add(x ?? y ?? 0, y ?? x ?? 0);
		return this;
	}

	public function scaleToScreen():RWSprite
	{
		setScale(1);

		if (width > height) setGraphicSize(FlxG.width);
		else if (height > width) setGraphicSize(0, FlxG.height);
		else setScale(FlxG.width, FlxG.height);

		updateHitbox();
		screenCenter();

		return this;
	}
}
