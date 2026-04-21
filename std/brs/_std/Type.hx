package;

enum ValueType {
	TNull;
	TInt;
	TFloat;
	TBool;
	TObject;
	TFunction;
	TClass(c:Class<Dynamic>);
	TEnum(e:Enum<Dynamic>);
	TUnknown;
}

extern class Type {
	@:nativeFunctionCode("__Type_typeof__({arg0})")
	public static function typeof(v:Dynamic):ValueType;

	@:nativeFunctionCode("0 + {arg0}._index")
	public static function enumIndex(e:EnumValue):Int;

	@:nativeFunctionCode("__Type_enumConstructor__({arg0})")
	public static function enumConstructor(e:EnumValue):String;

	@:nativeFunctionCode("__Type_enumParameters__({arg0})")
	public static function enumParameters(e:EnumValue):Array<Dynamic>;

	@:nativeFunctionCode("__Type_enumEq__({arg0}, {arg1})")
	public static function enumEq<T>(a:T, b:T):Bool;

	@:nativeFunctionCode("__Type_getClass__({arg0})")
	public static function getClass<T>(o:T):Class<T>;

	@:nativeFunctionCode("__Type_getClassName__({arg0})")
	public static function getClassName(c:Class<Dynamic>):String;

	@:nativeFunctionCode("__Type_getEnum__({arg0})")
	public static function getEnum(o:EnumValue):Enum<Dynamic>;

	@:nativeFunctionCode("__Type_getEnumName__({arg0})")
	public static function getEnumName(e:Enum<Dynamic>):String;

	@:nativeFunctionCode("__Type_getInstanceFields__({arg0})")
	public static function getInstanceFields(c:Class<Dynamic>):Array<String>;

	@:nativeFunctionCode("__Type_getClassFields__({arg0})")
	public static function getClassFields(c:Class<Dynamic>):Array<String>;

	@:nativeFunctionCode("invalid")
	public static function getSuperClass(c:Class<Dynamic>):Class<Dynamic>;

	@:nativeFunctionCode("__Type_createInstance__({arg0}, {arg1})")
	public static function createInstance<T>(cl:Class<T>, args:Array<Dynamic>):T;

	@:nativeFunctionCode("__Type_createEmptyInstance__({arg0})")
	public static function createEmptyInstance<T>(cl:Class<T>):T;

	@:nativeFunctionCode("invalid")
	public static function resolveClass(name:String):Class<Dynamic>;

	@:nativeFunctionCode("invalid")
	public static function resolveEnum(name:String):Enum<Dynamic>;

	@:nativeFunctionCode("invalid")
	public static function createEnum<T>(e:Enum<T>, constr:String, ?params:Array<Dynamic>):T;

	@:runtime public inline static function createEnumIndex<T>(e:Enum<T>, index:Int, ?params:Array<Dynamic>):T {
		return cast brsCreateEnumIndexFull(index, params);
	}

	@:nativeFunctionCode("__Type_createEnumIndex__({arg0}, {arg1})")
	private static function brsCreateEnumIndexFull(index:Int, params:Dynamic):Dynamic;

	@:nativeFunctionCode("[]")
	public static function allEnums<T>(e:Enum<T>):Array<T>;

	@:nativeFunctionCode("[]")
	public static function getEnumConstructs(e:Enum<Dynamic>):Array<String>;
}

private extern class BrsType {
	@:nativeFunctionCode("__Type_enumEq__({arg0}, {arg1})")
	static function enumEq(a:Dynamic, b:Dynamic):Bool;
}

// --- typeof: runtime type detection ---

@:keep @:brs_global function __Type_typeof__(v:Dynamic):Dynamic {
	untyped __brs__('
	if {0} = invalid then return {"_index": 0}
	t = Type({0})
	if t = "roInt" OR t = "Integer" then return {"_index": 1}
	if t = "roFloat" OR t = "Float" OR t = "roDouble" OR t = "Double" then return {"_index": 2}
	if t = "roBoolean" OR t = "Boolean" then return {"_index": 3}
	if t = "roString" OR t = "String" then return {"_index": 6, "c": invalid}
	if t = "roFunction" OR t = "Function" then return {"_index": 5}
	if t = "roArray" then return {"_index": 6, "c": invalid}
	if t = "roAssociativeArray" then
		if {0}.DoesExist("_index") then
			if {0}.DoesExist("__static__") then return {"_index": 6, "c": invalid}
			return {"_index": 7, "e": invalid}
		end if
		if {0}.DoesExist("call") AND {0}.DoesExist("_ctx_") then return {"_index": 5}
		if {0}.DoesExist("__static__") then return {"_index": 6, "c": invalid}
		return {"_index": 4}
	end if
	return {"_index": 8}', v);
	return brs.Native.invalid();
}

// --- enumConstructor: return constructor name if stored, else null ---

@:keep @:brs_global function __Type_enumConstructor__(e:Dynamic):Dynamic {
	untyped __brs__('
	if {0} = invalid then return invalid
	if {0}.DoesExist("_hxName") then return {0}._hxName', e);
	return brs.Native.invalid();
}

// --- enumParameters: return params array if present, else empty ---

@:keep @:brs_global function __Type_enumParameters__(e:Dynamic):Dynamic {
	untyped __brs__('
	if {0} = invalid then return []
	if {0}.DoesExist("params") then return {0}.params', e);
	return brs.Native.emptyArray();
}

// --- enumEq: deep equality comparison ---

@:keep @:brs_global function __Type_enumEq__(a:Dynamic, b:Dynamic):Dynamic {
	untyped __brs__('
	if {0} = invalid then
		if {1} = invalid then return true
		return false
	end if
	if {1} = invalid then return false', a, b);
	var ta:String = brs.Native.typeOf(a);
	var tb:String = brs.Native.typeOf(b);
	if (ta != tb)
		return false;
	if (ta == "roAssociativeArray") {
		var hasIdxA:Bool = brs.Native.doesExist(a, "_index");
		var hasIdxB:Bool = brs.Native.doesExist(b, "_index");
		if (hasIdxA != true)
			return false;
		if (hasIdxB != true)
			return false;
		var idxA:Dynamic = brs.Native.fieldGet(a, "_index");
		var idxB:Dynamic = brs.Native.fieldGet(b, "_index");
		if (idxA != idxB)
			return false;
		var hasParamsA:Bool = brs.Native.doesExist(a, "params");
		var hasParamsB:Bool = brs.Native.doesExist(b, "params");
		if (hasParamsA == true) {
			if (hasParamsB == true) {
				var paramsA:Dynamic = brs.Native.fieldGet(a, "params");
				var paramsB:Dynamic = brs.Native.fieldGet(b, "params");
				var countA:Int = brs.Native.count(paramsA);
				var countB:Int = brs.Native.count(paramsB);
				if (countA != countB)
					return false;
				var i:Int = 0;
				while (i < countA) {
					var paramA:Dynamic = brs.Native.arrayGet(paramsA, i);
					var paramB:Dynamic = brs.Native.arrayGet(paramsB, i);
					var eq:Bool = BrsType.enumEq(paramA, paramB);
					if (eq != true)
						return false;
					i = i + 1;
				}
			}
		}
		return true;
	}
	return brs.Native.eq(a, b);
}

// --- getClass: return __static__ AA if class instance ---

@:keep @:brs_global function __Type_getClass__(o:Dynamic):Dynamic {
	// trace('====================> getClass called with $o', o);
	untyped __brs__('
	if {0} = invalid then return invalid', o);
	var t:String = brs.Native.typeOf(o);
	if (t == "roAssociativeArray") {
		var hasStatic:Bool = brs.Native.doesExist(o, "__static__");
		if (hasStatic == true)
			return brs.Native.fieldGet(o, "__static__");
	}
	return brs.Native.invalid();
}

// --- getClassName: return __hx_name__ if stored ---

@:keep @:brs_global function __Type_getClassName__(c:Dynamic):Dynamic {
	untyped __brs__('
	if {0} = invalid then return invalid
	if {0}.DoesExist("__hx_name__") then return {0}.__hx_name__', c);
	return brs.Native.invalid();
}

// --- getEnum: return __enum__ AA if enum value ---

@:keep @:brs_global function __Type_getEnum__(o:Dynamic):Dynamic {
	untyped __brs__('
	if {0} = invalid then return invalid
	if Type({0}) = "roAssociativeArray" then
		if {0}.DoesExist("__enum__") then return {0}.__enum__
	end if', o);
	return brs.Native.invalid();
}

// --- getEnumName: return __hx_name__ from enum type ---

@:keep @:brs_global function __Type_getEnumName__(e:Dynamic):Dynamic {
	untyped __brs__('
	if {0} = invalid then return invalid
	if {0}.DoesExist("__hx_name__") then return {0}.__hx_name__', e);
	return brs.Native.invalid();
}

// --- getInstanceFields: return __hx_fields__ if stored on class ---

@:keep @:brs_global function __Type_getInstanceFields__(cls:Dynamic):Dynamic {
	untyped __brs__('
	if {0} = invalid then return []
	if {0}.DoesExist("__hx_fields__") then return {0}.__hx_fields__', cls);
	return brs.Native.emptyArray();
}

// --- getClassFields: enumerate keys of class (static) AA ---

@:keep @:brs_global function __Type_getClassFields__(cls:Dynamic):Dynamic {
	untyped __brs__('
	if {0} = invalid then return []
	result = []
	keys = {0}.Keys()
	for i = 0 to keys.Count() - 1
		k = keys[i]
		if k <> "CreateInstance" then
			result.Push(k)
		end if
	end for
	return result', cls);
	return brs.Native.emptyArray();
}

// --- createInstance: call cls.CreateInstance with dynamic args ---

@:keep @:brs_global function __Type_createInstance__(cls:Dynamic, args:Dynamic):Dynamic {
	untyped __brs__('
	if {0} = invalid then return invalid
	if NOT {0}.DoesExist("CreateInstance") then return invalid
	cnt = {1}.Count()
	if cnt = 0 then return {0}.CreateInstance()
	if cnt = 1 then return {0}.CreateInstance({1}[0])
	if cnt = 2 then return {0}.CreateInstance({1}[0], {1}[1])
	if cnt = 3 then return {0}.CreateInstance({1}[0], {1}[1], {1}[2])
	if cnt = 4 then return {0}.CreateInstance({1}[0], {1}[1], {1}[2], {1}[3])
	if cnt = 5 then return {0}.CreateInstance({1}[0], {1}[1], {1}[2], {1}[3], {1}[4])
	return invalid', cls, args);
	return brs.Native.invalid();
}

// --- createEmptyInstance: create AA with __static__ link but no constructor ---

@:keep @:brs_global function __Type_createEmptyInstance__(cls:Dynamic):Dynamic {
	untyped __brs__('
	if {0} = invalid then return invalid
	inst = {}
	inst.__static__ = {0}
	return inst', cls);
	return brs.Native.invalid();
}

// --- createEnumIndex: construct enum value from index ---

@:keep @:brs_global function __Type_createEnumIndex__(index:Int, params:Dynamic):Dynamic {
	var result:Dynamic = brs.Native.emptyAA();
	brs.Native.fieldSet(result, "_index", index);
	untyped __brs__('
	if {0} <> invalid then {1}.params = {0}', params, result);
	return result;
}
