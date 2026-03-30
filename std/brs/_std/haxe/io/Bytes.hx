package haxe.io;

extern class Bytes {
	@:nativeFunctionCode("{this}.Count()")
	public var length(default, null):Int;

	@:nativeFunctionCode("{this}[{arg0}]")
	public function get(pos:Int):Int;

	@:nativeFunctionCode("{this}[{arg0}] = {arg1}")
	public function set(pos:Int, v:Int):Void;

	@:nativeFunctionCode("__Bytes_blit__({this}, {arg0}, {arg1}, {arg2}, {arg3})")
	public function blit(pos:Int, src:Bytes, srcpos:Int, len:Int):Void;

	@:nativeFunctionCode("__Bytes_fill__({this}, {arg0}, {arg1}, {arg2})")
	public function fill(pos:Int, len:Int, value:Int):Void;

	@:nativeFunctionCode("__Bytes_sub__({this}, {arg0}, {arg1})")
	public function sub(pos:Int, len:Int):Bytes;

	@:nativeFunctionCode("__Bytes_compare__({this}, {arg0})")
	public function compare(other:Bytes):Int;

	@:runtime public inline function getString(pos:Int, len:Int, ?encoding:Dynamic):String {
		return brsGetString(pos, len);
	}

	@:nativeFunctionCode("__Bytes_getString__({this}, {arg0}, {arg1})")
	private function brsGetString(pos:Int, len:Int):String;

	@:runtime public inline function toString():String {
		return brsToString(this);
	}

	@:nativeFunctionCode("__Bytes_toString__({arg0})")
	private static function brsToString(bytes:Bytes):String;

	@:nativeFunctionCode("__Bytes_toHex__({this})")
	public function toHex():String;

	@:nativeFunctionCode("{this}")
	public function getData():Dynamic;

	@:nativeFunctionCode("__Bytes_getInt32__({this}, {arg0})")
	public function getInt32(pos:Int):Int;

	@:nativeFunctionCode("__Bytes_setInt32__({this}, {arg0}, {arg1})")
	public function setInt32(pos:Int, v:Int):Void;

	@:nativeFunctionCode("__Bytes_getUInt16__({this}, {arg0})")
	public function getUInt16(pos:Int):Int;

	@:nativeFunctionCode("__Bytes_setUInt16__({this}, {arg0}, {arg1})")
	public function setUInt16(pos:Int, v:Int):Void;

	@:nativeFunctionCode("__Bytes_alloc__({arg0})")
	public static function alloc(length:Int):Bytes;

	@:nativeFunctionCode("{arg0}")
	public static function ofData(b:Dynamic):Bytes;

	@:runtime public inline static function ofString(s:String, ?encoding:Dynamic):Bytes {
		return brsOfString(s);
	}

	@:nativeFunctionCode("__Bytes_ofString__({arg0})")
	private static function brsOfString(s:String):Bytes;

	@:nativeFunctionCode("__Bytes_ofHex__({arg0})")
	public static function ofHex(s:String):Bytes;
}

@:keep @:brs_global function __Bytes_alloc__(len:Int):Dynamic {
	untyped __brs__('
		__ba = CreateObject("roByteArray")
		for __i = 0 to {0} - 1
			__ba.Push(0)
		end for
	', len);
	return untyped __brs__('__ba');
}

@:keep @:brs_global function __Bytes_ofString__(s:String):Dynamic {
	untyped __brs__('
		__ba = CreateObject("roByteArray")
		__ba.FromAsciiString({0})
	', s);
	return untyped __brs__('__ba');
}

@:keep @:brs_global function __Bytes_ofHex__(s:String):Dynamic {
	untyped __brs__('
		__ba = CreateObject("roByteArray")
		__ba.FromHexString({0})
	', s);
	return untyped __brs__('__ba');
}

@:keep @:brs_global function __Bytes_blit__(self:Dynamic, dstPos:Int, src:Dynamic, srcPos:Int, len:Int) {
	untyped __brs__('
		for __i = 0 to (0 + {0}) - 1
			{1}[(0 + {2}) + __i] = {3}[(0 + {4}) + __i]
		end for
	', len, self, dstPos, src, srcPos);
}

@:keep @:brs_global function __Bytes_fill__(self:Dynamic, fillPos:Int, len:Int, value:Int) {
	untyped __brs__('
		for __i = 0 to (0 + {0}) - 1
			{1}[(0 + {2}) + __i] = 0 + {3}
		end for
	', len, self, fillPos, value);
}

@:keep @:brs_global function __Bytes_sub__(self:Dynamic, subPos:Int, len:Int):Dynamic {
	untyped __brs__('
		__ba = CreateObject("roByteArray")
		for __i = 0 to (0 + {0}) - 1
			__ba.Push({1}[(0 + {2}) + __i])
		end for
	', len, self, subPos);
	return untyped __brs__('__ba');
}

@:keep @:brs_global function __Bytes_compare__(self:Dynamic, other:Dynamic):Int {
	untyped __brs__('
		__selfLen = {0}.Count()
		__otherLen = {1}.Count()
		__cmpResult = 0
		__minLen = __selfLen
		if __otherLen < __minLen then __minLen = __otherLen
		for __i = 0 to __minLen - 1
			if {0}[__i] < {1}[__i] then
				__cmpResult = -1
				exit for
			else if {0}[__i] > {1}[__i] then
				__cmpResult = 1
				exit for
			end if
		end for
		if __cmpResult = 0 then
			if __selfLen < __otherLen then
				__cmpResult = -1
			else if __selfLen > __otherLen then
				__cmpResult = 1
			end if
		end if
	', self, other);
	return untyped __brs__('__cmpResult');
}

@:keep @:brs_global function __Bytes_getString__(self:Dynamic, strPos:Int, len:Int):String {
	untyped __brs__('
		__s = ""
		for __i = 0 to (0 + {0}) - 1
			__s = __s + Chr({1}[(0 + {2}) + __i])
		end for
	', len, self, strPos);
	return untyped __brs__('__s');
}

@:keep @:brs_global function __Bytes_toString__(self:Dynamic):String {
	untyped __brs__('
		__s = ""
		for __i = 0 to {0}.Count() - 1
			__s = __s + Chr({0}[__i])
		end for
	', self);
	return untyped __brs__('__s');
}

@:keep @:brs_global function __Bytes_toHex__(self:Dynamic):String {
	untyped __brs__('
		__s = ""
		for __i = 0 to {0}.Count() - 1
			__v = {0}[__i]
			__hi = __v >> 4
			__lo = __v And 15
			if __hi < 10 then
				__s = __s + Chr(48 + __hi)
			else
				__s = __s + Chr(87 + __hi)
			end if
			if __lo < 10 then
				__s = __s + Chr(48 + __lo)
			else
				__s = __s + Chr(87 + __lo)
			end if
		end for
	', self);
	return untyped __brs__('__s');
}

@:keep @:brs_global function __Bytes_getInt32__(self:Dynamic, p:Int):Int {
	untyped __brs__('
		__p = 0 + {1}
		__r = {0}[__p] + ({0}[__p + 1] * 256) + ({0}[__p + 2] * 65536) + ({0}[__p + 3] * 16777216)
	', self, p);
	return untyped __brs__('__r');
}

@:keep @:brs_global function __Bytes_setInt32__(self:Dynamic, p:Int, v:Int) {
	untyped __brs__('
		__p = 0 + {1}
		__v = 0 + {2}
		{0}[__p] = __v And 255
		{0}[__p + 1] = (__v >> 8) And 255
		{0}[__p + 2] = (__v >> 16) And 255
		{0}[__p + 3] = (__v >> 24) And 255
	', self, p, v);
}

@:keep @:brs_global function __Bytes_getUInt16__(self:Dynamic, p:Int):Int {
	untyped __brs__('
		__p = 0 + {1}
		__r = {0}[__p] + ({0}[__p + 1] * 256)
	', self, p);
	return untyped __brs__('__r');
}

@:keep @:brs_global function __Bytes_setUInt16__(self:Dynamic, p:Int, v:Int) {
	untyped __brs__('
		__p = 0 + {1}
		__v = 0 + {2}
		{0}[__p] = __v And 255
		{0}[__p + 1] = (__v >> 8) And 255
	', self, p, v);
}
