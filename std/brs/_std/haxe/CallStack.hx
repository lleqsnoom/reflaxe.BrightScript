package haxe;

/**
	Elements returned by `CallStack` methods.
**/
enum StackItem {
	CFunction;
	Module(m:String);
	FilePos(s:Null<StackItem>, file:String, line:Int, ?column:Int);
	Method(classname:Null<String>, method:String);
	LocalFunction(?v:Int);
}

/**
	Get information about the call stack.
	BrightScript has no native stack trace API — all methods return empty data.
**/
@:allow(haxe.Exception)
@:using(haxe.CallStack)
abstract CallStack(Array<StackItem>) from Array<StackItem> {
	public var length(get, never):Int;

	inline function get_length():Int
		return this.length;

	public static inline function callStack():Array<StackItem> {
		return [];
	}

	public static inline function exceptionStack(fullStack = false):Array<StackItem> {
		return [];
	}

	@:keep static public inline function toString(stack:CallStack):String {
		return "";
	}

	public inline function subtract(stack:CallStack):CallStack {
		return cast this;
	}

	public inline function copy():CallStack {
		return cast [];
	}

	@:arrayAccess public inline function get(index:Int):StackItem {
		return this[index];
	}

	inline function asArray():Array<StackItem> {
		return this;
	}
}
