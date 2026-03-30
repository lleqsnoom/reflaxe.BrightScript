package;

extern class StringTools {
	@:nativeFunctionCode("(Instr(1, {arg0}, {arg1}) > 0)")
	public static function contains(s:String, value:String):Bool;

	@:nativeFunctionCode("(Left({arg0}, Len({arg1})) = {arg1})")
	public static function startsWith(s:String, start:String):Bool;

	@:nativeFunctionCode("(Right({arg0}, Len({arg1})) = {arg1})")
	public static function endsWith(s:String, end:String):Bool;

	@:nativeFunctionCode("__StringTools_isSpace__({arg0}, {arg1})")
	public static function isSpace(s:String, pos:Int):Bool;

	@:nativeFunctionCode("__StringTools_ltrim__({arg0})")
	public static function ltrim(s:String):String;

	@:nativeFunctionCode("__StringTools_rtrim__({arg0})")
	public static function rtrim(s:String):String;

	@:nativeFunctionCode("{arg0}.Trim()")
	public static function trim(s:String):String;

	@:nativeFunctionCode("__StringTools_lpad__({arg0}, {arg1}, {arg2})")
	public static function lpad(s:String, c:String, l:Int):String;

	@:nativeFunctionCode("__StringTools_rpad__({arg0}, {arg1}, {arg2})")
	public static function rpad(s:String, c:String, l:Int):String;

	@:nativeFunctionCode("__StringTools_replace__({arg0}, {arg1}, {arg2})")
	public static function replace(s:String, substr:String, by:String):String;

	@:runtime public inline static function hex(n:Int, ?digits:Int):String {
		var d = 0;
		if (digits != null)
			d = digits;
		return _hex(n, d);
	}

	@:nativeFunctionCode("__StringTools_hex__({arg0}, {arg1})")
	private static function _hex(n:Int, digits:Int):String;

	@:nativeFunctionCode("__StringTools_fastCodeAt__({arg0}, {arg1})")
	public static function fastCodeAt(s:String, index:Int):Int;

	@:nativeFunctionCode("Asc(Mid({arg0}, {arg1} + 1, 1))")
	public static function unsafeCodeAt(s:String, index:Int):Int;

	@:noUsing @:nativeFunctionCode("({arg0} = -1)")
	public static function isEof(c:Int):Bool;

	@:runtime public inline static function htmlEscape(s:String, ?quotes:Bool):String {
		var q = false;
		if (quotes != null)
			q = quotes;
		return _htmlEscapeImpl(s, q);
	}

	@:nativeFunctionCode("__StringTools_htmlEscape__({arg0}, {arg1})")
	private static function _htmlEscapeImpl(s:String, quotes:Bool):String;

	@:nativeFunctionCode("__StringTools_htmlUnescape__({arg0})")
	public static function htmlUnescape(s:String):String;

	@:nativeFunctionCode("__StringTools_urlEncode__({arg0})")
	public static function urlEncode(s:String):String;

	@:nativeFunctionCode("__StringTools_urlDecode__({arg0})")
	public static function urlDecode(s:String):String;
}

// --- Private typed wrappers for cross-@:brs_global calls ---

private extern class BrsStringTools {
	@:nativeFunctionCode("__StringTools_isUnreserved__({arg0})")
	static function isUnreserved(c:Int):Bool;

	@:nativeFunctionCode("__StringTools_hex__({arg0}, {arg1})")
	static function hex(n:Int, digits:Int):String;

	@:nativeFunctionCode("__StringTools_parseHexByte__({arg0})")
	static function parseHexByte(hex:String):Int;

	@:nativeFunctionCode("__StringTools_hexCharToInt__({arg0})")
	static function hexCharToInt(c:Int):Int;
}

// --- @:brs_global helper functions ---

@:keep @:brs_global function __StringTools_isSpace__(s:String, pos:Int):Bool {
	if (pos < 0) return false;
	var sLen = brs.Native.len(s);
	if (pos >= sLen) return false;
	var c = brs.Native.charCodeAt(s, pos);
	if (c == 32) return true;
	if (c >= 9) {
		if (c <= 13) return true;
	}
	return false;
}

@:keep @:brs_global function __StringTools_ltrim__(s:String):String {
	var sLen = brs.Native.len(s);
	var r = 0;
	while (r < sLen) {
		var c = brs.Native.charCodeAt(s, r);
		if (c != 32) {
			if (c < 9) return brs.Native.midFrom(s, r);
			if (c > 13) return brs.Native.midFrom(s, r);
		}
		r = r + 1;
	}
	return "";
}

@:keep @:brs_global function __StringTools_rtrim__(s:String):String {
	var sLen = brs.Native.len(s);
	var r = sLen - 1;
	while (r >= 0) {
		var c = brs.Native.charCodeAt(s, r);
		if (c != 32) {
			if (c < 9) return brs.Native.left(s, r + 1);
			if (c > 13) return brs.Native.left(s, r + 1);
		}
		r = r - 1;
	}
	return "";
}

@:keep @:brs_global function __StringTools_lpad__(s:String, c:String, l:Int):String {
	var cLen = brs.Native.len(c);
	if (cLen <= 0) return s;
	var pad = "";
	var sLen = brs.Native.len(s);
	var needed = l - sLen;
	var padLen = 0;
	while (padLen < needed) {
		pad = pad + c;
		padLen = padLen + cLen;
	}
	return pad + s;
}

@:keep @:brs_global function __StringTools_rpad__(s:String, c:String, l:Int):String {
	var cLen = brs.Native.len(c);
	if (cLen <= 0) return s;
	var result = s;
	var rLen = brs.Native.len(s);
	while (rLen < l) {
		result = result + c;
		rLen = rLen + cLen;
	}
	return result;
}

@:keep @:brs_global function __StringTools_replace__(s:String, substr:String, by:String):String {
	if (substr == "") {
		if (by == "") return s;
		var result = "";
		var sLen = brs.Native.len(s);
		var i = 0;
		while (i < sLen) {
			if (i > 0) result = result + by;
			result = result + brs.Native.mid(s, i, 1);
			i = i + 1;
		}
		return result;
	}
	return brs.Native.replace(s, substr, by);
}

@:keep @:brs_global function __StringTools_hex__(n:Int, digits:Int):String {
	var s = "";
	var hexChars = "0123456789ABCDEF";
	var num = n;
	// First iteration (do-while equivalent)
	var nibble:Int = brs.Native.bitwiseAnd(num, 15);
	s = brs.Native.mid(hexChars, nibble, 1) + s;
	num = brs.Native.bitwiseAnd(brs.Native.shiftRight(num, 4), 268435455);
	// Remaining iterations
	while (num > 0) {
		nibble = brs.Native.bitwiseAnd(num, 15);
		s = brs.Native.mid(hexChars, nibble, 1) + s;
		num = brs.Native.bitwiseAnd(brs.Native.shiftRight(num, 4), 268435455);
	}
	// Pad with zeros if needed
	if (digits > 0) {
		var sLen = brs.Native.len(s);
		while (sLen < digits) {
			s = "0" + s;
			sLen = sLen + 1;
		}
	}
	return s;
}

@:keep @:brs_global function __StringTools_fastCodeAt__(s:String, index:Int):Int {
	var sLen = brs.Native.len(s);
	if (index >= sLen) return -1;
	return brs.Native.charCodeAt(s, index);
}

@:keep @:brs_global function __StringTools_htmlEscape__(s:String, quotes:Bool):String {
	var result:String = brs.Native.replace(s, "&", "&amp;");
	result = brs.Native.replace(result, "<", "&lt;");
	result = brs.Native.replace(result, ">", "&gt;");
	if (quotes == true) {
		result = brs.Native.replace(result, brs.Native.chr(34), "&quot;");
		result = brs.Native.replace(result, brs.Native.chr(39), "&#039;");
	}
	return result;
}

@:keep @:brs_global function __StringTools_htmlUnescape__(s:String):String {
	var result:String = brs.Native.replace(s, "&lt;", "<");
	result = brs.Native.replace(result, "&gt;", ">");
	result = brs.Native.replace(result, "&quot;", brs.Native.chr(34));
	result = brs.Native.replace(result, "&#039;", brs.Native.chr(39));
	result = brs.Native.replace(result, "&amp;", "&");
	return result;
}

@:keep @:brs_global function __StringTools_urlEncode__(s:String):String {
	var result = "";
	var sLen = brs.Native.len(s);
	var i = 0;
	while (i < sLen) {
		var c = brs.Native.charCodeAt(s, i);
		var unreserved:Bool = BrsStringTools.isUnreserved(c);
		if (unreserved == true) {
			result = result + brs.Native.chr(c);
		} else {
			var hexStr:String = BrsStringTools.hex(c, 2);
			result = result + "%" + hexStr;
		}
		i = i + 1;
	}
	return result;
}

@:keep @:brs_global function __StringTools_isUnreserved__(c:Int):Bool {
	// A-Z (65-90)
	if (c >= 65) {
		if (c <= 90) return true;
	}
	// a-z (97-122)
	if (c >= 97) {
		if (c <= 122) return true;
	}
	// 0-9 (48-57)
	if (c >= 48) {
		if (c <= 57) return true;
	}
	// - (45)
	if (c == 45) return true;
	// _ (95)
	if (c == 95) return true;
	// . (46)
	if (c == 46) return true;
	// ~ (126)
	if (c == 126) return true;
	return false;
}

@:keep @:brs_global function __StringTools_urlDecode__(s:String):String {
	var result = "";
	var sLen = brs.Native.len(s);
	var i = 0;
	while (i < sLen) {
		var c = brs.Native.mid(s, i, 1);
		if (c == "%") {
			if (i + 2 < sLen) {
				var hex = brs.Native.mid(s, i + 1, 2);
				var code:Int = BrsStringTools.parseHexByte(hex);
				result = result + brs.Native.chr(code);
				i = i + 3;
			} else {
				result = result + c;
				i = i + 1;
			}
		} else if (c == "+") {
			result = result + " ";
			i = i + 1;
		} else {
			result = result + c;
			i = i + 1;
		}
	}
	return result;
}

@:keep @:brs_global function __StringTools_parseHexByte__(hex:String):Int {
	var hexUpper:String = brs.Native.ucase(hex);
	var h:Int = brs.Native.charCodeAt(hexUpper, 0);
	var l:Int = brs.Native.charCodeAt(hexUpper, 1);
	var hi:Int = BrsStringTools.hexCharToInt(h);
	var lo:Int = BrsStringTools.hexCharToInt(l);
	return hi * 16 + lo;
}

@:keep @:brs_global function __StringTools_hexCharToInt__(c:Int):Int {
	// 0-9: ASCII 48-57
	if (c >= 48) {
		if (c <= 57) return c - 48;
	}
	// A-F: ASCII 65-70
	if (c >= 65) {
		if (c <= 70) return c - 55;
	}
	return 0;
}
