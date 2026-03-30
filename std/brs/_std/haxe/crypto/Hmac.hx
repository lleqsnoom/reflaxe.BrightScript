package haxe.crypto;

extern class Hmac {
	@:nativeFunctionCode("__Hmac_new__({arg0})")
	public function new(method:HashMethod);

	@:nativeFunctionCode("__Hmac_make__({this}, {arg0}, {arg1})")
	public function make(key:haxe.io.Bytes, msg:haxe.io.Bytes):haxe.io.Bytes;
}

@:keep @:brs_global function __Hmac_new__(method:Dynamic):Dynamic {
	return untyped __brs__('{method: {0}}', method);
}

@:keep @:brs_global function __Hmac_make__(self:Dynamic, key:Dynamic, msg:Dynamic):Dynamic {
	untyped __brs__('
		__blockSize = 64
		__m = {0}.method._index
		__k = CreateObject("roByteArray")
		for __i = 0 to {1}.Count() - 1 : __k.Push({1}[__i]) : end for
		if __k.Count() > __blockSize then
			if __m = 0 then __k = __Md5_digest__(__k)
			if __m = 1 then __k = __Sha1_digest__(__k)
			if __m = 2 then __k = __Sha256_digest__(__k, 256)
		end if
		while __k.Count() < __blockSize : __k.Push(0) : end while
		__ipad = CreateObject("roByteArray")
		__opad = CreateObject("roByteArray")
		for __i = 0 to __blockSize - 1
			__ipad.Push((__crypto_xor__(__k[__i], &h36) Or 0) And &hFF)
			__opad.Push((__crypto_xor__(__k[__i], &h5c) Or 0) And &hFF)
		end for
		__inner = CreateObject("roByteArray")
		for __i = 0 to __ipad.Count() - 1 : __inner.Push(__ipad[__i]) : end for
		for __i = 0 to {2}.Count() - 1 : __inner.Push({2}[__i]) : end for
		if __m = 0 then __innerHash = __Md5_digest__(__inner)
		if __m = 1 then __innerHash = __Sha1_digest__(__inner)
		if __m = 2 then __innerHash = __Sha256_digest__(__inner, 256)
		__outer = CreateObject("roByteArray")
		for __i = 0 to __opad.Count() - 1 : __outer.Push(__opad[__i]) : end for
		for __i = 0 to __innerHash.Count() - 1 : __outer.Push(__innerHash[__i]) : end for
		if __m = 0 then __result = __Md5_digest__(__outer)
		if __m = 1 then __result = __Sha1_digest__(__outer)
		if __m = 2 then __result = __Sha256_digest__(__outer, 256)
	', self, key, msg);
	return untyped __brs__('__result');
}
