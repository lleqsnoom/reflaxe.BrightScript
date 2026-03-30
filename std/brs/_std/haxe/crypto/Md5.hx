package haxe.crypto;

extern class Md5 {
	@:nativeFunctionCode("__Md5_encode__({arg0})")
	public static function encode(s:String):String;

	@:nativeFunctionCode("__Md5_make__({arg0})")
	public static function make(b:haxe.io.Bytes):haxe.io.Bytes;
}

// --- Shared crypto helpers (used by Md5, Sha1, Sha256) ---

@:keep @:brs_global function __crypto_not__(x:Int):Int {
	return untyped __brs__('(-((({0}) Or 0) + 1)) Or 0', x);
}

@:keep @:brs_global function __crypto_xor__(a:Int, b:Int):Int {
	untyped __brs__('
		__xa = ({0}) Or 0
		__xb = ({1}) Or 0
		__xn = (-((__xa And __xb) + 1)) Or 0
		__xr = (__xa Or __xb) And __xn
	', a, b);
	return untyped __brs__('__xr Or 0');
}

@:keep @:brs_global function __crypto_rotl__(x:Int, n:Int):Int {
	untyped __brs__('__rx = ({0}) Or 0', x);
	return untyped __brs__('((__rx << ({0})) Or (__rx >> (32 - ({0})))) Or 0', n);
}

@:keep @:brs_global function __crypto_add32__(a:Int, b:Int):Int {
	return untyped __brs__('((({0}) Or 0) + (({1}) Or 0)) Or 0', a, b);
}

@:keep @:brs_global function __crypto_toHex32LE__(v:Int):String {
	untyped __brs__('
		__hex = ""
		__tmp = ({0}) Or 0
		for __bi = 0 to 3
			__byte = __tmp And &hFF
			__hi = (__byte >> 4) And &hF
			__lo = __byte And &hF
			if __hi < 10 then __hex = __hex + Chr(48 + __hi) else __hex = __hex + Chr(87 + __hi)
			if __lo < 10 then __hex = __hex + Chr(48 + __lo) else __hex = __hex + Chr(87 + __lo)
			__tmp = __tmp >> 8
		end for
	', v);
	return untyped __brs__('__hex');
}

@:keep @:brs_global function __crypto_toHex32BE__(v:Int):String {
	untyped __brs__('
		__hex = ""
		__vv = ({0}) Or 0
		for __bi = 3 to 0 step -1
			if __bi = 0 then
				__byte = __vv And &hFF
			else
				__byte = (__vv >> (__bi * 8)) And &hFF
			end if
			__hi = (__byte >> 4) And &hF
			__lo = __byte And &hF
			if __hi < 10 then __hex = __hex + Chr(48 + __hi) else __hex = __hex + Chr(87 + __hi)
			if __lo < 10 then __hex = __hex + Chr(48 + __lo) else __hex = __hex + Chr(87 + __lo)
		end for
	', v);
	return untyped __brs__('__hex');
}

@:keep @:brs_global function __crypto_int32ToBytes__(v:Int, ba:Dynamic):Void {
	untyped __brs__('
		__iv = ({0}) Or 0
		{1}.Push(__iv And &hFF)
		{1}.Push((__iv >> 8) And &hFF)
		{1}.Push((__iv >> 16) And &hFF)
		{1}.Push((__iv >> 24) And &hFF)
	', v, ba);
}

@:keep @:brs_global function __crypto_int32ToBytesBE__(v:Int, ba:Dynamic):Void {
	untyped __brs__('
		__iv = ({0}) Or 0
		{1}.Push((__iv >> 24) And &hFF)
		{1}.Push((__iv >> 16) And &hFF)
		{1}.Push((__iv >> 8) And &hFF)
		{1}.Push(__iv And &hFF)
	', v, ba);
}

// --- MD5 implementation ---

@:keep @:brs_global function __Md5_encode__(inputStr:String):String {
	untyped __brs__('
		__msg = CreateObject("roByteArray")
		__msg.FromAsciiString({0})
		__ba = __Md5_digest__(__msg)
		__result = ""
		__tmp2 = __ba
		for __wi = 0 to 3
			__w = ((__tmp2[__wi*4]) Or (__tmp2[__wi*4+1] << 8) Or (__tmp2[__wi*4+2] << 16) Or (__tmp2[__wi*4+3] << 24)) Or 0
			__result = __result + __crypto_toHex32LE__(__w)
		end for
	', inputStr);
	return untyped __brs__('__result');
}

@:keep @:brs_global function __Md5_make__(ba:Dynamic):Dynamic {
	return untyped __brs__('__Md5_digest__({0})', ba);
}

@:keep @:brs_global function __Md5_digest__(msg:Dynamic):Dynamic {
	untyped __brs__('
		__K = CreateObject("roArray", 64, false)
		__K[0]=&hd76aa478:__K[1]=&he8c7b756:__K[2]=&h242070db:__K[3]=&hc1bdceee
		__K[4]=&hf57c0faf:__K[5]=&h4787c62a:__K[6]=&ha8304613:__K[7]=&hfd469501
		__K[8]=&h698098d8:__K[9]=&h8b44f7af:__K[10]=&hffff5bb1:__K[11]=&h895cd7be
		__K[12]=&h6b901122:__K[13]=&hfd987193:__K[14]=&ha679438e:__K[15]=&h49b40821
		__K[16]=&hf61e2562:__K[17]=&hc040b340:__K[18]=&h265e5a51:__K[19]=&he9b6c7aa
		__K[20]=&hd62f105d:__K[21]=&h02441453:__K[22]=&hd8a1e681:__K[23]=&he7d3fbc8
		__K[24]=&h21e1cde6:__K[25]=&hc33707d6:__K[26]=&hf4d50d87:__K[27]=&h455a14ed
		__K[28]=&ha9e3e905:__K[29]=&hfcefa3f8:__K[30]=&h676f02d9:__K[31]=&h8d2a4c8a
		__K[32]=&hfffa3942:__K[33]=&h8771f681:__K[34]=&h6d9d6122:__K[35]=&hfde5380c
		__K[36]=&ha4beea44:__K[37]=&h4bdecfa9:__K[38]=&hf6bb4b60:__K[39]=&hbebfbc70
		__K[40]=&h289b7ec6:__K[41]=&heaa127fa:__K[42]=&hd4ef3085:__K[43]=&h04881d05
		__K[44]=&hd9d4d039:__K[45]=&he6db99e5:__K[46]=&h1fa27cf8:__K[47]=&hc4ac5665
		__K[48]=&hf4292244:__K[49]=&h432aff97:__K[50]=&hab9423a7:__K[51]=&hfc93a039
		__K[52]=&h655b59c3:__K[53]=&h8f0ccc92:__K[54]=&hffeff47d:__K[55]=&h85845dd1
		__K[56]=&h6fa87e4f:__K[57]=&hfe2ce6e0:__K[58]=&ha3014314:__K[59]=&h4e0811a1
		__K[60]=&hf7537e82:__K[61]=&hbd3af235:__K[62]=&h2ad7d2bb:__K[63]=&heb86d391
		for __ki = 0 to 63 : __K[__ki] = __K[__ki] Or 0 : end for
		__SS = CreateObject("roArray", 64, false)
		__SS[0]=7:__SS[1]=12:__SS[2]=17:__SS[3]=22:__SS[4]=7:__SS[5]=12:__SS[6]=17:__SS[7]=22:__SS[8]=7:__SS[9]=12:__SS[10]=17:__SS[11]=22:__SS[12]=7:__SS[13]=12:__SS[14]=17:__SS[15]=22
		__SS[16]=5:__SS[17]=9:__SS[18]=14:__SS[19]=20:__SS[20]=5:__SS[21]=9:__SS[22]=14:__SS[23]=20:__SS[24]=5:__SS[25]=9:__SS[26]=14:__SS[27]=20:__SS[28]=5:__SS[29]=9:__SS[30]=14:__SS[31]=20
		__SS[32]=4:__SS[33]=11:__SS[34]=16:__SS[35]=23:__SS[36]=4:__SS[37]=11:__SS[38]=16:__SS[39]=23:__SS[40]=4:__SS[41]=11:__SS[42]=16:__SS[43]=23:__SS[44]=4:__SS[45]=11:__SS[46]=16:__SS[47]=23
		__SS[48]=6:__SS[49]=10:__SS[50]=15:__SS[51]=21:__SS[52]=6:__SS[53]=10:__SS[54]=15:__SS[55]=21:__SS[56]=6:__SS[57]=10:__SS[58]=15:__SS[59]=21:__SS[60]=6:__SS[61]=10:__SS[62]=15:__SS[63]=21
		__pad = CreateObject("roByteArray")
		for __pi = 0 to {0}.Count() - 1 : __pad.Push({0}[__pi]) : end for
		__origLen = {0}.Count()
		__bitLen = __origLen * 8
		__pad.Push(&h80)
		while __pad.Count() Mod 64 <> 56 : __pad.Push(0) : end while
		__pad.Push(__bitLen And &hFF) : __pad.Push((__bitLen >> 8) And &hFF)
		__pad.Push((__bitLen >> 16) And &hFF) : __pad.Push((__bitLen >> 24) And &hFF)
		__pad.Push(0):__pad.Push(0):__pad.Push(0):__pad.Push(0)
		__h0=&h67452301 Or 0:__h1=&hefcdab89 Or 0:__h2=&h98badcfe Or 0:__h3=&h10325476 Or 0
		__numBlk = __pad.Count() / 64
		for __blk = 0 to __numBlk - 1
			__MM = CreateObject("roArray", 16, false)
			for __j = 0 to 15
				__base = __blk * 64 + __j * 4
				__MM[__j] = (__pad[__base] Or (__pad[__base+1] << 8) Or (__pad[__base+2] << 16) Or (__pad[__base+3] << 24)) Or 0
			end for
			__A=__h0:__B=__h1:__C=__h2:__D=__h3
			for __i = 0 to 63
				if __i < 16 then
					__notB = __crypto_not__(__B) Or 0
					__F = (__B And __C) Or (__notB And __D) : __g = __i
				else if __i < 32 then
					__notD = __crypto_not__(__D) Or 0
					__F = (__D And __B) Or (__notD And __C) : __g = (5*__i+1) Mod 16
				else if __i < 48 then
					__F = __crypto_xor__(__crypto_xor__(__B, __C), __D) Or 0 : __g = (3*__i+5) Mod 16
				else
					__notD = __crypto_not__(__D) Or 0
					__F = __crypto_xor__(__C, (__B Or __notD)) Or 0 : __g = (7*__i) Mod 16
				end if
				__F = __crypto_add32__(__crypto_add32__(__crypto_add32__(__F, __A), __K[__i]), __MM[__g]) Or 0
				__A=__D:__D=__C:__C=__B
				__B = __crypto_add32__(__B, __crypto_rotl__(__F, __SS[__i])) Or 0
			end for
			__h0=__crypto_add32__(__h0,__A) Or 0:__h1=__crypto_add32__(__h1,__B) Or 0:__h2=__crypto_add32__(__h2,__C) Or 0:__h3=__crypto_add32__(__h3,__D) Or 0
		end for
		__out = CreateObject("roByteArray")
		__crypto_int32ToBytes__(__h0, __out)
		__crypto_int32ToBytes__(__h1, __out)
		__crypto_int32ToBytes__(__h2, __out)
		__crypto_int32ToBytes__(__h3, __out)
	', msg);
	return untyped __brs__('__out');
}
