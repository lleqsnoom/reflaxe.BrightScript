package haxe.format;

extern class JsonPrinter {
	@:runtime public static inline function print(o:Dynamic, ?replacer:Dynamic, ?space:String):String {
		return _printImpl(o, replacer, space);
	}

	@:nativeFunctionCode("__JsonPrinter_print__({arg0}, {arg1}, {arg2})")
	private static function _printImpl(o:Dynamic, replacer:Dynamic, space:Dynamic):String;
}

// Private typed wrappers for cross-@:brs_global calls

private extern class BrsJsonPrinter {
	@:nativeFunctionCode("__JsonPrinter_write__({arg0}, {arg1}, {arg2})")
	static function write(self:Dynamic, k:Dynamic, v:Dynamic):Void;

	@:nativeFunctionCode("__JsonPrinter_quote__({arg0}, {arg1})")
	static function quote(self:Dynamic, s:Dynamic):Void;

	@:nativeFunctionCode("__JsonPrinter_objString__({arg0}, {arg1})")
	static function objString(self:Dynamic, v:Dynamic):Void;
}

// --- @:brs_global helper functions ---

@:keep @:brs_global function __JsonPrinter_print__(o:Dynamic, replacer:Dynamic, space:Dynamic):Dynamic {
	var self:Dynamic = brs.Native.emptyAA();
	brs.Native.fieldSet(self, "buf", "");
	brs.Native.fieldSet(self, "replacer", replacer);
	brs.Native.fieldSet(self, "pretty", false);
	brs.Native.fieldSet(self, "indent", "");
	brs.Native.fieldSet(self, "nind", 0);
	untyped __brs__('
	if {0} <> invalid then
		{1}.pretty = true
		{1}.indent = {0}
	end if', space, self);
	BrsJsonPrinter.write(self, "", o);
	return brs.Native.fieldGet(self, "buf");
}

@:keep @:brs_global function __JsonPrinter_quote__(self:Dynamic, s:Dynamic):Dynamic {
	untyped __brs__('
	{0}.buf = {0}.buf + Chr(34)
	__jq_len = Len({1})
	__jq_i = 1
	while __jq_i <= __jq_len
		__jq_c = Asc(Mid({1}, __jq_i, 1))
		if __jq_c = 34 then
			{0}.buf = {0}.buf + Chr(92) + Chr(34)
		else if __jq_c = 92 then
			{0}.buf = {0}.buf + Chr(92) + Chr(92)
		else if __jq_c = 10 then
			{0}.buf = {0}.buf + Chr(92) + "n"
		else if __jq_c = 13 then
			{0}.buf = {0}.buf + Chr(92) + "r"
		else if __jq_c = 9 then
			{0}.buf = {0}.buf + Chr(92) + "t"
		else if __jq_c = 8 then
			{0}.buf = {0}.buf + Chr(92) + "b"
		else if __jq_c = 12 then
			{0}.buf = {0}.buf + Chr(92) + "f"
		else
			{0}.buf = {0}.buf + Chr(__jq_c)
		end if
		__jq_i = __jq_i + 1
	end while
	{0}.buf = {0}.buf + Chr(34)', self, s);
	return brs.Native.invalid();
}

@:keep @:brs_global function __JsonPrinter_ipad__(self:Dynamic):Dynamic {
	untyped __brs__('
	if {0}.pretty then
		__ji_p = ""
		__ji_i = 0
		while __ji_i < {0}.nind
			__ji_p = __ji_p + {0}.indent
			__ji_i = __ji_i + 1
		end while
		{0}.buf = {0}.buf + __ji_p
	end if', self);
	return brs.Native.invalid();
}

@:keep @:brs_global function __JsonPrinter_objString__(self:Dynamic, v:Dynamic):Dynamic {
	untyped __brs__('
	{0}.buf = {0}.buf + "{"
	__jo_ks = {1}.Keys()
	__jo_cnt = __jo_ks.Count()
	__jo_empty = true
	__jo_i = 0
	while __jo_i < __jo_cnt
		__jo_f = __jo_ks[__jo_i]
		if __jo_f <> "__static__" and __jo_f <> "__hx_name__" and __jo_f <> "__hx_id__" then
			__jo_val = {1}[__jo_f]
			__jo_vt = Type(__jo_val)
			if __jo_vt <> "roFunction" and __jo_vt <> "Function" then
				if __jo_empty then
					{0}.nind = {0}.nind + 1
					__jo_empty = false
				else
					{0}.buf = {0}.buf + ","
				end if
				if {0}.pretty then
					{0}.buf = {0}.buf + Chr(10)
					__JsonPrinter_ipad__({0})
				end if
				__JsonPrinter_quote__({0}, __jo_f)
				{0}.buf = {0}.buf + ":"
				if {0}.pretty then {0}.buf = {0}.buf + " "
				__JsonPrinter_write__({0}, __jo_f, __jo_val)
			end if
		end if
		__jo_i = __jo_i + 1
	end while
	if not __jo_empty then
		{0}.nind = {0}.nind - 1
		if {0}.pretty then
			{0}.buf = {0}.buf + Chr(10)
			__JsonPrinter_ipad__({0})
		end if
	end if
	{0}.buf = {0}.buf + "}"', self, v);
	return brs.Native.invalid();
}

@:keep @:brs_global function __JsonPrinter_write__(self:Dynamic, k:Dynamic, v:Dynamic):Dynamic {
	// Apply replacer
	untyped __brs__('
	if {0}.replacer <> invalid then
		{2} = {0}.replacer({1}, {2})
	end if', self, k, v);

	// Null check
	untyped __brs__('
	if {0} = invalid then
		{1}.buf = {1}.buf + "null"
		return invalid
	end if', v, self);

	var t:String = brs.Native.typeOf(v);

	// Int
	if (t == "roInt") {
		untyped __brs__('{0}.buf = {0}.buf + Str({1}).Trim()', self, v);
		return brs.Native.invalid();
	}
	if (t == "Integer") {
		untyped __brs__('{0}.buf = {0}.buf + Str({1}).Trim()', self, v);
		return brs.Native.invalid();
	}

	// Float / Double
	if (t == "roFloat") {
		untyped __brs__('
		if {1} <> {1} then
			{0}.buf = {0}.buf + "null"
		else
			{0}.buf = {0}.buf + Str({1}).Trim()
		end if', self, v);
		return brs.Native.invalid();
	}
	if (t == "Float") {
		untyped __brs__('
		if {1} <> {1} then
			{0}.buf = {0}.buf + "null"
		else
			{0}.buf = {0}.buf + Str({1}).Trim()
		end if', self, v);
		return brs.Native.invalid();
	}
	if (t == "roDouble") {
		untyped __brs__('
		if {1} <> {1} then
			{0}.buf = {0}.buf + "null"
		else
			{0}.buf = {0}.buf + Str({1}).Trim()
		end if', self, v);
		return brs.Native.invalid();
	}
	if (t == "Double") {
		untyped __brs__('
		if {1} <> {1} then
			{0}.buf = {0}.buf + "null"
		else
			{0}.buf = {0}.buf + Str({1}).Trim()
		end if', self, v);
		return brs.Native.invalid();
	}

	// Boolean
	if (t == "roBoolean") {
		untyped __brs__('
		if {1} then
			{0}.buf = {0}.buf + "true"
		else
			{0}.buf = {0}.buf + "false"
		end if', self, v);
		return brs.Native.invalid();
	}
	if (t == "Boolean") {
		untyped __brs__('
		if {1} then
			{0}.buf = {0}.buf + "true"
		else
			{0}.buf = {0}.buf + "false"
		end if', self, v);
		return brs.Native.invalid();
	}

	// String
	if (t == "roString") {
		BrsJsonPrinter.quote(self, v);
		return brs.Native.invalid();
	}
	if (t == "String") {
		BrsJsonPrinter.quote(self, v);
		return brs.Native.invalid();
	}

	// Array
	if (t == "roArray") {
		untyped __brs__('
		{0}.buf = {0}.buf + "["
		__jw_cnt = {1}.Count()
		__jw_last = __jw_cnt - 1
		__jw_i = 0
		while __jw_i < __jw_cnt
			if __jw_i > 0 then
				{0}.buf = {0}.buf + ","
			else
				{0}.nind = {0}.nind + 1
			end if
			if {0}.pretty then
				{0}.buf = {0}.buf + Chr(10)
				__JsonPrinter_ipad__({0})
			end if
			__JsonPrinter_write__({0}, __jw_i, {1}[__jw_i])
			if __jw_i = __jw_last then
				{0}.nind = {0}.nind - 1
				if {0}.pretty then
					{0}.buf = {0}.buf + Chr(10)
					__JsonPrinter_ipad__({0})
				end if
			end if
			__jw_i = __jw_i + 1
		end while
		{0}.buf = {0}.buf + "]"', self, v);
		return brs.Native.invalid();
	}

	// Associative Array (Object, Enum, Class Instance)
	if (t == "roAssociativeArray") {
		var hasIdx:Bool = brs.Native.doesExist(v, "_index");
		var hasStatic:Bool = brs.Native.doesExist(v, "__static__");
		if (hasIdx == true) {
			if (hasStatic != true) {
				// Enum value — output index
				untyped __brs__('{0}.buf = {0}.buf + Str(0 + {1}._index).Trim()', self, v);
				return brs.Native.invalid();
			}
		}
		BrsJsonPrinter.objString(self, v);
		return brs.Native.invalid();
	}

	// Function
	if (t == "roFunction") {
		BrsJsonPrinter.quote(self, "<fun>");
		return brs.Native.invalid();
	}
	if (t == "Function") {
		BrsJsonPrinter.quote(self, "<fun>");
		return brs.Native.invalid();
	}

	// Unknown
	untyped __brs__('{0}.buf = {0}.buf + Chr(34) + "???" + Chr(34)', self);
	return brs.Native.invalid();
}
