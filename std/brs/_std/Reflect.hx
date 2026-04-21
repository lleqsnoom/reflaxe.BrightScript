package;

extern class Reflect {
	@:nativeFunctionCode("{arg0}[{arg1}]")
	public static function field(o:Dynamic, field:String):Dynamic;

	@:nativeFunctionCode("{arg0}[{arg1}] = {arg2}")
	public static function setField(o:Dynamic, field:String, value:Dynamic):Void;

	@:nativeFunctionCode("{arg0}.DoesExist({arg1})")
	public static function hasField(o:Dynamic, field:String):Bool;

	@:nativeFunctionCode("__Reflect_deleteField__({arg0}, {arg1})")
	public static function deleteField(o:Dynamic, field:String):Bool;

	@:nativeFunctionCode("__Reflect_fields__({arg0})")
	public static function fields(o:Dynamic):Array<String>;

	@:nativeFunctionCode("{arg0}[{arg1}]")
	public static function getProperty(o:Dynamic, field:String):Dynamic;

	@:nativeFunctionCode("{arg0}[{arg1}] = {arg2}")
	public static function setProperty(o:Dynamic, field:String, value:Dynamic):Void;

	@:nativeFunctionCode("__Reflect_isFunction__({arg0})")
	public static function isFunction(f:Dynamic):Bool;

	@:nativeFunctionCode("__Reflect_isObject__({arg0})")
	public static function isObject(v:Dynamic):Bool;

	@:nativeFunctionCode("__Reflect_isEnumValue__({arg0})")
	public static function isEnumValue(v:Dynamic):Bool;

	@:nativeFunctionCode("__Reflect_compare__({arg0}, {arg1})")
	public static function compare<T>(a:T, b:T):Int;

	@:nativeFunctionCode("__Reflect_compareMethods__({arg0}, {arg1})")
	public static function compareMethods(f1:Dynamic, f2:Dynamic):Bool;

	@:nativeFunctionCode("__Reflect_copy__({arg0})")
	public static function copy<T>(o:Null<T>):Null<T>;

	@:nativeFunctionCode("__Reflect_callMethod__({arg0}, {arg1}, {arg2})")
	public static function callMethod(o:Dynamic, func:Dynamic, args:Array<Dynamic>):Dynamic;

	@:nativeFunctionCode("__Reflect_makeVarArgs__({arg0})")
	public static function makeVarArgs(f:Dynamic):Dynamic;
}

@:keep @:brs_global function __Reflect_deleteField__(o:Dynamic, f:String):Dynamic {
	var exists:Bool = brs.Native.doesExist(o, f);
	if (exists == true) {
		untyped __brs__('{0}.Delete({1})', o, f);
		return untyped __brs__('true');
	}
	return untyped __brs__('false');
}

@:keep @:brs_global function __Reflect_fields__(o:Dynamic):Dynamic {
	var k:Dynamic = brs.Native.keys(o);
	var result:Dynamic = brs.Native.emptyArray();
	var cnt:Int = brs.Native.count(k);
	var i:Int = 0;
	while (i < cnt) {
		brs.Native.push(result, brs.Native.arrayGet(k, i));
		i = i + 1;
	}
	return result;
}

@:keep @:brs_global function __Reflect_isFunction__(f:Dynamic):Bool {
	final t:String = brs.Native.typeOf(f);
	final isFunc:Bool = brs.Native.eq(t, "roFunction");
	if (isFunc)
		return untyped __brs__('true');
	final isFunc2:Bool = brs.Native.eq(t, "Function");
	if (isFunc2)
		return untyped __brs__('true');
	final isFunc3:Bool = untyped __brs__('{0} = "roAssociativeArray" AND {1}.call <> invalid AND (Type({1}.call) = "Function" OR Type({1}.call) = "roFunction" )', t, f);
	if(isFunc3)
		return untyped __brs__('true');
	return untyped __brs__('false');
}

@:keep @:brs_global function __Reflect_isObject__(v:Dynamic):Bool {
	var t:String = brs.Native.typeOf(v);

	var isAA:Bool = brs.Native.eq(t, "roAssociativeArray");
	if (isAA == true)
		return true;
	var isArr:Bool = brs.Native.eq(t, "roArray");
	if (isArr == true)
		return true;
	return false;
}

@:keep @:brs_global function __Reflect_isEnumValue__(v:Dynamic):Bool {
	var t:String = brs.Native.typeOf(v);
	var isAA:Bool = brs.Native.eq(t, "roAssociativeArray");
	if (isAA == true) {
		var hasIdx:Bool = brs.Native.doesExist(v, "_index");
		if (hasIdx == true)
			return untyped __brs__('true');
	}
	return untyped __brs__('false');
}

@:keep @:brs_global function __Reflect_compare__(a:Dynamic, b:Dynamic):Int {
	untyped __brs__('
	if {0} = invalid then
		if {1} = invalid then
			return 0
		end if
		return -1
	end if
	if {1} = invalid then
		return 1
	end if
	if {0} < {1} then
		return -1
	end if
	if {0} > {1} then
		return 1
	end if', a, b);
	return 0;
}

@:keep @:brs_global function __Reflect_compareMethods__(f1:Dynamic, f2:Dynamic):Dynamic {
	untyped __brs__('
	if {0} = invalid then
		return false
	end if
	if {1} = invalid then
		return false
	end if', f1, f2);
	return untyped __brs__('({0} = {1})', f1, f2);
}

@:keep @:brs_global function __Reflect_copy__(o:Dynamic):Dynamic {
	untyped __brs__('
	if {0} = invalid then
		return invalid
	end if', o);
	var result:Dynamic = brs.Native.emptyAA();
	var k:Dynamic = brs.Native.keys(o);
	var cnt:Int = brs.Native.count(k);
	var i:Int = 0;
	while (i < cnt) {
		var key:String = brs.Native.arrayGet(k, i);
		brs.Native.fieldSet(result, key, brs.Native.fieldGet(o, key));
		i = i + 1;
	}
	return result;
}

@:keep @:brs_global function __Reflect_callMethod__(o:Dynamic, func:Dynamic, args:Dynamic):Dynamic {
	var cnt:Int = brs.Native.count(args);
	if (cnt == 0)
		return untyped __brs__('{0}()', func);
	if (cnt == 1)
		return untyped __brs__('{0}({1}[0])', func, args);
	if (cnt == 2)
		return untyped __brs__('{0}({1}[0], {1}[1])', func, args);
	if (cnt == 3)
		return untyped __brs__('{0}({1}[0], {1}[1], {1}[2])', func, args);
	if (cnt == 4)
		return untyped __brs__('{0}({1}[0], {1}[1], {1}[2], {1}[3])', func, args);
	if (cnt == 5)
		return untyped __brs__('{0}({1}[0], {1}[1], {1}[2], {1}[3], {1}[4])', func, args);
	return brs.Native.invalid();
}

@:keep @:brs_global function __Reflect_makeVarArgs__(f:Dynamic):Dynamic {
	return f;
}
