package haxe.crypto;

extern class Crc32 {
	@:nativeFunctionCode("__Crc32_new__()")
	public function new();

	@:nativeFunctionCode("__Crc32_update__({this}, {arg0}, {arg1}, {arg2})")
	public function update(data:haxe.io.Bytes, pos:Int, len:Int):Void;

	@:nativeFunctionCode("__crypto_xor__({this}.crc, &hFFFFFFFF Or 0) Or 0")
	public function get():Int;

	@:nativeFunctionCode("__Crc32_make__({arg0})")
	public static function make(data:haxe.io.Bytes):Int;
}

@:keep @:brs_global function __Crc32_initTable__():Dynamic {
	untyped __brs__('
		__tbl = CreateObject("roArray", 256, false)
		for __n = 0 to 255
			__c = __n
			for __k = 0 to 7
				if (__c And 1) <> 0 then
					__c = __crypto_xor__((&hEDB88320 Or 0), (__c >> 1)) Or 0
				else
					__c = (__c >> 1) Or 0
				end if
			end for
			__tbl[__n] = __c
		end for
	');
	return untyped __brs__('__tbl');
}

@:keep @:brs_global function __Crc32_new__():Dynamic {
	untyped __brs__('
		if GetGlobalAA().DoesExist("__crc32_table__") = false then
			GetGlobalAA().__crc32_table__ = __Crc32_initTable__()
		end if
		__inst = {crc: &hFFFFFFFF Or 0}
	');
	return untyped __brs__('__inst');
}

@:keep @:brs_global function __Crc32_update__(self:Dynamic, data:Dynamic, pos:Int, len:Int) {
	untyped __brs__('
		__tbl = GetGlobalAA().__crc32_table__
		__c = {0}.crc Or 0
		__loopStart = {2} Or 0
		__loopEnd = (({2} Or 0) + ({3} Or 0) - 1) Or 0
		for __i = __loopStart to __loopEnd
			__byte = {1}[__i] Or 0
			__idx = (__crypto_xor__(__c, __byte) Or 0) And &hFF
			__c = __crypto_xor__(__tbl[__idx], ((__c >> 8) Or 0)) Or 0
		end for
		{0}.crc = __c
	', self, data, pos, len);
}

@:keep @:brs_global function __Crc32_make__(data:Dynamic):Int {
	untyped __brs__('
		__obj = __Crc32_new__()
		__Crc32_update__(__obj, {0}, 0, {0}.Count())
		__result = __crypto_xor__(__obj.crc, &hFFFFFFFF Or 0) Or 0
	', data);
	return untyped __brs__('__result');
}
