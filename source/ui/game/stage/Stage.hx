package ui.game.stage;

import flixel.util.typeLimit.OneOfTwo;
import haxpression.Expression;
import haxpression.Value;
import haxpression.Expressions;
import ui.objects.Floor;
import util.CustomShader;
import flixel.util.FlxColor;
import util.Constants;
import openfl.display.BlendMode;
import flixel.FlxSprite;
import flixel.util.FlxAxes;
import flixel.addons.display.FlxBackdrop;
import flixel.FlxBasic;
import ui.game.stage.StageData;
import json2object.JsonWriter;
import hxjsonast.Json;
import json2object.JsonParser;
import flixel.FlxG;
import lime.utils.Assets;

using StringTools;

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

		this.expressionVariableMap = [];

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
			y: null,
		};

		this.config.player.scale ??= {
			x: null,
			y: null,
		};

		this.config.beatmonsters ??= {
			scale: null
		};

		this.config.beatmonsters.scale ??= 1.0;

		addExpressionVariable('game_width', FlxG.width);
		addExpressionVariable('game_height', FlxG.height);
	}

	public function toString():String
		return new JsonWriter<Stage>().write(this, '');

	public function createStageProps(layer:StageObjectLayerData):Map<String, FlxSprite>
	{
		if (objects == null || objects.length < 1)
			return [];

		var props:Map<String, FlxSprite> = [];
		var floorQueue:Map<String, StageObjectData> = [];

		for (i => object in objects)
		{
			if (object.layer != layer)
				continue;

			var res = createStageProp(i, object, props);

			if (floorQueue.exists(object.id))
			{
				createStageProp(i, floorQueue.get(object.id), props);
				floorQueue.remove(object.id);
			}

			if (res != null && object.type == floor)
				floorQueue.set(object.id, res);
		}

		return props;
	}

	public function createStageProp(index:Int, object:StageObjectData, ?props:Map<String, FlxSprite>):StageObjectData
	{
		var centerAxes:FlxAxes = (object.center is Bool) ? (object.center) ? XY : NONE : ((object.center is String) ? FlxAxes.fromString(object.center) : NONE);
		var repeatAxes:FlxAxes = FlxAxes.fromString(object.repeatAxes) ?? XY;

		function applyBasicStuff(object:FlxSprite, data:StageObjectData)
		{
			addExpressionVariable('graphic_width', object.width);
			addExpressionVariable('graphic_height', object.height);

			object.alpha = data.alpha;
			object.blend = Constants.BLENDMODE_MAP.get(data.blend?.toLowerCase() ?? 'NORMAL') ?? NORMAL;
			object.screenCenter(centerAxes);
			object.color = FlxColor.fromString(data.color ?? '0xFFFFFFFF');

			if (data.position != null)
			{
				object.x += applyFloatOrString(data.position?.x ?? 0);
				object.y += applyFloatOrString(data.position?.y ?? 0);
			}

			if (data.scaleToScreen)
				object.setGraphicSize(FlxG.width, FlxG.height);
			else if (data.scale != null)
				object.scale.set(applyFloatOrString(data.scale.x), applyFloatOrString(data.scale.y));

			if (data.scrollFactor != null)
			{
				object.scrollFactor.x += applyFloatOrString(data.scrollFactor?.x ?? 1);
				object.scrollFactor.y += applyFloatOrString(data.scrollFactor?.y ?? 1);
			}

			if (data.velocity != null)
			{
				object.velocity.x += applyFloatOrString(data.velocity?.x ?? 0);
				object.velocity.y += applyFloatOrString(data.velocity?.y ?? 0);
			}

			removeExpressionVariable('graphic_width');
			removeExpressionVariable('graphic_height');

			var newShader = new CustomShader(data.shader?.shader ?? null);

			if (!newShader.shaderFound)
				return;

			if (data.shader?.config != null)
				for (field in Reflect.fields(data.shader.config))
				{
					var value:Dynamic = Reflect.field(data.shader.config, field);

					if (value is Bool)
						newShader.setBool(field, value);
					else if (value is Float)
						newShader.setFloat(field, value);
					else if (value is Int)
						newShader.setInt(field, value);
					else if (value is Array)
					{
						var elementUno = value[0];
						var elementDos = value[1];

						if (elementUno is Bool && elementDos is Bool)
							newShader.setBoolArray(field, value);
						else if (elementUno is Float && elementDos is Float)
							newShader.setFloatArray(field, value);
						else if (elementUno is Int && elementDos is Int)
							newShader.setIntArray(field, value);
						else
							trace('Unimplemented array value type (${value})');
					}
					else
						trace('Unimplemented value type (${value})');
				}

			object.shader = newShader;
		}

		function addObject(id:String, obj:FlxSprite)
		{
			if (id == null)
				return;
			if (obj == null)
				return;

			addExpressionVariable(id + '_alpha', obj.alpha);

			addExpressionVariable(id + '_x', obj.x);
			addExpressionVariable(id + '_y', obj.y);
			
			addExpressionVariable(id + '_width', obj.width);
			addExpressionVariable(id + '_height', obj.height);

			props.set(id, obj);
		}

		switch (object.type)
		{
			case backdrop:
				if (object.graphic == null)
					return null;

				var backdrop = new FlxBackdrop(Paths.getImagePath('game/stages/$id/${object.graphic}'), repeatAxes);
				applyBasicStuff(backdrop, object);
				addObject(object?.id ?? '$index', backdrop);

			case floor:
				if (object.parent == null)
					return null;
				if (!props.exists(object.parent))
					return object;

				var floor = new Floor(props.get(object.parent), 0xFFFFFFFF, null, null);
				applyBasicStuff(floor, object);
				addObject(object?.id ?? '$index', floor);

			case sprite:
				if (object.graphic == null)
					return null;

				var spr = new StageSprite('$id/${object.graphic}', object.animated, object.frame?.width, object.frame?.height,);
				applyBasicStuff(spr, object);

				if (object.animated)
					for (index => animation in object.animations)
					{
						if (animation.frames == null || animation.frames.length < 1)
							return null;

						spr.addAnim(animation.name ?? '$index', animation.frames, animation?.fps ?? 24, animation.looped, animation.flipX, animation.flipY);
					}

				addObject(object?.id ?? '$index', spr);
		}

		return null;
	}

	public var expressionVariableMap(default, null):Map<String, Value> = [];

	public function getExpressionVariablesFrom(name:String, d:Dynamic)
		for (field in Reflect.fields(d))
			addExpressionVariable('${name}_${field}', Reflect.getProperty(d, field));

	public function addExpressionVariable(name:String, value:Dynamic)
		expressionVariableMap.set(name, Value.fromDynamic(value));

	public function removeExpressionVariable(name:String)
		expressionVariableMap.remove(name);

	public function applyExpressionShit(expression:Expression)
		return Expressions.evaluate([expression], expressionVariableMap)[0];

	public function applyFloatOrString(a:OneOfTwo<String, Null<Float>>):Float
		return (a is Float) ? a : (a is String) ? applyExpressionShit(Expression.fromString(a)) : 0;
}
