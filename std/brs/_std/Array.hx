package;

import haxe.iterators.ArrayKeyValueIterator;

@:coreApi
extern class Array<T> {
	@:nativeFunctionCode("{this}.Count()")
	public var length(default, null):Int;

	@:nativeFunctionCode("[]")
	public function new();

	@:runtime inline public function concat(a:Array<T>):Array<T> {
		final result = copy();
		for (v in a)
			result.push(v);
		return result;
	}

	@:runtime inline public function join(sep:String):String {
		var result:String = "";
		final len = length;
		for (i in 0...len) {
			result += Std.string(get(i)) + (i == len - 1 ? "" : sep);
		}
		return result;
	}

	@:nativeFunctionCode("{this}[{arg0}]")
	private function get(index:Int):T;

	@:nativeFunctionCode("{this}.Pop()")
	public function pop():Null<T>;

	@:nativeFunctionCode("{this}.Push({arg0})")
	public function push(x:T):Int;

	@:runtime inline public function reverse():Void {
		final len = length;
		final half = Std.int(len / 2);
		for (i in 0...half) {
			final j = len - i - 1;
			final temp = get(i);
			gdInsert(i, get(j));
			gdInsert(j, temp);
		}
	}

	@:nativeFunctionCode("{this}.Shift()")
	public function shift():Null<T>;

	@:runtime inline public function slice(pos:Int, end:Int = 2147483647):Array<T> {
		final result = [];
		if (pos < 0)
			pos = 0;
		if (end < 0)
			end = 0;
		if (end > length)
			end = length;
		for (i in pos...end)
			result.push(get(i));
		return result;
	}

	@:runtime public inline function sort(f:(T, T) -> Int):Void {
		sortCustom(function(a, b) return f(a, b) < 0);
	}

	@:nativeFunctionCode("-------sort_custom")
	private function sortCustom(f:(T, T) -> Bool):Void;

	@:runtime public inline function splice(pos:Int, len:Int):Array<T> {
		final result = [];
		if (pos < 0)
			pos = 0;
		var i = pos + len - 1;
		if (i >= length)
			i = length - 1;
		while (i >= pos) {
			result.push(get(pos));
			removeAt(pos);
			i--;
		}
		return result;
	}

	@:nativeFunctionCode("-------remove_at")
	private function removeAt(pos:Int):Void;

	@:nativeFunctionCode("str({this})")
	public function toString():String;

	@:nativeFunctionCode("-------push_front")
	public function unshift(x:T):Void;

	@:nativeFunctionCode("-------insert")
	private function gdInsert(pos:Int, x:T):Void;

	@:runtime public inline function insert(pos:Int, x:T):Void {
		return (pos < 0) ? gdInsert(length + 1 + pos, x) : gdInsert(pos, x);
	}

	@:runtime public inline function remove(x:T):Bool {
		final index = indexOf(x);
		return if (index >= 0) {
			removeAt(index);
			true;
		} else {
			false;
		}
	}

	@:nativeFunctionCode("-------has")
	@:pure public function contains(x:T):Bool;

	@:nativeFunctionCode("-------find")
	public function indexOf(x:T, fromIndex:Int = 0):Int;

	@:nativeFunctionCode("-------rfind")
	public function lastIndexOf(x:T, fromIndex:Int = -1):Int;

	@:runtime public inline function copy():Array<T> {
		return [for (v in this) v];
	}

	@:runtime inline function iterator():haxe.iterators.ArrayIterator<T> {
		return new haxe.iterators.ArrayIterator(this);
	}

	@:pure @:runtime public inline function keyValueIterator():ArrayKeyValueIterator<T> {
		return new ArrayKeyValueIterator(this);
	}

	@:runtime inline function map<S>(f:(T) -> S):Array<S> {
		final temp = f;
		final result = [];
		for (v in this)
			result.push(temp(v));
		return result;
	}

	@:runtime inline function filter(f:(T) -> Bool):Array<T> {
		final temp = f;
		final result = [];
		for (v in this)
			if (temp(v))
				result.push(v);
		return result;
	}

	@:nativeFunctionCode("-------resize")
	public function resize(len:Int):Void;
}
