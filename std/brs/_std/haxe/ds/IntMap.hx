package haxe.ds;

extern class IntMap<T> implements haxe.Constraints.IMap<Int, T> {
	@:nativeFunctionCode("__IntMap_new__()")
	public function new():Void;

	@:nativeFunctionCode("{this}.AddReplace(Str({arg0}).Trim(), {arg1})")
	public function set(key:Int, value:T):Void;

	@:nativeFunctionCode("{this}.Lookup(Str({arg0}).Trim())")
	public function get(key:Int):Null<T>;

	@:nativeFunctionCode("{this}.DoesExist(Str({arg0}).Trim())")
	public function exists(key:Int):Bool;

	@:nativeFunctionCode("__IntMap_remove__({this}, {arg0})")
	public function remove(key:Int):Bool;

	@:nativeFunctionCode("__BrsArrIter__(__IntMap_intKeys__({this}))")
	public function keys():Iterator<Int>;

	@:nativeFunctionCode("__BrsArrIter__({this}.Items())")
	public function iterator():Iterator<T>;

	@:nativeFunctionCode("__IntMap_kvIter__({this})")
	public function keyValueIterator():KeyValueIterator<Int, T>;

	@:nativeFunctionCode("__IntMap_copy__({this})")
	public function copy():IntMap<T>;

	@:nativeFunctionCode("__IntMap_toString__({this})")
	public function toString():String;

	@:nativeFunctionCode("{this}.Clear()")
	public function clear():Void;
}

// --- Private typed wrappers for cross-@:brs_global calls ---

private extern class BrsIntMap {
	@:nativeFunctionCode("__IntMap_intKeys__({arg0})")
	static function intKeys(self:Dynamic):Dynamic;
}

@:keep @:brs_global function __IntMap_new__():Dynamic {
	return brs.Native.emptyAA();
}

@:keep @:brs_global function __IntMap_remove__(self:Dynamic, key:Int):Bool {
	var ik:String = brs.Native.intToStr(key);
	var exists:Bool = brs.Native.doesExist(self, ik);
	if (exists == true) {
		brs.Native.delete(self, ik);
		return true;
	}
	return false;
}

@:keep @:brs_global function __IntMap_intKeys__(self:Dynamic):Dynamic {
	var ks:Dynamic = brs.Native.keys(self);
	var count = brs.Native.count(ks);
	var ik:Dynamic = brs.Native.emptyArray();
	var i = 0;
	while (i < count) {
		var intKey:Int = brs.Native.intOfVal(brs.Native.arrayGet(ks, i));
		brs.Native.push(ik, intKey);
		i = i + 1;
	}
	return ik;
}

// kvIter must stay as BRS — inline BRS function literals can't be expressed in Haxe
@:keep @:brs_global function __IntMap_kvIter__(self:Dynamic):Dynamic {
	untyped __brs__('
		__kvi_k = __IntMap_intKeys__({0})
		__kvi = {
			"k": __kvi_k,
			"d": {0},
			"i": 0,
			"hasNext": function() as Boolean
				return m.i < m.k.Count()
			end function,
			"next": function() as Object
				__key = m.k[m.i]
				__val = m.d.Lookup(Str(__key).Trim())
				m.i = m.i + 1
				return {"key": __key, "value": __val}
			end function
		}
	', self);
	return untyped __brs__('__kvi');
}

@:keep @:brs_global function __IntMap_copy__(self:Dynamic):Dynamic {
	var c:Dynamic = brs.Native.emptyAA();
	brs.Native.append(c, self);
	return c;
}

@:keep @:brs_global function __IntMap_toString__(self:Dynamic):String {
	var ks:Dynamic = brs.Native.keys(self);
	var count = brs.Native.count(ks);
	var s = "{";
	var i = 0;
	while (i < count) {
		if (i > 0) s = s + ", ";
		var k:String = brs.Native.arrayGet(ks, i);
		var v:String = brs.Native.dynToStr(brs.Native.lookup(self, k));
		s = s + k + " => " + v;
		i = i + 1;
	}
	return s + "}";
}
