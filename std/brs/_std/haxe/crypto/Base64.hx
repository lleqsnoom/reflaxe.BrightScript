package haxe.crypto;

extern class Base64 {
	@:runtime public static inline function encode(bytes:haxe.io.Bytes, complement:Bool = true):String {
		return brsEncode(bytes, complement);
	}

	@:nativeFunctionCode("__Base64_encode__({arg0}, {arg1})")
	private static function brsEncode(bytes:haxe.io.Bytes, complement:Bool):String;

	@:runtime public static inline function decode(str:String, complement:Bool = true):haxe.io.Bytes {
		return brsDecode(str, complement);
	}

	@:nativeFunctionCode("__Base64_decode__({arg0}, {arg1})")
	private static function brsDecode(str:String, complement:Bool):haxe.io.Bytes;

	@:runtime public static inline function urlEncode(bytes:haxe.io.Bytes, complement:Bool = true):String {
		return brsUrlEncode(bytes, complement);
	}

	@:nativeFunctionCode("__Base64_urlEncode__({arg0}, {arg1})")
	private static function brsUrlEncode(bytes:haxe.io.Bytes, complement:Bool):String;

	@:runtime public static inline function urlDecode(str:String, complement:Bool = true):haxe.io.Bytes {
		return brsUrlDecode(str, complement);
	}

	@:nativeFunctionCode("__Base64_urlDecode__({arg0}, {arg1})")
	private static function brsUrlDecode(str:String, complement:Bool):haxe.io.Bytes;
}

@:keep @:brs_global function __Base64_encode__(ba:Dynamic, complement:Dynamic):String {
	untyped __brs__('
		__b64 = {0}.ToBase64String()
		if {1} = false then
			while Right(__b64, 1) = "="
				__b64 = Left(__b64, Len(__b64) - 1)
			end while
		end if
	', ba, complement);
	return untyped __brs__('__b64');
}

@:keep @:brs_global function __Base64_decode__(str:String, complement:Dynamic):Dynamic {
	untyped __brs__('
		__s = {0}
		if {1} = false then
			__rem = Len(__s) Mod 4
			if __rem = 2 then __s = __s + "=="
			if __rem = 3 then __s = __s + "="
		end if
		__ba = CreateObject("roByteArray")
		__ba.FromBase64String(__s)
	', str, complement);
	return untyped __brs__('__ba');
}

@:keep @:brs_global function __Base64_urlEncode__(ba:Dynamic, complement:Dynamic):String {
	untyped __brs__('
		__b64 = {0}.ToBase64String()
		__out = ""
		for __ci = 1 to Len(__b64)
			__ch = Mid(__b64, __ci, 1)
			if __ch = "+" then __ch = "-"
			if __ch = "/" then __ch = "_"
			__out = __out + __ch
		end for
		if {1} = false then
			while Right(__out, 1) = "="
				__out = Left(__out, Len(__out) - 1)
			end while
		end if
	', ba, complement);
	return untyped __brs__('__out');
}

@:keep @:brs_global function __Base64_urlDecode__(str:String, complement:Dynamic):Dynamic {
	untyped __brs__('
		__s = ""
		for __ci = 1 to Len({0})
			__ch = Mid({0}, __ci, 1)
			if __ch = "-" then __ch = "+"
			if __ch = "_" then __ch = "/"
			__s = __s + __ch
		end for
		if {1} = false then
			__rem = Len(__s) Mod 4
			if __rem = 2 then __s = __s + "=="
			if __rem = 3 then __s = __s + "="
		end if
		__ba = CreateObject("roByteArray")
		__ba.FromBase64String(__s)
	', str, complement);
	return untyped __brs__('__ba');
}
