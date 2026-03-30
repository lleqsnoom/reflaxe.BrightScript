package;

extern class Lambda {
	@:nativeFunctionCode("__Lambda_array__({arg0})")
	public static function array<A>(it:Iterable<A>):Array<A>;

	@:nativeFunctionCode("__Lambda_map__({arg0}, {arg1})")
	public static function map<A, B>(it:Iterable<A>, f:(item:A) -> B):Array<B>;

	@:nativeFunctionCode("__Lambda_mapi__({arg0}, {arg1})")
	public static function mapi<A, B>(it:Iterable<A>, f:(index:Int, item:A) -> B):Array<B>;

	@:nativeFunctionCode("__Lambda_flatMap__({arg0}, {arg1})")
	public static function flatMap<A, B>(it:Iterable<A>, f:(item:A) -> Iterable<B>):Array<B>;

	@:nativeFunctionCode("__Lambda_filter__({arg0}, {arg1})")
	public static function filter<A>(it:Iterable<A>, f:(item:A) -> Bool):Array<A>;

	@:nativeFunctionCode("__Lambda_fold__({arg0}, {arg1}, {arg2})")
	public static function fold<A, B>(it:Iterable<A>, f:(item:A, result:B) -> B, first:B):B;

	@:nativeFunctionCode("__Lambda_foldi__({arg0}, {arg1}, {arg2})")
	public static function foldi<A, B>(it:Iterable<A>, f:(item:A, result:B, index:Int) -> B, first:B):B;

	@:runtime public inline static function count<A>(it:Iterable<A>, ?pred:(item:A) -> Bool):Int {
		return _count(it, pred);
	}

	@:nativeFunctionCode("__Lambda_count__({arg0}, {arg1})")
	private static function _count(it:Dynamic, pred:Dynamic):Int;

	@:nativeFunctionCode("__Lambda_find__({arg0}, {arg1})")
	public static function find<T>(it:Iterable<T>, f:(item:T) -> Bool):Null<T>;

	@:nativeFunctionCode("__Lambda_findIndex__({arg0}, {arg1})")
	public static function findIndex<T>(it:Iterable<T>, f:(item:T) -> Bool):Int;

	@:nativeFunctionCode("__Lambda_exists__({arg0}, {arg1})")
	public static function exists<A>(it:Iterable<A>, f:(item:A) -> Bool):Bool;

	@:nativeFunctionCode("__Lambda_foreach__({arg0}, {arg1})")
	public static function foreach<A>(it:Iterable<A>, f:(item:A) -> Bool):Bool;

	@:nativeFunctionCode("__Lambda_iter__({arg0}, {arg1})")
	public static function iter<A>(it:Iterable<A>, f:(item:A) -> Void):Void;

	@:nativeFunctionCode("__Lambda_empty__({arg0})")
	public static function empty<T>(it:Iterable<T>):Bool;

	@:nativeFunctionCode("__Lambda_indexOf__({arg0}, {arg1})")
	public static function indexOf<T>(it:Iterable<T>, v:T):Int;

	@:nativeFunctionCode("__Lambda_concat__({arg0}, {arg1})")
	public static function concat<T>(a:Iterable<T>, b:Iterable<T>):Array<T>;

	@:nativeFunctionCode("__Lambda_flatten__({arg0})")
	public static function flatten<A>(it:Iterable<Iterable<A>>):Array<A>;

	@:nativeFunctionCode("__Lambda_has__({arg0}, {arg1})")
	public static function has<A>(it:Iterable<A>, elt:A):Bool;
}

@:keep @:brs_global function __Lambda_array__(it:Dynamic):Dynamic {
	var result:Dynamic = brs.Native.emptyArray();
	var cnt:Int = brs.Native.count(it);
	var i:Int = 0;
	while (i < cnt) {
		brs.Native.push(result, brs.Native.arrayGet(it, i));
		i = i + 1;
	}
	return result;
}

@:keep @:brs_global function __Lambda_map__(it:Dynamic, f:Dynamic):Dynamic {
	var result:Dynamic = brs.Native.emptyArray();
	var cnt:Int = brs.Native.count(it);
	var i:Int = 0;
	while (i < cnt) {
		var v:Dynamic = brs.Native.arrayGet(it, i);
		var mapped:Dynamic = untyped __brs__('{0}({1})', f, v);
		brs.Native.push(result, mapped);
		i = i + 1;
	}
	return result;
}

@:keep @:brs_global function __Lambda_mapi__(it:Dynamic, f:Dynamic):Dynamic {
	var result:Dynamic = brs.Native.emptyArray();
	var cnt:Int = brs.Native.count(it);
	var i:Int = 0;
	while (i < cnt) {
		var v:Dynamic = brs.Native.arrayGet(it, i);
		var mapped:Dynamic = untyped __brs__('{0}({1}, {2})', f, i, v);
		brs.Native.push(result, mapped);
		i = i + 1;
	}
	return result;
}

@:keep @:brs_global function __Lambda_flatMap__(it:Dynamic, f:Dynamic):Dynamic {
	var result:Dynamic = brs.Native.emptyArray();
	var cnt:Int = brs.Native.count(it);
	var i:Int = 0;
	while (i < cnt) {
		var v:Dynamic = brs.Native.arrayGet(it, i);
		var inner:Dynamic = untyped __brs__('{0}({1})', f, v);
		var innerCnt:Int = brs.Native.count(inner);
		var j:Int = 0;
		while (j < innerCnt) {
			brs.Native.push(result, brs.Native.arrayGet(inner, j));
			j = j + 1;
		}
		i = i + 1;
	}
	return result;
}

@:keep @:brs_global function __Lambda_filter__(it:Dynamic, f:Dynamic):Dynamic {
	var result:Dynamic = brs.Native.emptyArray();
	var cnt:Int = brs.Native.count(it);
	var i:Int = 0;
	while (i < cnt) {
		var v:Dynamic = brs.Native.arrayGet(it, i);
		var matches:Dynamic = untyped __brs__('{0}({1})', f, v);
		if (matches == true)
			brs.Native.push(result, v);
		i = i + 1;
	}
	return result;
}

@:keep @:brs_global function __Lambda_fold__(it:Dynamic, f:Dynamic, first:Dynamic):Dynamic {
	var acc:Dynamic = first;
	var cnt:Int = brs.Native.count(it);
	var i:Int = 0;
	while (i < cnt) {
		var v:Dynamic = brs.Native.arrayGet(it, i);
		acc = untyped __brs__('{0}({1}, {2})', f, v, acc);
		i = i + 1;
	}
	return acc;
}

@:keep @:brs_global function __Lambda_foldi__(it:Dynamic, f:Dynamic, first:Dynamic):Dynamic {
	var acc:Dynamic = first;
	var cnt:Int = brs.Native.count(it);
	var i:Int = 0;
	while (i < cnt) {
		var v:Dynamic = brs.Native.arrayGet(it, i);
		acc = untyped __brs__('{0}({1}, {2}, {3})', f, v, acc, i);
		i = i + 1;
	}
	return acc;
}

@:keep @:brs_global function __Lambda_count__(it:Dynamic, pred:Dynamic):Int {
	var n:Int = 0;
	var cnt:Int = brs.Native.count(it);
	var i:Int = 0;
	untyped __brs__('
	if {0} <> invalid then
		while {1} < {2}
			v = {3}[{1}]
			if {0}(v) = true then
				{4} = {4} + 1
			end if
			{1} = {1} + 1
		end while
	else
		{4} = {2}
	end if', pred, i, cnt, it, n);
	return n;
}

@:keep @:brs_global function __Lambda_find__(it:Dynamic, f:Dynamic):Dynamic {
	var cnt:Int = brs.Native.count(it);
	var i:Int = 0;
	while (i < cnt) {
		var v:Dynamic = brs.Native.arrayGet(it, i);
		var matches:Dynamic = untyped __brs__('{0}({1})', f, v);
		if (matches == true)
			return v;
		i = i + 1;
	}
	return untyped __brs__('invalid');
}

@:keep @:brs_global function __Lambda_findIndex__(it:Dynamic, f:Dynamic):Int {
	var cnt:Int = brs.Native.count(it);
	var i:Int = 0;
	while (i < cnt) {
		var v:Dynamic = brs.Native.arrayGet(it, i);
		var matches:Dynamic = untyped __brs__('{0}({1})', f, v);
		if (matches == true)
			return i;
		i = i + 1;
	}
	return -1;
}

@:keep @:brs_global function __Lambda_exists__(it:Dynamic, f:Dynamic):Dynamic {
	var cnt:Int = brs.Native.count(it);
	var i:Int = 0;
	while (i < cnt) {
		var v:Dynamic = brs.Native.arrayGet(it, i);
		var matches:Dynamic = untyped __brs__('{0}({1})', f, v);
		if (matches == true)
			return untyped __brs__('true');
		i = i + 1;
	}
	return untyped __brs__('false');
}

@:keep @:brs_global function __Lambda_foreach__(it:Dynamic, f:Dynamic):Dynamic {
	var cnt:Int = brs.Native.count(it);
	var i:Int = 0;
	while (i < cnt) {
		var v:Dynamic = brs.Native.arrayGet(it, i);
		var matches:Dynamic = untyped __brs__('{0}({1})', f, v);
		if (matches != true)
			return untyped __brs__('false');
		i = i + 1;
	}
	return untyped __brs__('true');
}

@:keep @:brs_global function __Lambda_iter__(it:Dynamic, f:Dynamic):Dynamic {
	var cnt:Int = brs.Native.count(it);
	var i:Int = 0;
	while (i < cnt) {
		var v:Dynamic = brs.Native.arrayGet(it, i);
		untyped __brs__('{0}({1})', f, v);
		i = i + 1;
	}
	return untyped __brs__('invalid');
}

@:keep @:brs_global function __Lambda_empty__(it:Dynamic):Dynamic {
	var cnt:Int = brs.Native.count(it);
	if (cnt == 0)
		return untyped __brs__('true');
	return untyped __brs__('false');
}

@:keep @:brs_global function __Lambda_indexOf__(it:Dynamic, v:Dynamic):Int {
	var cnt:Int = brs.Native.count(it);
	var i:Int = 0;
	while (i < cnt) {
		var elem:Dynamic = brs.Native.arrayGet(it, i);
		var eq:Bool = brs.Native.eq(elem, v);
		if (eq == true)
			return i;
		i = i + 1;
	}
	return -1;
}

@:keep @:brs_global function __Lambda_concat__(a:Dynamic, b:Dynamic):Dynamic {
	var result:Dynamic = brs.Native.emptyArray();
	var cnt:Int = brs.Native.count(a);
	var i:Int = 0;
	while (i < cnt) {
		brs.Native.push(result, brs.Native.arrayGet(a, i));
		i = i + 1;
	}
	var cnt2:Int = brs.Native.count(b);
	var j:Int = 0;
	while (j < cnt2) {
		brs.Native.push(result, brs.Native.arrayGet(b, j));
		j = j + 1;
	}
	return result;
}

@:keep @:brs_global function __Lambda_flatten__(it:Dynamic):Dynamic {
	var result:Dynamic = brs.Native.emptyArray();
	var outerCnt:Int = brs.Native.count(it);
	var i:Int = 0;
	while (i < outerCnt) {
		var inner:Dynamic = brs.Native.arrayGet(it, i);
		var innerCnt:Int = brs.Native.count(inner);
		var j:Int = 0;
		while (j < innerCnt) {
			brs.Native.push(result, brs.Native.arrayGet(inner, j));
			j = j + 1;
		}
		i = i + 1;
	}
	return result;
}

@:keep @:brs_global function __Lambda_has__(it:Dynamic, elt:Dynamic):Dynamic {
	var cnt:Int = brs.Native.count(it);
	var i:Int = 0;
	while (i < cnt) {
		var v:Dynamic = brs.Native.arrayGet(it, i);
		var eq:Bool = brs.Native.eq(v, elt);
		if (eq == true)
			return untyped __brs__('true');
		i = i + 1;
	}
	return untyped __brs__('false');
}

