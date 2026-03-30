package haxe.crypto;

extern class Sha1 {
	@:nativeFunctionCode("__Sha1_encode__({arg0})")
	public static function encode(s:String):String;

	@:nativeFunctionCode("__Sha1_make__({arg0})")
	public static function make(b:haxe.io.Bytes):haxe.io.Bytes;
}

@:keep @:brs_global function __Sha1_encode__(inputStr:String):String {
	untyped __brs__('
		__msg = CreateObject("roByteArray")
		__msg.FromAsciiString({0})
		__ba = __Sha1_digest__(__msg)
		__result = ""
		for __wi = 0 to 4
			__w = ((__ba[__wi*4] << 24) Or (__ba[__wi*4+1] << 16) Or (__ba[__wi*4+2] << 8) Or __ba[__wi*4+3]) Or 0
			__result = __result + __crypto_toHex32BE__(__w)
		end for
	', inputStr);
	return untyped __brs__('__result');
}

@:keep @:brs_global function __Sha1_make__(ba:Dynamic):Dynamic {
	return untyped __brs__('__Sha1_digest__({0})', ba);
}

@:keep @:brs_global function __Sha1_digest__(msg:Dynamic):Dynamic {
	untyped __brs__('
		__pad = CreateObject("roByteArray")
		for __pi = 0 to {0}.Count() - 1 : __pad.Push({0}[__pi]) : end for
		__origLen = {0}.Count()
		__bitLen = __origLen * 8
		__pad.Push(&h80)
		while __pad.Count() Mod 64 <> 56 : __pad.Push(0) : end while
		__pad.Push(0):__pad.Push(0):__pad.Push(0):__pad.Push(0)
		__pad.Push((__bitLen >> 24) And &hFF) : __pad.Push((__bitLen >> 16) And &hFF)
		__pad.Push((__bitLen >> 8) And &hFF) : __pad.Push(__bitLen And &hFF)
		__h0=&h67452301 Or 0:__h1=&hefcdab89 Or 0:__h2=&h98badcfe Or 0:__h3=&h10325476 Or 0:__h4=&hc3d2e1f0 Or 0
		__numBlk = __pad.Count() / 64
		for __blk = 0 to __numBlk - 1
			__W = CreateObject("roArray", 80, false)
			for __j = 0 to 15
				__base = __blk * 64 + __j * 4
				__W[__j] = ((__pad[__base] << 24) Or (__pad[__base+1] << 16) Or (__pad[__base+2] << 8) Or __pad[__base+3]) Or 0
			end for
			for __j = 16 to 79
				__xv = __crypto_xor__(__crypto_xor__(__crypto_xor__(__W[__j-3], __W[__j-8]), __W[__j-14]), __W[__j-16]) Or 0
				__W[__j] = __crypto_rotl__(__xv, 1) Or 0
			end for
			__a=__h0:__b=__h1:__c=__h2:__d=__h3:__e=__h4
			for __i = 0 to 79
				if __i < 20 then
					__notb = __crypto_not__(__b) Or 0
					__f = (__b And __c) Or (__notb And __d) : __k = &h5a827999 Or 0
				else if __i < 40 then
					__f = __crypto_xor__(__crypto_xor__(__b, __c), __d) Or 0 : __k = &h6ed9eba1 Or 0
				else if __i < 60 then
					__f = (__b And __c) Or (__b And __d) Or (__c And __d) : __k = &h8f1bbcdc Or 0
				else
					__f = __crypto_xor__(__crypto_xor__(__b, __c), __d) Or 0 : __k = &hca62c1d6 Or 0
				end if
				__temp = __crypto_add32__(__crypto_add32__(__crypto_add32__(__crypto_add32__(__crypto_rotl__(__a, 5), __f), __e), __k), __W[__i]) Or 0
				__e=__d:__d=__c
				__c = __crypto_rotl__(__b, 30) Or 0
				__b=__a:__a=__temp
			end for
			__h0=__crypto_add32__(__h0,__a) Or 0:__h1=__crypto_add32__(__h1,__b) Or 0:__h2=__crypto_add32__(__h2,__c) Or 0:__h3=__crypto_add32__(__h3,__d) Or 0:__h4=__crypto_add32__(__h4,__e) Or 0
		end for
		__out = CreateObject("roByteArray")
		__crypto_int32ToBytesBE__(__h0, __out)
		__crypto_int32ToBytesBE__(__h1, __out)
		__crypto_int32ToBytesBE__(__h2, __out)
		__crypto_int32ToBytesBE__(__h3, __out)
		__crypto_int32ToBytesBE__(__h4, __out)
	', msg);
	return untyped __brs__('__out');
}
