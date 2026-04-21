package;

extern class EReg {
	@:nativeFunctionCode("__EReg_new__({arg0}, {arg1})")
	function new(r:String, opt:String):Void;

	@:nativeFunctionCode("__EReg_match__({this}, {arg0})")
	function match(s:String):Bool;

	@:nativeFunctionCode("__EReg_matched__({this}, {arg0})")
	function matched(n:Int):String;

	@:nativeFunctionCode("__EReg_matchedLeft__({this})")
	function matchedLeft():String;

	@:nativeFunctionCode("__EReg_matchedRight__({this})")
	function matchedRight():String;

	@:nativeFunctionCode("__EReg_matchedPos__({this})")
	function matchedPos():{pos:Int, len:Int};

	@:runtime public inline function matchSub(s:String, pos:Int, len:Int = -1):Bool {
		return brsMatchSub(s, pos, len);
	}

	@:nativeFunctionCode("__EReg_matchSub__({this}, {arg0}, {arg1}, {arg2})")
	private function brsMatchSub(s:String, pos:Int, len:Int):Bool;

	@:nativeFunctionCode("__EReg_split__({this}, {arg0})")
	function split(s:String):Array<String>;

	@:nativeFunctionCode("__EReg_replace__({this}, {arg0}, {arg1})")
	function replace(s:String, by:String):String;

	@:nativeFunctionCode("__EReg_map__({this}, {arg0}, {arg1})")
	function map(s:String, f:EReg->String):String;

	@:nativeFunctionCode("__EReg_escape__({arg0})")
	static function escape(s:String):String;
}

@:keep @:brs_global function __EReg_new__(pattern:String, opts:String):Dynamic {
	var isGlobal:Bool = brs.Native.instr(opts, "g") >= 0;
	var cleanOpts = StringTools.replace(opts, "g", "");
	untyped __brs__('__regex = CreateObject("roRegex", {0}, {1})', pattern, cleanOpts);
	return untyped __brs__('{"r": __regex, "s": "", "ms": "", "g": {0}, "fm": "", "pos": -1, "ok": false}', isGlobal);
}

// Match using IsMatch + Replace with Chr(1) markers to find position and full match text.
// roRegex.Match() is broken in the brs npm emulator, so we use Replace("$&") instead.
@:keep @:brs_global function __EReg_match__(self:Dynamic, s:String):Bool {
	untyped __brs__('{0}.s = {1}', self, s);
	untyped __brs__('{0}.ms = {1}', self, s);
	var ok:Bool = untyped __brs__('{0}.r.IsMatch({1})', self, s);
	untyped __brs__('{0}.ok = {1}', self, ok);
	if (ok == true) {
		var mk = brs.Native.chr(1);
		var replacement = mk + "$&" + mk;
		var marked:String = untyped __brs__('{0}.r.Replace({1}, {2})', self, s, replacement);
		var p1 = brs.Native.instr(marked, mk);
		var p2 = brs.Native.instrFrom(p1 + 1, marked, mk);
		var fm = brs.Native.mid(marked, p1 + 1, p2 - p1 - 1);
		untyped __brs__('{0}.fm = {1}', self, fm);
		untyped __brs__('{0}.pos = {1}', self, p1);
	} else {
		untyped __brs__('{0}.fm = ""', self);
		untyped __brs__('{0}.pos = -1', self);
	}
	return ok;
}

// Extract matched group n. n=0 returns full match, n>0 returns capture group via Replace("$N").
@:keep @:brs_global function __EReg_matched__(self:Dynamic, n:Int):String {
	if (n == 0) {
		return untyped __brs__('{0}.fm', self);
	}
	var mk = brs.Native.chr(1);
	var repl = mk + "$" + String.fromCharCode(48 + n) + mk;
	var ms:String = untyped __brs__('{0}.ms', self);
	var marked:String = untyped __brs__('{0}.r.Replace({1}, {2})', self, ms, repl);
	var q1 = brs.Native.instr(marked, mk);
	var q2 = brs.Native.instrFrom(q1 + 1, marked, mk);
	return brs.Native.mid(marked, q1 + 1, q2 - q1 - 1);
}

@:keep @:brs_global function __EReg_matchedLeft__(self:Dynamic):String {
	var s:String = untyped __brs__('{0}.s', self);
	var p:Int = untyped __brs__('{0}.pos', self);
	return brs.Native.left(s, p);
}

@:keep @:brs_global function __EReg_matchedRight__(self:Dynamic):String {
	var s:String = untyped __brs__('{0}.s', self);
	var fm:String = untyped __brs__('{0}.fm', self);
	var p:Int = untyped __brs__('{0}.pos', self);
	var start = p + fm.length;
	return brs.Native.midFrom(s, start);
}

@:keep @:brs_global function __EReg_matchedPos__(self:Dynamic):Dynamic {
	var p:Int = untyped __brs__('{0}.pos', self);
	var fm:String = untyped __brs__('{0}.fm', self);
	return untyped __brs__('{"pos": {0}, "len": {1}}', p, fm.length);
}

@:keep @:brs_global function __EReg_matchSub__(self:Dynamic, s:String, pos:Int, len:Int):Bool {
	untyped __brs__('{0}.s = {1}', self, s);
	var subStr = brs.Native.midFrom(s, pos);
	if (len >= 0) {
		subStr = brs.Native.mid(s, pos, len);
	}
	untyped __brs__('{0}.ms = {1}', self, subStr);
	var ok:Bool = untyped __brs__('{0}.r.IsMatch({1})', self, subStr);
	untyped __brs__('{0}.ok = {1}', self, ok);
	if (ok == true) {
		var mk = brs.Native.chr(1);
		var replacement = mk + "$&" + mk;
		var marked:String = untyped __brs__('{0}.r.Replace({1}, {2})', self, subStr, replacement);
		var p1 = brs.Native.instr(marked, mk);
		var p2 = brs.Native.instrFrom(p1 + 1, marked, mk);
		var fm = brs.Native.mid(marked, p1 + 1, p2 - p1 - 1);
		untyped __brs__('{0}.fm = {1}', self, fm);
		untyped __brs__('{0}.pos = {1}', self, p1 + pos);
	} else {
		untyped __brs__('{0}.fm = ""', self);
		untyped __brs__('{0}.pos = -1', self);
	}
	return ok;
}

// Non-global splits at first match only, global splits at all.
// Uses Replace/ReplaceAll with Chr(1) marker, then String.split() on the marker.
@:keep @:brs_global function __EReg_split__(self:Dynamic, s:String):Array<String> {
	var mk = brs.Native.chr(1);
	var isGlobal:Bool = untyped __brs__('{0}.g', self);
	var replaced:String = untyped __brs__('{0}.r.Replace({1}, {2})', self, s, mk);
	if (isGlobal == true) {
		replaced = untyped __brs__('{0}.r.ReplaceAll({1}, {2})', self, s, mk);
	}
	return replaced.split(mk);
}

@:keep @:brs_global function __EReg_replace__(self:Dynamic, s:String, by:String):String {
	var isGlobal:Bool = untyped __brs__('{0}.g', self);
	if (isGlobal == true) {
		return untyped __brs__('{0}.r.ReplaceAll({1}, {2})', self, s, by);
	}
	return untyped __brs__('{0}.r.Replace({1}, {2})', self, s, by);
}

// Map: call callback for each match. Sets internal state so matched() etc. work in callback.
@:keep @:brs_global inline function __EReg_map__(self:Dynamic, s:String, f:Dynamic):String {
	var mk = brs.Native.chr(1);
	var isGlobal:Bool = untyped __brs__('{0}.g', self);
	if (isGlobal == true) {
		var mapResult = "";
		var remaining = s;
		var cont = 1;
		while (cont > 0) {
			var ok:Bool = untyped __brs__('{0}.r.IsMatch({1})', self, remaining);
			if (ok != true) {
				cont = 0;
			} else {
				var replacement = mk + "$&" + mk;
				var marked:String = untyped __brs__('{0}.r.Replace({1}, {2})', self, remaining, replacement);
				var p1 = brs.Native.instr(marked, mk);
				var p2 = brs.Native.instrFrom(p1 + 1, marked, mk);
				var fm = brs.Native.mid(marked, p1 + 1, p2 - p1 - 1);
				untyped __brs__('{0}.s = {1}', self, remaining);
				untyped __brs__('{0}.ms = {1}', self, remaining);
				untyped __brs__('{0}.fm = {1}', self, fm);
				untyped __brs__('{0}.pos = {1}', self, p1);
				untyped __brs__('{0}.ok = true', self);
				var cb:String = f(self);//untyped __brs__('{0}({1})', f, self);
				var leftPart = brs.Native.left(remaining, p1);
				mapResult = mapResult + leftPart + cb;
				var ml = fm.length;
				if (ml == 0) {
					if (remaining.length > p1) {
						var oneChar = brs.Native.mid(remaining, p1, 1);
						mapResult = mapResult + oneChar;
						remaining = brs.Native.midFrom(remaining, p1 + 1);
					} else {
						cont = 0;
					}
				} else {
					remaining = brs.Native.midFrom(remaining, p1 + ml);
				}
			}
		}
		return mapResult + remaining;
	}
	// Non-global case
	var hasMatch:Bool = untyped __brs__('{0}.r.IsMatch({1})', self, s);
	if (hasMatch == true) {
		var replacement = mk + "$&" + mk;
		var marked:String = untyped __brs__('{0}.r.Replace({1}, {2})', self, s, replacement);
		var p1 = brs.Native.instr(marked, mk);
		var p2 = brs.Native.instrFrom(p1 + 1, marked, mk);
		var fm:String = brs.Native.mid(marked, p1 + 1, p2 - p1 - 1);
		untyped __brs__('{0}.s = {1}', self, s);
		untyped __brs__('{0}.ms = {1}', self, s);
		untyped __brs__('{0}.fm = {1}', self, fm);
		untyped __brs__('{0}.pos = {1}', self, p1);
		untyped __brs__('{0}.ok = true', self);
		var ml = fm.length;
		var cb:String = f(self);
		var leftPart = brs.Native.left(s, p1);
		var rightPart = brs.Native.midFrom(s, p1 + ml);
		return leftPart + cb + rightPart;
	}
	return s;
}

@:keep @:brs_global function __EReg_escape__(s:String):String {
	var bs = brs.Native.chr(92);
	var r = StringTools.replace(s, bs, bs + bs);
	r = StringTools.replace(r, ".", bs + ".");
	r = StringTools.replace(r, "+", bs + "+");
	r = StringTools.replace(r, "*", bs + "*");
	r = StringTools.replace(r, "?", bs + "?");
	r = StringTools.replace(r, "[", bs + "[");
	r = StringTools.replace(r, "]", bs + "]");
	r = StringTools.replace(r, "^", bs + "^");
	r = StringTools.replace(r, "$", bs + "$");
	r = StringTools.replace(r, "(", bs + "(");
	r = StringTools.replace(r, ")", bs + ")");
	r = StringTools.replace(r, "{", bs + "{");
	r = StringTools.replace(r, "}", bs + "}");
	r = StringTools.replace(r, "|", bs + "|");
	return r;
}
