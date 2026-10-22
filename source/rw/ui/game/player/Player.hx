package rw.ui.game.player;

import flixel.util.FlxColor;
import flixel.FlxSprite;
import rw.ui.objects.RWSprite;

class Player extends RWSprite
{
	public var data(default, null):PlayerData;
	public var collision(default, null):FlxSprite;

	public var stunned:Bool = false;

	override public function new(player:String)
	{
		data = new PlayerData(player);

		super('game/players/${data.config?.graphic ?? data.id}', true, data.config.dimensions.sprite[0], data.config.dimensions.sprite[1]);

		for (anim in data.animations)
		{
			if (anim == null || anim.name == null || anim.frames == null || anim.frames.length < 1) continue;

			trace('Player Anim : ${anim.name}');

			if (!anim.createFlippedVarients)
			{
				addAnim(anim.name, anim.frames, anim.fps, anim.looped, anim.flipX, anim.flipY);
				continue;
			}

			addAnim(anim.name + 'L', anim.frames, anim.fps, anim.looped, anim.flipX, anim.flipY);
			addAnim(anim.name + 'R', anim.frames, anim.fps, anim.looped, anim.flipX, anim.flipY);
		}

		collision = new FlxSprite().makeGraphic(data.config?.dimensions?.hitbox[0] ?? 32, data.config?.dimensions?.hitbox[1] ?? 32, FlxColor.RED);
		collision.visible = false;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (collision == null) return;

		collision.x = getGraphicMidpoint().x - (collision.width / 2);
		collision.y = getGraphicMidpoint().y - (collision.height / 2);
	}

	override function draw()
	{
		super.draw();

		if (collision != null && collision.visible)
		{
			collision.cameras = cameras;
			collision.draw();
		}
	}
}
