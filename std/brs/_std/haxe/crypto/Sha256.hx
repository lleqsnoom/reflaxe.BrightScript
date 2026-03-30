package haxe.crypto;

extern class Sha256 {
	@:nativeFunctionCode("__Sha256_encode__({arg0})")
	public static function encode(s:String):String;

	@:nativeFunctionCode("__Sha256_make__({arg0})")
	public static function make(b:haxe.io.Bytes):haxe.io.Bytes;
}

@:keep @:brs_global function __Sha256_encode__(inputStr:String):String {
	untyped __brs__('
		__msg = CreateObject("roByteArray")
		__msg.FromAsciiString({0})
		__ba = __Sha256_digest__(__msg, 256)
		__result = ""
		for __wi = 0 to 7
			__w = ((__ba[__wi*4] << 24) Or (__ba[__wi*4+1] << 16) Or (__ba[__wi*4+2] << 8) Or __ba[__wi*4+3]) Or 0
			__result = __result + __crypto_toHex32BE__(__w)
		end for
	', inputStr);
	return untyped __brs__('__result');
}

@:keep @:brs_global function __Sha256_make__(ba:Dynamic):Dynamic {
	return untyped __brs__('__Sha256_digest__({0}, 256)', ba);
}

@:keep @:brs_global function __Sha256_digest__(msg:Dynamic, bits:Int):Dynamic {
	untyped __brs__('
		__RK = CreateObject("roArray", 64, false)
		__RK[0]=&h428a2f98:__RK[1]=&h71374491:__RK[2]=&hb5c0fbcf:__RK[3]=&he9b5dba5
		__RK[4]=&h3956c25b:__RK[5]=&h59f111f1:__RK[6]=&h923f82a4:__RK[7]=&hab1c5ed5
		__RK[8]=&hd807aa98:__RK[9]=&h12835b01:__RK[10]=&h243185be:__RK[11]=&h550c7dc3
		__RK[12]=&h72be5d74:__RK[13]=&h80deb1fe:__RK[14]=&h9bdc06a7:__RK[15]=&hc19bf174
		__RK[16]=&he49b69c1:__RK[17]=&hefbe4786:__RK[18]=&h0fc19dc6:__RK[19]=&h240ca1cc
		__RK[20]=&h2de92c6f:__RK[21]=&h4a7484aa:__RK[22]=&h5cb0a9dc:__RK[23]=&h76f988da
		__RK[24]=&h983e5152:__RK[25]=&ha831c66d:__RK[26]=&hb00327c8:__RK[27]=&hbf597fc7
		__RK[28]=&hc6e00bf3:__RK[29]=&hd5a79147:__RK[30]=&h06ca6351:__RK[31]=&h14292967
		__RK[32]=&h27b70a85:__RK[33]=&h2e1b2138:__RK[34]=&h4d2c6dfc:__RK[35]=&h53380d13
		__RK[36]=&h650a7354:__RK[37]=&h766a0abb:__RK[38]=&h81c2c92e:__RK[39]=&h92722c85
		__RK[40]=&ha2bfe8a1:__RK[41]=&ha81a664b:__RK[42]=&hc24b8b70:__RK[43]=&hc76c51a3
		__RK[44]=&hd192e819:__RK[45]=&hd6990624:__RK[46]=&hf40e3585:__RK[47]=&h106aa070
		__RK[48]=&h19a4c116:__RK[49]=&h1e376c08:__RK[50]=&h2748774c:__RK[51]=&h34b0bcb5
		__RK[52]=&h391c0cb3:__RK[53]=&h4ed8aa4a:__RK[54]=&h5b9cca4f:__RK[55]=&h682e6ff3
		__RK[56]=&h748f82ee:__RK[57]=&h78a5636f:__RK[58]=&h84c87814:__RK[59]=&h8cc70208
		__RK[60]=&h90befffa:__RK[61]=&ha4506ceb:__RK[62]=&hbef9a3f7:__RK[63]=&hc67178f2
		for __ki = 0 to 63 : __RK[__ki] = __RK[__ki] Or 0 : end for
		__pad = CreateObject("roByteArray")
		for __pi = 0 to {0}.Count() - 1 : __pad.Push({0}[__pi]) : end for
		__origLen = {0}.Count()
		__bitLen = __origLen * 8
		__pad.Push(&h80)
		while __pad.Count() Mod 64 <> 56 : __pad.Push(0) : end while
		__pad.Push(0):__pad.Push(0):__pad.Push(0):__pad.Push(0)
		__pad.Push((__bitLen >> 24) And &hFF) : __pad.Push((__bitLen >> 16) And &hFF)
		__pad.Push((__bitLen >> 8) And &hFF) : __pad.Push(__bitLen And &hFF)
		if {1} = 224 then
			__sh0=&hc1059ed8 Or 0:__sh1=&h367cd507 Or 0:__sh2=&h3070dd17 Or 0:__sh3=&hf70e5939 Or 0
			__sh4=&hffc00b31 Or 0:__sh5=&h68581511 Or 0:__sh6=&h64f98fa7 Or 0:__sh7=&hbefa4fa4 Or 0
		else
			__sh0=&h6a09e667 Or 0:__sh1=&hbb67ae85 Or 0:__sh2=&h3c6ef372 Or 0:__sh3=&ha54ff53a Or 0
			__sh4=&h510e527f Or 0:__sh5=&h9b05688c Or 0:__sh6=&h1f83d9ab Or 0:__sh7=&h5be0cd19 Or 0
		end if
		__numBlk = __pad.Count() / 64
		for __blk = 0 to __numBlk - 1
			__W = CreateObject("roArray", 64, false)
			for __j = 0 to 15
				__base = __blk * 64 + __j * 4
				__W[__j] = ((__pad[__base] << 24) Or (__pad[__base+1] << 16) Or (__pad[__base+2] << 8) Or __pad[__base+3]) Or 0
			end for
			for __j = 16 to 63
				__s0w = __W[__j-15]
				__s0 = __crypto_xor__(__crypto_xor__(__crypto_rotl__(__s0w, 25), __crypto_rotl__(__s0w, 14)), (__s0w >> 3)) Or 0
				__s1w = __W[__j-2]
				__s1 = __crypto_xor__(__crypto_xor__(__crypto_rotl__(__s1w, 15), __crypto_rotl__(__s1w, 13)), (__s1w >> 10)) Or 0
				__W[__j] = __crypto_add32__(__crypto_add32__(__crypto_add32__(__W[__j-16], __s0), __W[__j-7]), __s1) Or 0
			end for
			__a=__sh0:__b=__sh1:__c=__sh2:__d=__sh3:__e=__sh4:__ff=__sh5:__gg=__sh6:__hh=__sh7
			for __i = 0 to 63
				__S1 = __crypto_xor__(__crypto_xor__(__crypto_rotl__(__e, 26), __crypto_rotl__(__e, 21)), __crypto_rotl__(__e, 7)) Or 0
				__note = __crypto_not__(__e) Or 0
				__ch = __crypto_xor__((__e And __ff), (__note And __gg)) Or 0
				__temp1 = __crypto_add32__(__crypto_add32__(__crypto_add32__(__crypto_add32__(__hh, __S1), __ch), __RK[__i]), __W[__i]) Or 0
				__S0 = __crypto_xor__(__crypto_xor__(__crypto_rotl__(__a, 30), __crypto_rotl__(__a, 19)), __crypto_rotl__(__a, 10)) Or 0
				__maj = __crypto_xor__(__crypto_xor__((__a And __b), (__a And __c)), (__b And __c)) Or 0
				__temp2 = __crypto_add32__(__S0, __maj) Or 0
				__hh=__gg:__gg=__ff:__ff=__e
				__e = __crypto_add32__(__d, __temp1) Or 0
				__d=__c:__c=__b:__b=__a
				__a = __crypto_add32__(__temp1, __temp2) Or 0
			end for
			__sh0=__crypto_add32__(__sh0,__a) Or 0:__sh1=__crypto_add32__(__sh1,__b) Or 0:__sh2=__crypto_add32__(__sh2,__c) Or 0:__sh3=__crypto_add32__(__sh3,__d) Or 0
			__sh4=__crypto_add32__(__sh4,__e) Or 0:__sh5=__crypto_add32__(__sh5,__ff) Or 0:__sh6=__crypto_add32__(__sh6,__gg) Or 0:__sh7=__crypto_add32__(__sh7,__hh) Or 0
		end for
		__out = CreateObject("roByteArray")
		__crypto_int32ToBytesBE__(__sh0, __out):__crypto_int32ToBytesBE__(__sh1, __out)
		__crypto_int32ToBytesBE__(__sh2, __out):__crypto_int32ToBytesBE__(__sh3, __out)
		__crypto_int32ToBytesBE__(__sh4, __out):__crypto_int32ToBytesBE__(__sh5, __out)
		__crypto_int32ToBytesBE__(__sh6, __out)
		if {1} = 256 then
			__crypto_int32ToBytesBE__(__sh7, __out)
		end if
	', msg, bits);
	return untyped __brs__('__out');
}
