package;

extern class Date {
	@:nativeFunctionCode("__Date_new__({arg0}, {arg1}, {arg2}, {arg3}, {arg4}, {arg5})")
	function new(year:Int, month:Int, day:Int, hour:Int, min:Int, sec:Int);

	@:nativeFunctionCode("__Date_getFullYear__({this})")
	function getFullYear():Int;

	@:nativeFunctionCode("__Date_getMonth__({this})")
	function getMonth():Int;

	@:nativeFunctionCode("__Date_getDate__({this})")
	function getDate():Int;

	@:nativeFunctionCode("__Date_getDay__({this})")
	function getDay():Int;

	@:nativeFunctionCode("__Date_getHours__({this})")
	function getHours():Int;

	@:nativeFunctionCode("__Date_getMinutes__({this})")
	function getMinutes():Int;

	@:nativeFunctionCode("__Date_getSeconds__({this})")
	function getSeconds():Int;

	@:nativeFunctionCode("__Date_getTime__({this})")
	function getTime():Float;

	@:nativeFunctionCode("__Date_getTimezoneOffset__({this})")
	function getTimezoneOffset():Int;

	@:nativeFunctionCode("__Date_toString__({this})")
	function toString():String;

	@:nativeFunctionCode("__Date_now__()")
	static function now():Date;

	@:nativeFunctionCode("__Date_fromTime__({arg0})")
	static function fromTime(t:Float):Date;

	@:nativeFunctionCode("__Date_fromString__({arg0})")
	static function fromString(s:String):Date;
}

@:keep @:brs_global function __Date_new__(year:Int, month:Int, day:Int, hour:Int, min:Int, sec:Int):Dynamic {
	untyped __brs__('
		__y = Int({0})
		__mo = Int({1}) + 1
		__d = Int({2})
		__h = Int({3})
		__mi = Int({4})
		__se = Int({5})
		__iso = Str(__y).Trim() + "-" + Right("0" + Str(__mo).Trim(), 2) + "-" + Right("0" + Str(__d).Trim(), 2) + "T" + Right("0" + Str(__h).Trim(), 2) + ":" + Right("0" + Str(__mi).Trim(), 2) + ":" + Right("0" + Str(__se).Trim(), 2) + "Z"
		__dt = CreateObject("roDateTime")
		__dt.FromISO8601String(__iso)
		__secs = __dt.AsSeconds() + __dt.GetTimeZoneOffset() * 60
	', year, month, day, hour, min, sec);
	return untyped __brs__('{"s": __secs}');
}

@:keep @:brs_global function __Date_now__():Dynamic {
	untyped __brs__('
		__dt = CreateObject("roDateTime")
		__secs = __dt.AsSeconds()
	');
	return untyped __brs__('{"s": __secs}');
}

@:keep @:brs_global function __Date_fromTime__(t:Float):Dynamic {
	untyped __brs__('__secs = Int({0} / 1000)', t);
	return untyped __brs__('{"s": __secs}');
}

@:keep @:brs_global function __Date_fromString__(s:String):Dynamic {
	untyped __brs__('
		__hasDate = Instr(1, {0}, "-") > 0
		__hasTime = Instr(1, {0}, ":") > 0
		__secs = 0
		if __hasDate and __hasTime then
			__parts = {0}.Split(" ")
			__iso = __parts[0] + "T" + __parts[1] + "Z"
			__dt = CreateObject("roDateTime")
			__dt.FromISO8601String(__iso)
			__secs = __dt.AsSeconds() + __dt.GetTimeZoneOffset() * 60
		else if __hasDate then
			__iso = {0} + "T00:00:00Z"
			__dt = CreateObject("roDateTime")
			__dt.FromISO8601String(__iso)
			__secs = __dt.AsSeconds() + __dt.GetTimeZoneOffset() * 60
		else
			__iso = "1970-01-01T" + {0} + "Z"
			__dt = CreateObject("roDateTime")
			__dt.FromISO8601String(__iso)
			__secs = __dt.AsSeconds()
		end if
	', s);
	return untyped __brs__('{"s": __secs}');
}

@:keep @:brs_global function __Date_getFullYear__(self:Dynamic):Int {
	untyped __brs__('
		__dt = CreateObject("roDateTime")
		__dt.FromSeconds({0}.s)
		__dt.ToLocalTime()
	', self);
	return untyped __brs__('__dt.GetYear()');
}

@:keep @:brs_global function __Date_getMonth__(self:Dynamic):Int {
	untyped __brs__('
		__dt = CreateObject("roDateTime")
		__dt.FromSeconds({0}.s)
		__dt.ToLocalTime()
	', self);
	return untyped __brs__('__dt.GetMonth() - 1');
}

@:keep @:brs_global function __Date_getDate__(self:Dynamic):Int {
	untyped __brs__('
		__dt = CreateObject("roDateTime")
		__dt.FromSeconds({0}.s)
		__dt.ToLocalTime()
	', self);
	return untyped __brs__('__dt.GetDayOfMonth()');
}

@:keep @:brs_global function __Date_getDay__(self:Dynamic):Int {
	untyped __brs__('
		__dt = CreateObject("roDateTime")
		__dt.FromSeconds({0}.s)
		__dt.ToLocalTime()
	', self);
	return untyped __brs__('__dt.GetDayOfWeek()');
}

@:keep @:brs_global function __Date_getHours__(self:Dynamic):Int {
	untyped __brs__('
		__dt = CreateObject("roDateTime")
		__dt.FromSeconds({0}.s)
		__dt.ToLocalTime()
	', self);
	return untyped __brs__('__dt.GetHours()');
}

@:keep @:brs_global function __Date_getMinutes__(self:Dynamic):Int {
	untyped __brs__('
		__dt = CreateObject("roDateTime")
		__dt.FromSeconds({0}.s)
		__dt.ToLocalTime()
	', self);
	return untyped __brs__('__dt.GetMinutes()');
}

@:keep @:brs_global function __Date_getSeconds__(self:Dynamic):Int {
	untyped __brs__('
		__dt = CreateObject("roDateTime")
		__dt.FromSeconds({0}.s)
		__dt.ToLocalTime()
	', self);
	return untyped __brs__('__dt.GetSeconds()');
}

@:keep @:brs_global function __Date_getTimezoneOffset__(self:Dynamic):Int {
	untyped __brs__('
		__dt = CreateObject("roDateTime")
	');
	return untyped __brs__('__dt.GetTimeZoneOffset()');
}

@:keep @:brs_global function __Date_toString__(self:Dynamic):String {
	untyped __brs__('
		__dt = CreateObject("roDateTime")
		__dt.FromSeconds({0}.s)
		__dt.ToLocalTime()
		__y = Str(__dt.GetYear()).Trim()
		__mo = Right("0" + Str(__dt.GetMonth()).Trim(), 2)
		__d = Right("0" + Str(__dt.GetDayOfMonth()).Trim(), 2)
		__h = Right("0" + Str(__dt.GetHours()).Trim(), 2)
		__mi = Right("0" + Str(__dt.GetMinutes()).Trim(), 2)
		__se = Right("0" + Str(__dt.GetSeconds()).Trim(), 2)
		__result = __y + "-" + __mo + "-" + __d + " " + __h + ":" + __mi + ":" + __se
	', self);
	return untyped __brs__('__result');
}

@:keep @:brs_global function __Date_getTime__(self:Dynamic):Float {
	untyped __brs__('__ms = {0}.s * 1000.0', self);
	return untyped __brs__('__ms');
}
