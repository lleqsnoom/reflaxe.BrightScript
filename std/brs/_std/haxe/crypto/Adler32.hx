package haxe.crypto;

extern class Adler32 {
	@:nativeFunctionCode("__Adler32_new__()")
	public function new();

	@:nativeFunctionCode("__Adler32_update__({this}, {arg0}, {arg1}, {arg2})")
	public function update(data:haxe.io.Bytes, pos:Int, len:Int):Void;

	@:nativeFunctionCode("__Adler32_equals__({this}, {arg0})")
	public function equals(other:Adler32):Bool;

	@:nativeFunctionCode("__Adler32_toString__({this})")
	public function toString():String;

	@:nativeFunctionCode("__Adler32_make__({arg0})")
	public static function make(data:haxe.io.Bytes):Adler32;
}

@:keep @:brs_global function __Adler32_new__():Dynamic {
	return untyped __brs__('{a: 1, b: 0}');
}

@:keep @:brs_global function __Adler32_update__(self:Dynamic, data:Dynamic, pos:Int, len:Int) {
	untyped __brs__('
		__a = {0}.a
		__b = {0}.b
		__loopStart = {2} Or 0
		__loopEnd = (({2} Or 0) + ({3} Or 0) - 1) Or 0
		for __i = __loopStart to __loopEnd
			__a = (__a + ({1}[__i] Or 0)) Mod 65521
			__b = (__b + __a) Mod 65521
		end for
		{0}.a = __a
		{0}.b = __b
	', self, data, pos, len);
}

@:keep @:brs_global function __Adler32_equals__(self:Dynamic, other:Dynamic):Bool {
	return untyped __brs__('{0}.a = {1}.a And {0}.b = {1}.b', self, other);
}

@:keep @:brs_global function __Adler32_toString__(self:Dynamic):String {
	untyped __brs__('
		__val = (({0}.b << 16) Or {0}.a) Or 0
		__hex = ""
		__tmp = __val Or 0
		for __di = 0 to 7
			__nib = (__tmp And &hF) Or 0
			if __nib < 10 then __hex = Str(__nib).Trim() + __hex else __hex = Chr(87 + __nib) + __hex
			if __di < 7 then __tmp = (__tmp >> 4) Or 0
		end for
	', self);
	return untyped __brs__('__hex');
}

@:keep @:brs_global function __Adler32_make__(data:Dynamic):Dynamic {
	untyped __brs__('
		__obj = __Adler32_new__()
		__Adler32_update__(__obj, {0}, 0, {0}.Count())
	', data);
	return untyped __brs__('__obj');
}
