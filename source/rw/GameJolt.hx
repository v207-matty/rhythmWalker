package rw;

import haxe.crypto.Md5;
import haxe.Http;

class GameJolt
{
    public static var instance:GameJolt;

	public var gameId:Int;
	public var privateKey:String;

	public function new(gameId:Int, privateKey:String)
	{
		this.gameId = gameId;
		this.privateKey = privateKey;
	}

	private static function paramsToString(params:Dynamic):String
	{
		var result:String = '';

		for (i => field in Reflect.fields(params))
		{
			final property:String = Reflect.getProperty(params, field);
			result += '${i == 0 ? '?' : '&'}$field=$property';
		}

		return result;
	}

	public function requestProtocol(protocol:String, ?params:Dynamic)
	{
		final url:String = 'https://api.gamejolt.com/api/game/v1_2';
		final paramsString:String = paramsToString(params);

		final urlString:String = '$url/$protocol/$paramsString';
		final md5Result:String = Md5.encode('$urlString$privateKey').toString();
		var fullUrl:String = '$urlString&signature=$md5Result';
		// trace(fullUrl);

		var http = new Http(fullUrl);
		http.onData = data ->
		{
			trace(data);
		};
		http.request(false);
	}

	public function unlockTrophy(id:Int):Bool
	{
		requestProtocol("trophies/add-achieved", {
			game_id: gameId,
			username: '', // Add your GameJolt login stuff here!
			user_token: '',
			trophy_id: id
		});

		return false;
	}
}
