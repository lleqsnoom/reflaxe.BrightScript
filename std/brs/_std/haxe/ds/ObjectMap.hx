package haxe.ds;

extern class ObjectMap<K:{}, V> implements haxe.Constraints.IMap<K, V> {
	@:nativeFunctionCode("__BrsKVArrayNew__()")
	public function new():Void;

	@:nativeFunctionCode("__ObjectMap_set__({this}, {arg0}, {arg1})")
	public function set(key:K, value:V):Void;

	@:nativeFunctionCode("__ObjectMap_get__({this}, {arg0})")
	public function get(key:K):Null<V>;

	@:nativeFunctionCode("__ObjectMap_exists__({this}, {arg0})")
	public function exists(key:K):Bool;

	@:nativeFunctionCode("__ObjectMap_remove__({this}, {arg0})")
	public function remove(key:K):Bool;

	@:nativeFunctionCode("__BrsArrIter__(__ObjectMap_keys__({this}))")
	public function keys():Iterator<K>;

	@:nativeFunctionCode("__BrsArrIter__({this}.v)")
	public function iterator():Iterator<V>;

	@:nativeFunctionCode("__BrsKVArrayKVIter__({this})")
	public function keyValueIterator():KeyValueIterator<K, V>;

	@:nativeFunctionCode("__BrsKVArrayCopy__({this})")
	public function copy():ObjectMap<K, V>;

	@:nativeFunctionCode("__BrsKVArrayToString__({this})")
	public function toString():String;

	@:nativeFunctionCode("__BrsKVArrayClear__({this})")
	public function clear():Void;
}

// --- Private typed wrappers for cross-@:brs_global calls ---

private extern class BrsObjectMap {
	@:nativeFunctionCode("0 + __ObjectMap_findIdx__({arg0}, {arg1})")
	static function findIdx(self:Dynamic, key:Dynamic):Int;

	@:nativeFunctionCode("__ObjectMap_ensureId__({arg0})")
	static function ensureId(key:Dynamic):Void;
}

@:keep @:brs_global function __ObjectMap_ensureId__(key:Dynamic):Dynamic {
	untyped __brs__('
		if {0}.__hx_id__ = invalid
			if m.__hx_objmap_id__ = invalid then m.__hx_objmap_id__ = 0
			m.__hx_objmap_id__ = m.__hx_objmap_id__ + 1
			{0}.__hx_id__ = m.__hx_objmap_id__
		end if
	', key);
	return brs.Native.invalid();
}

@:keep @:brs_global function __ObjectMap_findIdx__(self:Dynamic, key:Dynamic):Dynamic {
	BrsObjectMap.ensureId(key);
	var kid:Dynamic = brs.Native.fieldGet(key, "__hx_id__");
	var keys:Dynamic = brs.Native.fieldGet(self, "k");
	var count = brs.Native.count(keys);
	var i = 0;
	while (i < count) {
		var hxId:Dynamic = brs.Native.fieldGet(brs.Native.arrayGet(keys, i), "__hx_id__");
		var match:Bool = brs.Native.eq(hxId, kid);
		if (match == true) return i;
		i = i + 1;
	}
	return -1;
}

@:keep @:brs_global function __ObjectMap_set__(self:Dynamic, key:Dynamic, value:Dynamic):Dynamic {
	BrsObjectMap.ensureId(key);
	var idx:Int = BrsObjectMap.findIdx(self, key);
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

@:keep @:brs_global function __ObjectMap_get__(self:Dynamic, key:Dynamic):Dynamic {
	var idx:Int = BrsObjectMap.findIdx(self, key);
	if (idx >= 0) {
		return brs.Native.arrayGet(brs.Native.fieldGet(self, "v"), idx);
	}
	return brs.Native.invalid();
}

@:keep @:brs_global function __ObjectMap_exists__(self:Dynamic, key:Dynamic):Bool {
	var idx:Int = BrsObjectMap.findIdx(self, key);
	return idx >= 0;
}

@:keep @:brs_global function __ObjectMap_remove__(self:Dynamic, key:Dynamic):Bool {
	var idx:Int = BrsObjectMap.findIdx(self, key);
	if (idx >= 0) {
		brs.Native.delete(brs.Native.fieldGet(self, "k"), idx);
		brs.Native.delete(brs.Native.fieldGet(self, "v"), idx);
		return true;
	}
	return false;
}

@:keep @:brs_global function __ObjectMap_keys__(self:Dynamic):Dynamic {
	var keys:Dynamic = brs.Native.fieldGet(self, "k");
	var count = brs.Native.count(keys);
	var ka:Dynamic = brs.Native.emptyArray();
	var i = 0;
	while (i < count) {
		brs.Native.push(ka, brs.Native.arrayGet(keys, i));
		i = i + 1;
	}
	return ka;
}
