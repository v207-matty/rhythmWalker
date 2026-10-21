package haxpression;

import Lambda;
import haxpression.ValueType;

using haxpression.utils.Arrays;
using haxpression.utils.Iterators;

class BinaryOperations
{
	static var map(default, null):Map<String, {precedence:Int, operation:Value->Value->Value}>;

	public static function __init__()
	{
		map = new Map();
		// Higher numbers have higher precedence (higher precedence ops will be evaluated before lower)
		addop("||", 1, function(left, right) return left.toBool() || right.toBool());
		addop("&&", 2, function(left, right) return left.toBool() && right.toBool());
		addop("|", 3, function(left, right) return left.toInt() | right.toInt());
		addop("^", 4, function(left, right) return left.toInt() ^ right.toInt());
		addop("&", 5, function(left, right) return left.toInt() & right.toInt());
		addop("==", 6, function(left, right) return left.toFloat() == right.toFloat());
		addop("!=", 6, function(left, right) return left.toFloat() != right.toFloat());
		addop("<", 7, function(left, right) return left.toFloat() < right.toFloat());
		addop(">", 7, function(left, right) return left.toFloat() > right.toFloat());
		addop("<=", 7, function(left, right) return left.toFloat() <= right.toFloat());
		addop(">=", 7, function(left, right) return left.toFloat() >= right.toFloat());
		addop("<<", 8, function(left, right) return left.toInt() << right.toInt());
		addop(">>", 8, function(left, right) return left.toInt() >> right.toInt());
		addop(">>>", 8, function(left, right) return left.toInt() >>> right.toInt());
		addop("+", 9, function(left, right) return left.toFloat() + right.toFloat());
		addop("-", 9, function(left, right) return left.toFloat() - right.toFloat());
		addop("*", 10, function(left, right) return left.toFloat() * right.toFloat());
		addop("/", 10, function(left, right) return left.toFloat() / right.toFloat());
		addop("%", 10, function(left, right) return left.toFloat() % right.toFloat());
		addop("**", 11, function(left, right) return Math.pow(left.toFloat(), right.toFloat()));
	}

	public static function evaluate(op, left:Value, right:Value):Value
	{
		return map.get(op).operation(left, right);
	}

	public static function addop(op:String, precedence:Int, operation:Value->Value->Value)
	{
		map.set(op, {
			precedence: precedence,
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

	public static function getopPrecedence(op:String):Int
	{
		return map.get(op).precedence;
	}

	public static function getMaxopLength():Int
	{
		return map.keys().toArray().reduce(function(maxLength:Int, key:String):Int
		{
			return key.length > maxLength ? key.length : maxLength;
		}, 0);
	}

	static function wrapOperation(operation:Value->Value->Value):Value->Value->Value
	{
		return function(left:Value, right:Value):Value
		{
			return if (left.isNA() || right.isNA()) return VNA; else if (left.isNM() || right.isNM()) return VNM; else operation(left, right);
		}
	}
}
