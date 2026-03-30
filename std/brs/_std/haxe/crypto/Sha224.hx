package haxe.crypto;

extern class Sha224 {
	@:nativeFunctionCode("__Sha224_encode__({arg0})")
	public static function encode(s:String):String;

	@:nativeFunctionCode("__Sha224_make__({arg0})")
	public static function make(b:haxe.io.Bytes):haxe.io.Bytes;
}

@:keep @:brs_global function __Sha224_encode__(inputStr:String):String {
	untyped __brs__('
		__msg = CreateObject("roByteArray")
		__msg.FromAsciiString({0})
		__ba = __Sha256_digest__(__msg, 224)
		__result = ""
		for __wi = 0 to 6
			__w = ((__ba[__wi*4] << 24) Or (__ba[__wi*4+1] << 16) Or (__ba[__wi*4+2] << 8) Or __ba[__wi*4+3]) Or 0
			__result = __result + __crypto_toHex32BE__(__w)
		end for
	', inputStr);
	return untyped __brs__('__result');
}

@:keep @:brs_global function __Sha224_make__(ba:Dynamic):Dynamic {
	return untyped __brs__('__Sha256_digest__({0}, 224)', ba);
}
