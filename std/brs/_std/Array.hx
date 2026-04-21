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
		var i = 0;
		while (i < len) {
			if (i > 0)
				result += sep;
			result += Std.string(get(i));
			i++;
		}
		return result;
	}

	@:nativeFunctionCode("{this}[{arg0}]")
	private function get(index:Int):T;

	@:nativeFunctionCode("{this}[{arg0}] = {arg1}")
	private function setAt(index:Int, x:T):Void;

	@:nativeFunctionCode("{this}.Pop()")
	public function pop():Null<T>;

	@:nativeFunctionCode("{this}.Push({arg0})")
	public function push(x:T):Int;

	@:runtime inline public function reverse():Void {
		final len = length;
		final half = Std.int(len / 2);
		var i = 0;
		while (i < half) {
			final j = len - i - 1;
			final temp = get(i);
			setAt(i, get(j));
			setAt(j, temp);
			i++;
		}
	}

	@:nativeFunctionCode("{this}.Shift()")
	public function shift():Null<T>;

	@:runtime inline public function slice(pos:Int, end:Int = 2147483647):Array<T> {
		final result = [];
		var sI = pos;
		var eI = end;
		if (sI < 0)
			sI = length + sI;
		if (sI < 0)
			sI = 0;
		if (eI < 0)
			eI = length + eI;
		if (eI < 0)
			eI = 0;
		if (eI > length)
			eI = length;
		var i = sI;
		while (i < eI) {
			result.push(get(i));
			i++;
		}
		return result;
	}

	@:runtime public inline function sort(f:(T, T) -> Int):Void {
		var n = length;
		while (n > 1) {
			var i = 0;
			while (i < n - 1) {
				if (f(get(i), get(i + 1)) > 0) {
					var temp = get(i);
					setAt(i, get(i + 1));
					setAt(i + 1, temp);
				}
				i++;
			}
			n--;
		}
	}

	@:runtime public inline function splice(pos:Int, len:Int):Array<T> {
		final result = [];
		var sI = pos;
		if (sI < 0)
			sI = length + sI;
		if (sI < 0)
			sI = 0;
		var i = sI + len - 1;
		if (i >= length)
			i = length - 1;
		while (i >= sI) {
			result.push(get(sI));
			removeAt(sI);
			i--;
		}
		return result;
	}

	@:nativeFunctionCode("{this}.Delete({arg0})")
	private function removeAt(pos:Int):Void;

	@:nativeFunctionCode("str({this})")
	public function toString():String;

	@:nativeFunctionCode("{this}.Unshift({arg0})")
	public function unshift(x:T):Void;

	@:runtime public inline function insert(pos:Int, x:T):Void {
		var p = pos;
		if (p < 0) {
			p = length + p;
			if (p < 0)
				p = 0;
		}
		if (p >= length) {
			push(x);
		} else {
			push(get(length - 1));
			var i = length - 2;
			while (i > p) {
				setAt(i, get(i - 1));
				i--;
			}
			setAt(p, x);
		}
	}

	@:runtime public inline function remove(x:T):Bool {
		var idx = indexOf(x);
		var removed = false;
		if (idx >= 0) {
			removeAt(idx);
			removed = true;
		}
		return removed;
	}

	@:runtime public inline function contains(x:T):Bool {
		var found = false;
		var i = 0;
		while (i < length) {
			if (get(i) == x)
				found = true;
			i++;
		}
		return found;
	}

	@:runtime public inline function indexOf(x:T, fromIndex:Int = 0):Int {
		var i = fromIndex;
		if (i < 0) {
			i = length + i;
			if (i < 0)
				i = 0;
		}
		var result = -1;
		while (i < length) {
			if (get(i) == x) {
				result = i;
				i = length;
			}
			i++;
		}
		return result;
	}

	@:runtime public inline function lastIndexOf(x:T, fromIndex:Int = -1):Int {
		var i = fromIndex;
		if (i < 0)
			i = length + i;
		if (i >= length)
			i = length - 1;
		var result = -1;
		while (i >= 0) {
			if (get(i) == x) {
				result = i;
				i = -1;
			}
			i--;
		}
		return result;
	}

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
		final result = [];
		for (v in this)
			result.push(f(v));
		return result;
	}

	@:runtime inline function filter(f:(T) -> Bool):Array<T> {
		final result = [];
		for (v in this)
			if (f(v) == true)
				result.push(v);
		return result;
	}

	@:runtime public inline function resize(len:Int):Void {
		while (length > len)
			pop();
		while (length < len)
			push(cast null);
	}
}
