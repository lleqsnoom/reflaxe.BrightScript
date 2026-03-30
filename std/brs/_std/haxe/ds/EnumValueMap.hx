package haxe.ds;

extern class EnumValueMap<K:EnumValue, V> implements haxe.Constraints.IMap<K, V> {
	@:nativeFunctionCode("__BrsKVArrayNew__()")
	public function new():Void;

	@:nativeFunctionCode("__EnumValueMap_set__({this}, {arg0}, {arg1})")
	public function set(key:K, value:V):Void;

	@:nativeFunctionCode("__EnumValueMap_get__({this}, {arg0})")
	public function get(key:K):Null<V>;

	@:nativeFunctionCode("__EnumValueMap_exists__({this}, {arg0})")
	public function exists(key:K):Bool;

	@:nativeFunctionCode("__EnumValueMap_remove__({this}, {arg0})")
	public function remove(key:K):Bool;

	@:nativeFunctionCode("__BrsArrIter__(__EnumValueMap_keys__({this}))")
	public function keys():Iterator<K>;

	@:nativeFunctionCode("__BrsArrIter__({this}.v)")
	public function iterator():Iterator<V>;

	@:nativeFunctionCode("__BrsKVArrayKVIter__({this})")
	public function keyValueIterator():KeyValueIterator<K, V>;

	@:nativeFunctionCode("__BrsKVArrayCopy__({this})")
	public function copy():EnumValueMap<K, V>;

	@:nativeFunctionCode("__BrsKVArrayToString__({this})")
	public function toString():String;

	@:nativeFunctionCode("__BrsKVArrayClear__({this})")
	public function clear():Void;
}

// --- Private typed wrappers for cross-@:brs_global calls ---

private extern class BrsEnumValueMap {
	@:nativeFunctionCode("0 + __EnumValueMap_findIdx__({arg0}, {arg1})")
	static function findIdx(self:Dynamic, key:Dynamic):Int;

	@:nativeFunctionCode("__EnumValueMap_enumEq__({arg0}, {arg1})")
	static function enumEq(a:Dynamic, b:Dynamic):Bool;
}

// --- Shared helpers for {k:[], v:[]} structures (used by EnumValueMap and ObjectMap) ---

@:keep @:brs_global function __BrsKVArrayNew__():Dynamic {
	return untyped __brs__('{"k": [], "v": []}');
}

@:keep @:brs_global function __BrsKVArrayKVIter__(self:Dynamic):Dynamic {
	untyped __brs__('
		__kvi = {
			"d": {0},
			"i": 0,
			"hasNext": function() as Boolean
				return m.i < m.d.k.Count()
			end function,
			"next": function() as Object
				__key = m.d.k[m.i]
				__val = m.d.v[m.i]
				m.i = m.i + 1
				return {"key": __key, "value": __val}
			end function
		}
	', self);
	return untyped __brs__('__kvi');
}

@:keep @:brs_global function __BrsKVArrayCopy__(self:Dynamic):Dynamic {
	var ka:Dynamic = untyped __brs__('[]');
	brs.Native.append(ka, brs.Native.fieldGet(self, "k"));
	var va:Dynamic = untyped __brs__('[]');
	brs.Native.append(va, brs.Native.fieldGet(self, "v"));
	return untyped __brs__('{"k": {0}, "v": {1}}', ka, va);
}

@:keep @:brs_global function __BrsKVArrayToString__(self:Dynamic):String {
	var keys:Dynamic = brs.Native.fieldGet(self, "k");
	var vals:Dynamic = brs.Native.fieldGet(self, "v");
	var count = brs.Native.count(keys);
	var s = "{";
	var i = 0;
	while (i < count) {
		if (i > 0) s = s + ", ";
		var ki:Dynamic = brs.Native.arrayGet(keys, i);
		var vi:Dynamic = brs.Native.arrayGet(vals, i);
		s = s + brs.Native.dynToStr(ki) + " => " + brs.Native.dynToStr(vi);
		i = i + 1;
	}
	return s + "}";
}

@:keep @:brs_global function __BrsKVArrayClear__(self:Dynamic):Dynamic {
	brs.Native.fieldSet(self, "k", untyped __brs__('[]'));
	brs.Native.fieldSet(self, "v", untyped __brs__('[]'));
	return brs.Native.invalid();
}

// --- EnumValueMap-specific functions ---

@:keep @:brs_global function __EnumValueMap_enumEq__(a:Dynamic, b:Dynamic):Dynamic {
	var ta:String = brs.Native.typeOf(a);
	var tb:String = brs.Native.typeOf(b);
	if (ta != tb) return false;
	if (ta == "roAssociativeArray") {
		var hasIdxA:Bool = brs.Native.doesExist(a, "_index");
		var hasIdxB:Bool = brs.Native.doesExist(b, "_index");
		if (hasIdxA != true) return false;
		if (hasIdxB != true) return false;
		var idxA:String = brs.Native.fieldGet(a, "_index");
		var idxB:String = brs.Native.fieldGet(b, "_index");
		if (idxA != idxB) return false;
		var hasParamsA:Bool = brs.Native.doesExist(a, "params");
		var hasParamsB:Bool = brs.Native.doesExist(b, "params");
		if (hasParamsA == true) {
			if (hasParamsB == true) {
				var paramsA:Dynamic = brs.Native.fieldGet(a, "params");
				var paramsB:Dynamic = brs.Native.fieldGet(b, "params");
				var countA:Int = brs.Native.count(paramsA);
				var countB:Int = brs.Native.count(paramsB);
				if (countA != countB) return false;
				var i = 0;
				while (i < countA) {
					var paramA:Dynamic = brs.Native.arrayGet(paramsA, i);
					var paramB:Dynamic = brs.Native.arrayGet(paramsB, i);
					var eq:Bool = BrsEnumValueMap.enumEq(paramA, paramB);
					if (eq != true) return false;
					i = i + 1;
				}
			}
		}
		return true;
	}
	return brs.Native.eq(a, b);
}

@:keep @:brs_global function __EnumValueMap_findIdx__(self:Dynamic, key:Dynamic):Dynamic {
	var keys:Dynamic = brs.Native.fieldGet(self, "k");
	var count = brs.Native.count(keys);
	var i = 0;
	while (i < count) {
		var ki:Dynamic = brs.Native.arrayGet(keys, i);
		var eq:Bool = BrsEnumValueMap.enumEq(ki, key);
		if (eq == true) return i;
		i = i + 1;
	}
	return -1;
}

@:keep @:brs_global function __EnumValueMap_set__(self:Dynamic, key:Dynamic, value:Dynamic):Dynamic {
	var idx:Int = BrsEnumValueMap.findIdx(self, key);
	var keys:Dynamic = brs.Native.fieldGet(self, "k");
	var vals:Dynamic = brs.Native.fieldGet(self, "v");
	if (idx >= 0) {
		brs.Native.arraySet(vals, idx, value);
	} else {
		brs.Native.push(keys, key);
		brs.Native.push(vals, value);
	}
	return brs.Native.invalid();
}

@:keep @:brs_global function __EnumValueMap_get__(self:Dynamic, key:Dynamic):Dynamic {
	var idx:Int = BrsEnumValueMap.findIdx(self, key);
	if (idx >= 0) {
		return brs.Native.arrayGet(brs.Native.fieldGet(self, "v"), idx);
	}
	return brs.Native.invalid();
}

@:keep @:brs_global function __EnumValueMap_exists__(self:Dynamic, key:Dynamic):Bool {
	var idx:Int = BrsEnumValueMap.findIdx(self, key);
	return idx >= 0;
}

@:keep @:brs_global function __EnumValueMap_remove__(self:Dynamic, key:Dynamic):Bool {
	var idx:Int = BrsEnumValueMap.findIdx(self, key);
	if (idx >= 0) {
		brs.Native.delete(brs.Native.fieldGet(self, "k"), idx);
		brs.Native.delete(brs.Native.fieldGet(self, "v"), idx);
		return true;
	}
	return false;
}

@:keep @:brs_global function __EnumValueMap_keys__(self:Dynamic):Dynamic {
	var ka:Dynamic = untyped __brs__('[]');
	brs.Native.append(ka, brs.Native.fieldGet(self, "k"));
	return ka;
}
