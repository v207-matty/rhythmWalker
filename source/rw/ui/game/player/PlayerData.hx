package rw.ui.game.player;

import json2object.JsonWriter;
import hxjsonast.Json;
import json2object.JsonParser;
import flixel.FlxG;
import lime.utils.Assets;

class PlayerData
{
	@:jignored
	public var id(default, null):String;

	public var config(default, null):PlayerConfigData;
	public var animations(default, null):Array<PlayerAnimationData>;

	public function new(id:String, ?loadFile:Bool = true)
	{
		this.id = id;

		if (loadFile) this.loadFile();
	}

	function loadFile()
	{
		try
		{
			var path:String = Paths.json('game/players/$id');
			loadData(new JsonParser<PlayerData>().fromJson(Assets.getText(path), path));
		}
		catch (e)
		{
			FlxG.stage.window.alert('Player File Loading Error: ${e.message}');
		}
	}

	function loadData(json:PlayerData)
	{
		if (json == null) throw 'Null JSON Data';

		this.config = json?.config ?? null;
		this.animations = json?.animations ?? null;

		this.config ??= {
			dimensions: null,
			speed: null,
			maxVelocityBase: null,
		};

		this.animations ??= [];

		this.config.dimensions ??= {
			sprite: null,
			hitbox: null,
		};

		this.config.dimensions.sprite ??= [64, 64];
		this.config.dimensions.hitbox ??= [32, 32];

		this.config.speed ??= 20;
		this.config.maxVelocityBase ??= 200;
		this.config.graphic ??= this.id;
	}

	public function toString():String return new JsonWriter<PlayerData>().write(this, '');
}
