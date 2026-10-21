package haxpression;

enum ExpressionType
{
	ELiteral(value:ValueType);
	EIdentifier(name:String);
	EUnary(op:String, operand:ExpressionType);
	EBinary(op:String, left:ExpressionType, right:ExpressionType);
	ECall(callee:String, arguments:Array<ExpressionType>);
	EConditional(test:ExpressionType, consequent:ExpressionType, alternate:ExpressionType);
	EArray(items:Array<ExpressionType>);
	ECompound(items:Array<ExpressionType>);
}
