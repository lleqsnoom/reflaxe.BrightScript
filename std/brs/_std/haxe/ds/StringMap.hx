package haxe.ds;

extern class StringMap<T> implements haxe.Constraints.IMap<String, T> {
	@:nativeFunctionCode("__StringMap_new__()")
	public function new():Void;

	@:nativeFunctionCode("{this}.AddReplace({arg0}, {arg1})")
	public function set(key:String, value:T):Void;

	@:nativeFunctionCode("{this}.Lookup({arg0})")
	public function get(key:String):Null<T>;

	@:nativeFunctionCode("{this}.DoesExist({arg0})")
	public function exists(key:String):Bool;

	@:nativeFunctionCode("__StringMap_remove__({this}, {arg0})")
	public function remove(key:String):Bool;

	@:nativeFunctionCode("__BrsArrIter__({this}.Keys())")
	public function keys():Iterator<String>;

	@:nativeFunctionCode("__BrsArrIter__({this}.Items())")
	public function iterator():Iterator<T>;

	@:nativeFunctionCode("__BrsKVIter__({this})")
	public function keyValueIterator():KeyValueIterator<String, T>;

	@:nativeFunctionCode("__StringMap_copy__({this})")
	public function copy():StringMap<T>;

	@:nativeFunctionCode("__StringMap_toString__({this})")
	public function toString():String;

	@:nativeFunctionCode("{this}.Clear()")
	public function clear():Void;
}

@:keep @:brs_global function __StringMap_new__():Dynamic {
	var d:Dynamic = brs.Native.emptyAA();
	brs.Native.setCaseSensitive(d);
	return d;
}

@:keep @:brs_global function __StringMap_remove__(self:Dynamic, key:String):Bool {
	var exists:Bool = brs.Native.doesExist(self, key);
	if (exists == true) {
		brs.Native.delete(self, key);
		return true;
	}
	return false;
}

@:keep @:brs_global function __StringMap_copy__(self:Dynamic):Dynamic {
	var c:Dynamic = brs.Native.emptyAA();
	brs.Native.setCaseSensitive(c);
	brs.Native.append(c, self);
	return c;
}

@:keep @:brs_global function __BrsArrIter__(arr:Dynamic):Dynamic {
	untyped __brs__('
		__iter = {
			"a": {0},
			"i": 0,
			"hasNext": function() as Boolean
				return m.i < m.a.Count()
			end function,
			"next": function() as Dynamic
				__v = m.a[m.i]
				m.i = m.i + 1
				return __v
			end function
		}
	', arr);
	return untyped __brs__('__iter');
}

@:keep @:brs_global function __BrsKVIter__(self:Dynamic):Dynamic {
	untyped __brs__('
		__kvi_k = {0}.Keys()
		__kvi = {
			"k": __kvi_k,
			"d": {0},
			"i": 0,
			"hasNext": function() as Boolean
				return m.i < m.k.Count()
			end function,
			"next": function() as Object
				__key = m.k[m.i]
				__val = m.d.Lookup(__key)
				m.i = m.i + 1
				return {"key": __key, "value": __val}
			end function
		}
	', self);
	return untyped __brs__('__kvi');
}

@:keep @:brs_global function __StringMap_toString__(self:Dynamic):String {
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
