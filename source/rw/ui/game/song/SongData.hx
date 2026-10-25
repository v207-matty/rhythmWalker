package rw.ui.game.song;

import rw.ui.game.PlayData.PlayModeData;
import rw.util.WindowUtil;
import json2object.JsonParser;
import json2object.JsonWriter;
import flixel.addons.sound.MusicTimeChangeEvent;
import flixel.FlxG;
import openfl.net.FileReference;
import haxe.Json;
import lime.utils.Assets;

using StringTools;

class SongData
{
	public var id(default, null):String;
	public var variation(default, null):SongVariation;

	public var bpmChanges(default, null):Array<MusicTimeChangeData> = [
		{
			t: 0.0,
			bpm: 0.0,
		}
	];

	@:optional
	@:default([])
	public var events(default, null):Array<SongEventData> = [];

	@:optional
	@:default(1)
	public var scrollSpeed(default, null):Null<Float> = 1;

	@:optional
	@:default('bro-regular')
	public var player(default, null):String = 'bro-regular';

	@:optional
	@:default('stage')
	public var stage(default, null):String = 'stage';

	@:optional
	@:default(WALKER)
	public var mode(default, null):PlayModeData = WALKER;

	public function new(nid:String, nvariation:SongVariation = defaultVariation, ?loadFile:Bool = true)
	{
		this.id = nid.toLowerCase();
		this.variation = new SongVariation(nvariation?.toString()?.toLowerCase() ?? SongVariation.defaultVariation.toString());

		if (variation?.toString()?.trim()?.length < 1 || variation == null) variation = defaultVariation;

		if (loadFile) this.loadFile();
	}

	public function loadFile()
	{
		try
		{
			var path:String = Paths.json('game/songs/$id/$variation');
			loadData(new JsonParser<SongData>().fromJson(Assets.getText(path), path));
		}
		catch (e)
		{
			WindowUtil.alert('SongData File Loading Error', '${e.message}');
		}
	}

	public function loadData(json:SongData)
	{
		if (json == null) throw 'Null JSON Data';

		this.id = json?.id?.toLowerCase() ?? 'idk';
		this.variation = new SongVariation(json?.variation) ?? defaultVariation;
		this.bpmChanges = json?.bpmChanges ?? [];
		this.events = json?.events ?? [];
		this.scrollSpeed = json?.scrollSpeed ?? 1;
		this.player = json?.player ?? 'bro-regular';
		this.stage = json?.stage ?? 'stage';
		this.mode = json?.mode ?? WALKER;
	}

	public function toString():String return '$id-$variation';
}
