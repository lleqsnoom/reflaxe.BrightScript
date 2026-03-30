package haxe.ds;

extern class List<T> {
	@:nativeFunctionCode("{this}.Count()")
	public var length(default, null):Int;

	@:nativeFunctionCode("[]")
	public function new();

	@:nativeFunctionCode("{this}.Push({arg0})")
	public function add(item:T):Void;

	@:nativeFunctionCode("{this}.Unshift({arg0})")
	public function push(item:T):Void;

	@:nativeFunctionCode("__List_first__({this})")
	public function first():Null<T>;

	@:nativeFunctionCode("__List_last__({this})")
	public function last():Null<T>;

	@:nativeFunctionCode("{this}.Shift()")
	public function pop():Null<T>;

	@:nativeFunctionCode("__List_isEmpty__({this})")
	public function isEmpty():Bool;

	@:nativeFunctionCode("__List_clear__({this})")
	public function clear():Void;

	@:nativeFunctionCode("__List_remove__({this}, {arg0})")
	public function remove(v:T):Bool;

	@:runtime public inline function iterator():ListIterator<T> {
		return cast _mkIter();
	}

	@:nativeFunctionCode("__BrsArrIter__({this})")
	private function _mkIter():Dynamic;

	@:runtime public inline function keyValueIterator():ListKeyValueIterator<T> {
		return cast _mkKVIter();
	}

	@:nativeFunctionCode("__List_kviter__({this})")
	private function _mkKVIter():Dynamic;

	@:runtime public inline function map<X>(f:(item:T) -> X):List<X> {
		return cast _map(f);
	}

	@:nativeFunctionCode("__List_map__({this}, {arg0})")
	private function _map(f:Dynamic):Dynamic;

	@:runtime public inline function filter(f:(item:T) -> Bool):List<T> {
		return cast _filter(f);
	}

	@:nativeFunctionCode("__List_filter__({this}, {arg0})")
	private function _filter(f:Dynamic):Dynamic;

	@:nativeFunctionCode("__List_join__({this}, {arg0})")
	public function join(sep:String):String;

	@:nativeFunctionCode("__List_toString__({this})")
	public function toString():String;
}

extern class ListIterator<T> {
	@:nativeFunctionCode("{this}.hasNext()")
	public function hasNext():Bool;

	@:nativeFunctionCode("{this}.next()")
	public function next():T;
}

extern class ListKeyValueIterator<T> {
	@:nativeFunctionCode("{this}.hasNext()")
	public function hasNext():Bool;

	@:nativeFunctionCode("{this}.next()")
	public function next():{key:Int, value:T};
}

// --- BRS global helper functions ---

@:keep @:brs_global function __List_first__(self:Dynamic):Dynamic {
	if (brs.Native.count(self) == 0)
		return untyped __brs__('invalid');
	return brs.Native.arrayGet(self, 0);
}

@:keep @:brs_global function __List_last__(self:Dynamic):Dynamic {
	var cnt:Int = brs.Native.count(self);
	if (cnt == 0)
		return untyped __brs__('invalid');
	return brs.Native.arrayGet(self, cnt - 1);
}

@:keep @:brs_global function __List_isEmpty__(self:Dynamic):Dynamic {
	if (brs.Native.count(self) == 0)
		return untyped __brs__('true');
	return untyped __brs__('false');
}

@:keep @:brs_global function __List_clear__(self:Dynamic):Dynamic {
	untyped __brs__('
	while {0}.Count() > 0
		{0}.Pop()
	end while', self);
	return untyped __brs__('invalid');
}

@:keep @:brs_global function __List_remove__(self:Dynamic, v:Dynamic):Dynamic {
	var cnt:Int = brs.Native.count(self);
	var i:Int = 0;
	while (i < cnt) {
		var elem:Dynamic = brs.Native.arrayGet(self, i);
		var eq:Bool = brs.Native.eq(elem, v);
		if (eq == true) {
			brs.Native.delete(self, i);
			return untyped __brs__('true');
		}
		i = i + 1;
	}
	return untyped __brs__('false');
}

@:keep @:brs_global function __List_map__(self:Dynamic, f:Dynamic):Dynamic {
	var result:Dynamic = brs.Native.emptyArray();
	var cnt:Int = brs.Native.count(self);
	var i:Int = 0;
	while (i < cnt) {
		var v:Dynamic = brs.Native.arrayGet(self, i);
		var mapped:Dynamic = untyped __brs__('{0}({1})', f, v);
		brs.Native.push(result, mapped);
		i = i + 1;
	}
	return result;
}

@:keep @:brs_global function __List_filter__(self:Dynamic, f:Dynamic):Dynamic {
	var result:Dynamic = brs.Native.emptyArray();
	var cnt:Int = brs.Native.count(self);
	var i:Int = 0;
	while (i < cnt) {
		var v:Dynamic = brs.Native.arrayGet(self, i);
		var matches:Dynamic = untyped __brs__('{0}({1})', f, v);
		if (matches == true)
			brs.Native.push(result, v);
		i = i + 1;
	}
	return result;
}

@:keep @:brs_global function __List_join__(self:Dynamic, sep:String):String {
	var cnt:Int = brs.Native.count(self);
	var s:String = "";
	var i:Int = 0;
	while (i < cnt) {
		if (i > 0)
			s = s + sep;
		var elemStr:String = brs.Native.dynToStr(brs.Native.arrayGet(self, i));
		untyped __brs__('{0} = {0} + {1}.Trim()', s, elemStr);
		i = i + 1;
	}
	return s;
}

@:keep @:brs_global function __List_toString__(self:Dynamic):String {
	var cnt:Int = brs.Native.count(self);
	var s:String = "{";
	var i:Int = 0;
	while (i < cnt) {
		if (i > 0)
			s = s + ", ";
		var elemStr:String = brs.Native.dynToStr(brs.Native.arrayGet(self, i));
		untyped __brs__('{0} = {0} + {1}.Trim()', s, elemStr);
		i = i + 1;
	}
	return s + "}";
}

@:keep @:brs_global function __List_kviter__(self:Dynamic):Dynamic {
	untyped __brs__('
		__lkvi = {
			"a": {0},
			"i": 0,
			"hasNext": function() as Boolean
				return m.i < m.a.Count()
			end function,
			"next": function() as Object
				__val = m.a[m.i]
				__idx = m.i
				m.i = m.i + 1
				return {"key": __idx, "value": __val}
			end function
		}
	', self);
	return untyped __brs__('__lkvi');
}
