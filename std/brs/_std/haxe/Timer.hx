package haxe;

import brscompiler.config.Define;

extern class Timer {
	@:nativeFunctionCode("__Timer_new__({arg0})")
	function new(time_ms:Int);

	@:nativeFunctionCode("__Timer_stop__({this})")
	function stop():Void;

	@:nativeFunctionCode("__Timer_stamp__()")
	static function stamp():Float;

	@:nativeFunctionCode("__Timer_delay__({arg0}, {arg1})")
	static function delay(f:() -> Void, time_ms:Int):Timer;

	@:nativeFunctionCode("__Timer_measure__({arg0}, {arg1})")
	static function measure<T>(f:() -> T, ?pos:PosInfos):T;
}

@:keep @:brs_global function __Timer_stamp__():Dynamic {
	untyped __brs__('
		if m.__hx_ts__ = invalid then
			m.__hx_ts__ = CreateObject("roTimespan")
		end if
	');
	return untyped __brs__('m.__hx_ts__.TotalMilliseconds() / 1000.0');
}

@:keep @:brs_global function __Timer_new__(time_ms:Int):Dynamic {
	return untyped __brs__('{"__interval": {0}, "__stopped": false}', time_ms);
}

@:keep @:brs_global function __Timer_stop__(t:Dynamic):Dynamic {
	untyped __brs__('{0}.__stopped = true', t);
	return untyped __brs__('invalid');
}

@:keep @:brs_global function __Timer_delay__(f:Dynamic, time_ms:Int):Dynamic {
	untyped __brs__('
		Sleep({1})
		__callFn0__({2}, {0})
	', f, time_ms, Define.Ctx);
	return untyped __brs__('{"__interval": {0}, "__stopped": true}', time_ms);
}

@:keep @:brs_global function __Timer_measure__(f:Dynamic, pos:Dynamic):Dynamic {
	untyped __brs__('
		__tm_t0 = __Timer_stamp__()
		__tm_result = __callFn0__({0})
		__tm_t1 = __Timer_stamp__()
		__tm_diff = __tm_t1 - __tm_t0
		if {1} <> invalid then
			Print {1}.fileName; ":"; {1}.lineNumber; ": "; Str(__tm_diff).Trim(); "s"
		else
			Print Str(__tm_diff).Trim(); "s"
		end if
	', f, pos);
	return untyped __brs__('__tm_result');
}
