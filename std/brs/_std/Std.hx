package;

extern class Std {
	@:deprecated('Std.is is deprecated. Use Std.isOfType instead.') @:runtime public inline static function is(v:Dynamic, t:Dynamic):Bool
		return isOfType(v, t);

	@:nativeFunctionCode("Type({arg0}) = {arg1}")
	public static function isOfType(v:Dynamic, t:Dynamic):Bool;

	@:deprecated('Std.instance() is deprecated. Use Std.downcast() instead.')
	@:runtime public inline static function instance<T:{}, S:T>(value:T, c:Class<S>):S
		return downcast(value, c);

	@:nativeFunctionCode("{arg0}")
	public static function downcast<T:{}, S:T>(value:T, c:Class<S>):S;

	@:nativeFunctionCode('__DynToStr__({arg0})')
	public static function string(s:Dynamic):String;

	@:nativeFunctionCode("Int({arg0})")
	public static function int(x:Float):Int;

	@:nativeFunctionCode("StrToI({arg0})")
	public static function parseInt(x:String):Null<Int>;

	@:nativeFunctionCode("StrToI({arg0})")
	public static function parseFloat(x:String):Float;

	@:nativeFunctionCode("Rnd({arg0})")
	public static function random(x:Int):Int;
}

@:keep @:brs_global function __DynToStr__(a:Dynamic) {
	final dynType = brs.Native.typeOf(a);

	return switch dynType {
		case 'roString': a;
		case 'roInt': untyped __brs__('Str({0})', a);
		case 'roFloat': untyped __brs__('Str({0})', a);
		case 'roDouble': untyped __brs__('Str({0})', a);
		case 'roBoolean': untyped __brs__('{0}.ToStr()', a);
		case 'roArray':
			untyped __brs__('
			s = ""
			for i = 0 to {0}.Count()-1
				If i > 0 Then 
					del = {1}
				Else 
					del = "" 
				end If
				s = s + del + __DynToStr__({0}[i])
			end for', a, ', ');
			'[${untyped __brs__("s")}]';

		case 'roAssociativeArray':
			untyped __brs__('
			s = "{"
			keys = {0}.Keys()
			for i = 0 to keys.Count() - 1
				if i > 0 then s = s + ", "
				s = s + keys[i] + ": " + __DynToStr__({0}[keys[i]])
			end for
			s = s + "}"', a);
			'[${untyped __brs__("s")}]';
		case 'Function': '[Function]';
		case _: 'NOT_IMPLEMENTED__DynToStr__($dynType)';
	}
}
