package haxe;

extern class Serializer {
	@:nativeFunctionCode("__Serializer_new__()")
	public function new():Void;

	@:nativeFunctionCode("__Serializer_serialize__({this}, {arg0})")
	public function serialize(v:Dynamic):Void;

	@:nativeFunctionCode("__Serializer_serialize__({this}, {arg0})")
	public function serializeException(e:Dynamic):Void;

	@:nativeFunctionCode("{this}.buf")
	public function toString():String;

	@:nativeFunctionCode("__Serializer_run__({arg0})")
	public static function run(v:Dynamic):String;
}

// Private typed wrappers for cross-@:brs_global calls

private extern class BrsSerializer {
	@:nativeFunctionCode("__Serializer_serStr__({arg0}, {arg1})")
	static function serStr(self:Dynamic, s:Dynamic):Void;

	@:nativeFunctionCode("__Serializer_serialize__({arg0}, {arg1})")
	static function serialize(self:Dynamic, v:Dynamic):Void;

	@:nativeFunctionCode("__StringTools_urlEncode__({arg0})")
	static function urlEncode(s:String):String;
}

// --- @:brs_global helper functions ---

@:keep @:brs_global function __Serializer_new__():Dynamic {
	var s:Dynamic = brs.Native.emptyAA();
	brs.Native.fieldSet(s, "buf", "");
	brs.Native.fieldSet(s, "scache", brs.Native.emptyArray());
	brs.Native.fieldSet(s, "cache", brs.Native.emptyArray());
	return s;
}

@:keep @:brs_global function __Serializer_run__(v:Dynamic):Dynamic {
	var s:Dynamic = brs.Native.emptyAA();
	brs.Native.fieldSet(s, "buf", "");
	brs.Native.fieldSet(s, "scache", brs.Native.emptyArray());
	brs.Native.fieldSet(s, "cache", brs.Native.emptyArray());
	BrsSerializer.serialize(s, v);
	return brs.Native.fieldGet(s, "buf");
}

@:keep @:brs_global function __Serializer_serStr__(self:Dynamic, s:Dynamic):Dynamic {
	var scache:Dynamic = brs.Native.fieldGet(self, "scache");
	var cnt:Int = brs.Native.count(scache);
	var i:Int = 0;
	while (i < cnt) {
		var cached:Dynamic = brs.Native.arrayGet(scache, i);
		var eq:Bool = brs.Native.eq(cached, s);
		if (eq == true) {
			brs.Native.fieldSet(self, "buf", brs.Native.fieldGet(self, "buf") + "R" + brs.Native.intToStr(i));
			return brs.Native.invalid();
		}
		i = i + 1;
	}
	brs.Native.push(scache, s);
	var enc:String = BrsSerializer.urlEncode(s);
	var encLen:String = brs.Native.intToStr(brs.Native.len(enc));
	brs.Native.fieldSet(self, "buf", brs.Native.fieldGet(self, "buf") + "y" + encLen + ":" + enc);
	return brs.Native.invalid();
}

@:keep @:brs_global function __Serializer_serialize__(self:Dynamic, v:Dynamic):Dynamic {
	// null check
	untyped __brs__('
	if {0} = invalid then
		{1}.buf = {1}.buf + "n"
		return invalid
	end if', v, self);

	var t:String = brs.Native.typeOf(v);

	// Int
	if (t == "roInt") {
		untyped __brs__('
		if {0} = 0 then
			{1}.buf = {1}.buf + "z"
		else
			{1}.buf = {1}.buf + "i" + Str({0}).Trim()
		end if', v, self);
		return brs.Native.invalid();
	}
	if (t == "Integer") {
		untyped __brs__('
		if {0} = 0 then
			{1}.buf = {1}.buf + "z"
		else
			{1}.buf = {1}.buf + "i" + Str({0}).Trim()
		end if', v, self);
		return brs.Native.invalid();
	}

	// Bool
	if (t == "roBoolean") {
		untyped __brs__('
		if {0} then
			{1}.buf = {1}.buf + "t"
		else
			{1}.buf = {1}.buf + "f"
		end if', v, self);
		return brs.Native.invalid();
	}
	if (t == "Boolean") {
		untyped __brs__('
		if {0} then
			{1}.buf = {1}.buf + "t"
		else
			{1}.buf = {1}.buf + "f"
		end if', v, self);
		return brs.Native.invalid();
	}

	// Float / Double
	if (t == "roFloat") {
		untyped __brs__('
		__fv = {0}
		if __fv <> __fv then
			{1}.buf = {1}.buf + "k"
			return invalid
		end if
		__fi = Int(__fv)
		if __fi = __fv then
			if __fi = 0 then
				{1}.buf = {1}.buf + "z"
			else
				{1}.buf = {1}.buf + "i" + Str(__fi).Trim()
			end if
		else
			{1}.buf = {1}.buf + "d" + Str(__fv).Trim()
		end if', v, self);
		return brs.Native.invalid();
	}
	if (t == "Float") {
		untyped __brs__('
		__fv = {0}
		if __fv <> __fv then
			{1}.buf = {1}.buf + "k"
			return invalid
		end if
		__fi = Int(__fv)
		if __fi = __fv then
			if __fi = 0 then
				{1}.buf = {1}.buf + "z"
			else
				{1}.buf = {1}.buf + "i" + Str(__fi).Trim()
			end if
		else
			{1}.buf = {1}.buf + "d" + Str(__fv).Trim()
		end if', v, self);
		return brs.Native.invalid();
	}
	if (t == "roDouble") {
		untyped __brs__('
		__fv = {0}
		if __fv <> __fv then
			{1}.buf = {1}.buf + "k"
			return invalid
		end if
		__fi = Int(__fv)
		if __fi = __fv then
			if __fi = 0 then
				{1}.buf = {1}.buf + "z"
			else
				{1}.buf = {1}.buf + "i" + Str(__fi).Trim()
			end if
		else
			{1}.buf = {1}.buf + "d" + Str(__fv).Trim()
		end if', v, self);
		return brs.Native.invalid();
	}
	if (t == "Double") {
		untyped __brs__('
		__fv = {0}
		if __fv <> __fv then
			{1}.buf = {1}.buf + "k"
			return invalid
		end if
		__fi = Int(__fv)
		if __fi = __fv then
			if __fi = 0 then
				{1}.buf = {1}.buf + "z"
			else
				{1}.buf = {1}.buf + "i" + Str(__fi).Trim()
			end if
		else
			{1}.buf = {1}.buf + "d" + Str(__fv).Trim()
		end if', v, self);
		return brs.Native.invalid();
	}

	// String
	if (t == "roString") {
		BrsSerializer.serStr(self, v);
		return brs.Native.invalid();
	}
	if (t == "String") {
		BrsSerializer.serStr(self, v);
		return brs.Native.invalid();
	}

	// Array
	if (t == "roArray") {
		untyped __brs__('
		{1}.buf = {1}.buf + "a"
		__ac = {0}.Count()
		__ai = 0
		while __ai < __ac
			__Serializer_serialize__({1}, {0}[__ai])
			__ai = __ai + 1
		end while
		{1}.buf = {1}.buf + "h"', v, self);
		return brs.Native.invalid();
	}

	// Associative Array
	if (t == "roAssociativeArray") {
		var hasIdx:Bool = brs.Native.doesExist(v, "_index");
		var hasStatic:Bool = brs.Native.doesExist(v, "__static__");
		if (hasIdx == true) {
			if (hasStatic != true) {
				// Enum value — serialize as j (by index)
				untyped __brs__('
				__eidx = 0 + {0}._index
				__ename = ""
				if {0}.DoesExist("_hxName") then __ename = {0}._hxName
				__Serializer_serStr__({1}, __ename)
				{1}.buf = {1}.buf + ":" + Str(__eidx).Trim() + ":"
				if {0}.DoesExist("params") then
					__ep = {0}.params
					__epc = __ep.Count()
					{1}.buf = {1}.buf + Str(__epc).Trim()
					__epi = 0
					while __epi < __epc
						__Serializer_serialize__({1}, __ep[__epi])
						__epi = __epi + 1
					end while
				else
					{1}.buf = {1}.buf + "0"
				end if', v, self);
				return brs.Native.invalid();
			}
		}

		// Regular AA or class instance — serialize as structure o...g
		untyped __brs__('
		{1}.buf = {1}.buf + "o"
		__ks = {0}.Keys()
		__kc = __ks.Count()
		__ki = 0
		while __ki < __kc
			__kn = __ks[__ki]
			if __kn <> "__static__" then
				if __kn <> "__hx_name__" then
					if __kn <> "__hx_id__" then
						__Serializer_serStr__({1}, __kn)
						__Serializer_serialize__({1}, {0}[__kn])
					end if
				end if
			end if
			__ki = __ki + 1
		end while
		{1}.buf = {1}.buf + "g"', v, self);
		return brs.Native.invalid();
	}

	// Unknown type — serialize as null
	untyped __brs__('{0}.buf = {0}.buf + "n"', self);
	return brs.Native.invalid();
}
