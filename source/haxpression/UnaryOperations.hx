package haxpression;

import Lambda;
import haxpression.ValueType;

using haxpression.utils.Arrays;
using haxpression.utils.Iterators;

class UnaryOperations
{
	static var map(default, null):Map<String, {operation:Value->Value}>;

	public static function __init__()
	{
		map = new Map();
		addop("-", function(value) return value.toFloat() * -1);
		addop("+", function(value) return value.toFloat() * 1);
		addop("!", function(value) return !(value.toBool()));
		addop("~", function(value) return ~(value.toInt()));
	}

	public static function evaluate(op:String, value:Value):Value
	{
		return map.get(op).operation(value);
	}

	public static function addop(op:String, operation:Value->Value)
	{
		map.set(op, {
			operation: wrapOperation(operation)
		});
	}

	public static function removeop(op:String)
	{
		map.remove(op);
	}

	public static function hasop(op:String):Bool
	{
		return map.exists(op);
	}

	public static function clearops()
	{
		map = new Map();
	}

	public static function getMaxopLength():Int
	{
		return map.keys().toArray().reduce(function(maxLength:Int, key:String):Int
		{
			return key.length > maxLength ? key.length : maxLength;
		}, 0);
	}

	static function wrapOperation(operation:Value->Value):Value->Value
	{
		return function(value:Value):Value
		{
			return if (value.isNA()) return VNA; else if (value.isNM()) return VNM; else operation(value);
		}
	}
}
