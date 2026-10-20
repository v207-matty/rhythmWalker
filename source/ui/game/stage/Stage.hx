package ui.game.player;

import ui.game.stage.StageData;
import json2object.JsonWriter;
import hxjsonast.Json;
import json2object.JsonParser;
import flixel.FlxG;
import lime.utils.Assets;

class Stage
{
	@:jignored
	public var id(default, null):String;

	public var objects:Array<StageObjectData>;

	@:optional
	public var shaders:StageShadersData;

	@:optional
	public var config:StageConfigData;

	public function new(id:String, ?loadFile:Bool = true)
	{
		this.id = id;

		if (loadFile)
			this.loadFile();
	}

	function loadFile()
	{
		try
		{
			var path:String = Paths.json('game/stages/$id/stage');
			loadData(new JsonParser<Stage>().fromJson(Assets.getText(path), path));
		}
		catch (e)
		{
			FlxG.stage.window.alert('Stage File Loading Error: ${e.message}');
		}
	}

	function loadData(json:Stage)
	{
		if (json == null)
			throw 'Null JSON Data';

		this.objects = json?.objects ?? [];
		this.shaders = json?.shaders ?? null;
		this.config = json?.config ?? null;

		this.shaders ??= {
			char: null,
			monster: null
		};

		this.shaders.char ??= {
			shader: null,
		}

		this.shaders.monster ??= {
			shader: null,
		}

		this.config ??= {
			beatmonsters: null,
			player: null,
			bgColor: null
		};

		this.config.bgColor ??= '0xFF000000';

		this.config.player ??= {
			scale: null,
			position: null,
		};

		this.config.player.position ??= {
			x: null,
			y:null,
		};

		this.config.player.scale ??= {
			x: null,
			y:null,
		};

		this.config.beatmonsters ??= {
			scale: null
		};

		this.config.beatmonsters.scale ??= 1.0;
	}

	public function toString():String
		return new JsonWriter<Stage>().write(this, '');
}
