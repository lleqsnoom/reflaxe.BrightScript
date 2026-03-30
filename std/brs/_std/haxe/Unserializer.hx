package haxe;

extern class Unserializer {
	@:nativeFunctionCode("__Unserializer_new__({arg0})")
	public function new(buf:String):Void;

	@:nativeFunctionCode("__Unserializer_unserialize__({this})")
	public function unserialize():Dynamic;

	@:nativeFunctionCode("invalid !37!")
	public function getResolver():Dynamic;

	@:nativeFunctionCode("invalid !38!")
	public function setResolver(r:Dynamic):Void;

	@:nativeFunctionCode("__Unserializer_run__({arg0})")
	public static function run(v:String):Dynamic;
}

// Private typed wrappers for cross-@:brs_global calls

private extern class BrsUnserializer {
	@:nativeFunctionCode("0 + __Unserializer_readDigits__({arg0})")
	static function readDigits(self:Dynamic):Int;

	@:nativeFunctionCode("__Unserializer_readFloat__({arg0})")
	static function readFloat(self:Dynamic):Dynamic;

	@:nativeFunctionCode("__Unserializer_readString__({arg0})")
	static function readString(self:Dynamic):Dynamic;

	@:nativeFunctionCode("__Unserializer_unserialize__({arg0})")
	static function unserialize(self:Dynamic):Dynamic;

	@:nativeFunctionCode("__StringTools_urlDecode__({arg0})")
	static function urlDecode(s:String):String;
}

// --- @:brs_global helper functions ---

@:keep @:brs_global function __Unserializer_new__(buf:String):Dynamic {
	var u:Dynamic = brs.Native.emptyAA();
	brs.Native.fieldSet(u, "buf", buf);
	brs.Native.fieldSet(u, "pos", 0);
	brs.Native.fieldSet(u, "length", brs.Native.len(buf));
	brs.Native.fieldSet(u, "scache", brs.Native.emptyArray());
	brs.Native.fieldSet(u, "cache", brs.Native.emptyArray());
	return u;
}

@:keep @:brs_global function __Unserializer_run__(buf:String):Dynamic {
	var u:Dynamic = brs.Native.emptyAA();
	brs.Native.fieldSet(u, "buf", buf);
	brs.Native.fieldSet(u, "pos", 0);
	brs.Native.fieldSet(u, "length", brs.Native.len(buf));
	brs.Native.fieldSet(u, "scache", brs.Native.emptyArray());
	brs.Native.fieldSet(u, "cache", brs.Native.emptyArray());
	return BrsUnserializer.unserialize(u);
}

@:keep @:brs_global function __Unserializer_readDigits__(self:Dynamic):Dynamic {
	untyped __brs__('
	__p = 0 + {0}.pos
	__b = {0}.buf
	__l = 0 + {0}.length
	__neg = false
	if __p < __l then
		if Asc(Mid(__b, __p + 1, 1)) = 45 then
			__neg = true
			__p = __p + 1
		end if
	end if
	__n = 0
	__rd = 0
	while __rd = 0
		if __p >= __l then
			__rd = 1
		else
			__c = Asc(Mid(__b, __p + 1, 1))
			if __c >= 48 then
				if __c <= 57 then
					__n = __n * 10 + (__c - 48)
					__p = __p + 1
				else
					__rd = 1
				end if
			else
				__rd = 1
			end if
		end if
	end while
	if __neg then __n = 0 - __n
	{0}.pos = __p
	return __n', self);
	return brs.Native.invalid();
}

@:keep @:brs_global function __Unserializer_readFloat__(self:Dynamic):Dynamic {
	untyped __brs__('
	__p = 0 + {0}.pos
	__b = {0}.buf
	__l = 0 + {0}.length
	__fs = __p
	__rd = 0
	while __rd = 0
		if __p >= __l then
			__rd = 1
		else
			__c = Asc(Mid(__b, __p + 1, 1))
			__isF = false
			if __c >= 48 then
				if __c <= 57 then __isF = true
			end if
			if __c = 46 then __isF = true
			if __c = 45 then __isF = true
			if __c = 43 then __isF = true
			if __c = 101 then __isF = true
			if __c = 69 then __isF = true
			if __isF then
				__p = __p + 1
			else
				__rd = 1
			end if
		end if
	end while
	__fstr = Mid(__b, __fs + 1, __p - __fs)
	{0}.pos = __p
	return Val(__fstr)', self);
	return brs.Native.invalid();
}

@:keep @:brs_global function __Unserializer_readString__(self:Dynamic):Dynamic {
	untyped __brs__('
	__p = 0 + {0}.pos
	__b = {0}.buf
	__l = 0 + {0}.length
	__slen = 0
	__rd = 0
	while __rd = 0
		if __p >= __l then
			__rd = 1
		else
			__c = Asc(Mid(__b, __p + 1, 1))
			if __c >= 48 then
				if __c <= 57 then
					__slen = __slen * 10 + (__c - 48)
					__p = __p + 1
				else
					__rd = 1
				end if
			else
				__rd = 1
			end if
		end if
	end while
	if __p < __l then
		if Mid(__b, __p + 1, 1) = ":" then
			__p = __p + 1
		end if
	end if
	__enc = Mid(__b, __p + 1, __slen)
	__p = __p + __slen
	__decoded = __StringTools_urlDecode__(__enc)
	{0}.scache.Push(__decoded)
	{0}.pos = __p
	return __decoded', self);
	return brs.Native.invalid();
}

@:keep @:brs_global function __Unserializer_readArray__(self:Dynamic):Dynamic {
	untyped __brs__('
	__arr = []
	{0}.cache.Push(__arr)
	__done = 0
	while __done = 0
		__p = 0 + {0}.pos
		if __p >= (0 + {0}.length) then
			__done = 1
		else
			__ch = Mid({0}.buf, __p + 1, 1)
			if __ch = "h" then
				{0}.pos = __p + 1
				__done = 1
			else if __ch = "u" then
				{0}.pos = __p + 1
				__nc = 0 + __Unserializer_readDigits__({0})
				__ni = 0
				while __ni < __nc
					__arr.Push(invalid)
					__ni = __ni + 1
				end while
			else
				__val = __Unserializer_unserialize__({0})
				__arr.Push(__val)
			end if
		end if
	end while
	return __arr', self);
	return brs.Native.invalid();
}

@:keep @:brs_global function __Unserializer_readObj__(self:Dynamic):Dynamic {
	untyped __brs__('
	__obj = {}
	__obj.SetModeCaseSensitive()
	{0}.cache.Push(__obj)
	__done = 0
	while __done = 0
		__p = 0 + {0}.pos
		if __p >= (0 + {0}.length) then
			__done = 1
		else
			__ch = Mid({0}.buf, __p + 1, 1)
			if __ch = "g" then
				{0}.pos = __p + 1
				__done = 1
			else
				__key = "" + __Unserializer_unserialize__({0})
				__val = __Unserializer_unserialize__({0})
				__obj[__key] = __val
			end if
		end if
	end while
	return __obj', self);
	return brs.Native.invalid();
}

@:keep @:brs_global function __Unserializer_readStringMap__(self:Dynamic):Dynamic {
	untyped __brs__('
	__sm = {}
	__sm.SetModeCaseSensitive()
	{0}.cache.Push(__sm)
	__done = 0
	while __done = 0
		__p = 0 + {0}.pos
		if __p >= (0 + {0}.length) then
			__done = 1
		else
			__ch = Mid({0}.buf, __p + 1, 1)
			if __ch = "h" then
				{0}.pos = __p + 1
				__done = 1
			else
				__key = "" + __Unserializer_unserialize__({0})
				__val = __Unserializer_unserialize__({0})
				__sm[__key] = __val
			end if
		end if
	end while
	return __sm', self);
	return brs.Native.invalid();
}

@:keep @:brs_global function __Unserializer_readIntMap__(self:Dynamic):Dynamic {
	untyped __brs__('
	__im = {}
	{0}.cache.Push(__im)
	__done = 0
	while __done = 0
		__p = 0 + {0}.pos
		if __p >= (0 + {0}.length) then
			__done = 1
		else
			__ch = Mid({0}.buf, __p + 1, 1)
			if __ch = "h" then
				{0}.pos = __p + 1
				__done = 1
			else if __ch = ":" then
				{0}.pos = __p + 1
				__key = __Unserializer_readDigits__({0})
				__val = __Unserializer_unserialize__({0})
				__im[Str(__key).Trim()] = __val
			else
				__done = 1
			end if
		end if
	end while
	return __im', self);
	return brs.Native.invalid();
}

@:keep @:brs_global function __Unserializer_readList__(self:Dynamic):Dynamic {
	untyped __brs__('
	__lst = []
	{0}.cache.Push(__lst)
	__done = 0
	while __done = 0
		__p = 0 + {0}.pos
		if __p >= (0 + {0}.length) then
			__done = 1
		else
			__ch = Mid({0}.buf, __p + 1, 1)
			if __ch = "h" then
				{0}.pos = __p + 1
				__done = 1
			else
				__val = __Unserializer_unserialize__({0})
				__lst.Push(__val)
			end if
		end if
	end while
	return __lst', self);
	return brs.Native.invalid();
}

@:keep @:brs_global function __Unserializer_readDate__(self:Dynamic):Dynamic {
	untyped __brs__('
	__p = 0 + {0}.pos
	__ds = Mid({0}.buf, __p + 1, 19)
	{0}.pos = __p + 19
	__dt = CreateObject("roDateTime")
	__iso = Left(__ds, 10) + "T" + Right(__ds, 8) + "Z"
	__dt.FromISO8601String(__iso)
	return {"s": __dt.AsSeconds()}', self);
	return brs.Native.invalid();
}

@:keep @:brs_global function __Unserializer_readEnumByName__(self:Dynamic):Dynamic {
	untyped __brs__('
	__ename = __Unserializer_unserialize__({0})
	__cname = __Unserializer_unserialize__({0})
	__p = 0 + {0}.pos
	if Mid({0}.buf, __p + 1, 1) = ":" then __p = __p + 1
	{0}.pos = __p
	__argc = 0 + __Unserializer_readDigits__({0})
	__params = []
	__i = 0
	while __i < __argc
		__params.Push(__Unserializer_unserialize__({0}))
		__i = __i + 1
	end while
	__e = {"_index": 0, "_hxName": __cname}
	if __argc > 0 then __e.params = __params
	{0}.cache.Push(__e)
	return __e', self);
	return brs.Native.invalid();
}

@:keep @:brs_global function __Unserializer_readEnumByIndex__(self:Dynamic):Dynamic {
	untyped __brs__('
	__ename = __Unserializer_unserialize__({0})
	__p = 0 + {0}.pos
	if Mid({0}.buf, __p + 1, 1) = ":" then __p = __p + 1
	{0}.pos = __p
	__eidx = 0 + __Unserializer_readDigits__({0})
	__p = 0 + {0}.pos
	if Mid({0}.buf, __p + 1, 1) = ":" then __p = __p + 1
	{0}.pos = __p
	__argc = 0 + __Unserializer_readDigits__({0})
	__params = []
	__i = 0
	while __i < __argc
		__params.Push(__Unserializer_unserialize__({0}))
		__i = __i + 1
	end while
	__e = {"_index": __eidx}
	if __argc > 0 then __e.params = __params
	{0}.cache.Push(__e)
	return __e', self);
	return brs.Native.invalid();
}

@:keep @:brs_global function __Unserializer_readObjMap__(self:Dynamic):Dynamic {
	untyped __brs__('
	__om = {"k": [], "v": []}
	{0}.cache.Push(__om)
	__done = 0
	while __done = 0
		__p = 0 + {0}.pos
		if __p >= (0 + {0}.length) then
			__done = 1
		else
			__ch = Mid({0}.buf, __p + 1, 1)
			if __ch = "h" then
				{0}.pos = __p + 1
				__done = 1
			else
				__key = __Unserializer_unserialize__({0})
				__val = __Unserializer_unserialize__({0})
				__om.k.Push(__key)
				__om.v.Push(__val)
			end if
		end if
	end while
	return __om', self);
	return brs.Native.invalid();
}

// --- Main unserialize dispatch ---

@:keep @:brs_global function __Unserializer_unserialize__(self:Dynamic):Dynamic {
	var p:Int = brs.Native.toInt(brs.Native.fieldGet(self, "pos"));
	var buf:String = brs.Native.fieldGet(self, "buf");
	var ch:String = brs.Native.mid(buf, p, 1);
	p = p + 1;
	brs.Native.fieldSet(self, "pos", p);

	// null
	if (ch == "n") return brs.Native.invalid();

	// true
	if (ch == "t") return untyped __brs__('true');

	// false
	if (ch == "f") return untyped __brs__('false');

	// zero
	if (ch == "z") return 0;

	// int
	if (ch == "i") {
		return BrsUnserializer.readDigits(self);
	}

	// float
	if (ch == "d") {
		return BrsUnserializer.readFloat(self);
	}

	// NaN
	if (ch == "k") return 0;

	// negative infinity
	if (ch == "m") return -2147483647;

	// positive infinity
	if (ch == "p") return 2147483647;

	// string
	if (ch == "y") {
		return BrsUnserializer.readString(self);
	}

	// string cache reference
	if (ch == "R") {
		var idx:Int = BrsUnserializer.readDigits(self);
		return brs.Native.arrayGet(brs.Native.fieldGet(self, "scache"), idx);
	}

	// array
	if (ch == "a") {
		return untyped __brs__('__Unserializer_readArray__({0})', self);
	}

	// structure
	if (ch == "o") {
		return untyped __brs__('__Unserializer_readObj__({0})', self);
	}

	// class instance — deserialize as anonymous object
	if (ch == "c") {
		untyped __brs__('__Unserializer_readString__({0})', self);
		return untyped __brs__('__Unserializer_readObj__({0})', self);
	}

	// enum by name
	if (ch == "w") {
		return untyped __brs__('__Unserializer_readEnumByName__({0})', self);
	}

	// enum by index
	if (ch == "j") {
		return untyped __brs__('__Unserializer_readEnumByIndex__({0})', self);
	}

	// StringMap
	if (ch == "b") {
		return untyped __brs__('__Unserializer_readStringMap__({0})', self);
	}

	// IntMap
	if (ch == "q") {
		return untyped __brs__('__Unserializer_readIntMap__({0})', self);
	}

	// List
	if (ch == "l") {
		return untyped __brs__('__Unserializer_readList__({0})', self);
	}

	// Date
	if (ch == "v") {
		return untyped __brs__('__Unserializer_readDate__({0})', self);
	}

	// object cache reference
	if (ch == "r") {
		var idx:Int = BrsUnserializer.readDigits(self);
		return brs.Native.arrayGet(brs.Native.fieldGet(self, "cache"), idx);
	}

	// exception
	if (ch == "x") {
		return BrsUnserializer.unserialize(self);
	}

	// ObjectMap
	if (ch == "M") {
		return untyped __brs__('__Unserializer_readObjMap__({0})', self);
	}

	return brs.Native.invalid();
}
