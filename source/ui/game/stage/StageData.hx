package ui.game.stage;

typedef StageData =
{
	var objects:Array<
		{
			var config:
				{
					var layer:String;
					var type:String;
					var scaleToScreen:Bool;
					?var
					id:String;
					var scale:
						{
							var x:Float;
							var y:Float;
						};
					var velocity:
						{
							var x:EitherType<String, Float>;
						};
					?var
					scrollFactor:
						{
							var x:Float;
							var y:Float;
						};
					?var
					center:String;
					?var
					color:String;
					?var
					parent:String;
					?var
					position:
						{
							?var
							x:String;
							var y:String;
						};
					?var
					alpha:Float;
					?var
					blend:String;
					?var
					animated:Bool;
					?var
					frame:
						{
							var width:Float;
							var height:Float;
						};
					?var
					animations:Array<
						{
							var name:String;
							var frames:Array<Float>;
							var fps:Float;
							?var
							looped:Bool;
						}>;
				};
			var graphic:String;
		}>;
	?var
	shaders:
	{
		var bg:
			{
				var shader:String;
				var config:
					{
						var hue:Float;
						var saturation:Float;
						var brightness:Float;
					};
			};
		var char:
			{
				var shader:String;
				var config:
					{
						var hue:Float;
						var saturation:Float;
						var brightness:Float;
					};
			};
		var monster:
			{
				var shader:String;
				var config:
					{
						var hue:Float;
						var saturation:Float;
						var brightness:Float;
					};
			};
	};
	?var
	config:
	{
		?var player:
		{
			?var scale:
			{
				var x:Float;
				var y:Float;
			};
			var position:
				{
					var y:String;
				};
		};
		?var beatmonsters:
		{
			var scale:Float;
		};
		?var bgColor:String;
	};
}
