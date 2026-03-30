package;

extern class Math {
	@:nativeFunctionCode("3.141592653589793")
	static var PI(default, null):Float;

	@:nativeFunctionCode("(0.0 / 0.0)")
	static var NaN(default, null):Float;

	@:nativeFunctionCode("(1.0 / 0.0)")
	static var POSITIVE_INFINITY(default, null):Float;

	@:nativeFunctionCode("(-1.0 / 0.0)")
	static var NEGATIVE_INFINITY(default, null):Float;

	@:nativeFunctionCode("Abs({arg0})")
	static function abs(v:Float):Float;

	@:nativeFunctionCode("Sin({arg0})")
	static function sin(v:Float):Float;

	@:nativeFunctionCode("Cos({arg0})")
	static function cos(v:Float):Float;

	@:nativeFunctionCode("Tan({arg0})")
	static function tan(v:Float):Float;

	@:nativeFunctionCode("Exp({arg0})")
	static function exp(v:Float):Float;

	@:nativeFunctionCode("Log({arg0})")
	static function log(v:Float):Float;

	@:nativeFunctionCode("Sqr({arg0})")
	static function sqrt(v:Float):Float;

	@:nativeFunctionCode("Atn({arg0})")
	static function atan(v:Float):Float;

	@:nativeFunctionCode("Rnd(0)")
	static function random():Float;

	@:nativeFunctionCode("({arg0} ^ {arg1})")
	static function pow(v:Float, exp:Float):Float;

	@:nativeFunctionCode("__Math_asin__({arg0})")
	static function asin(v:Float):Float;

	@:nativeFunctionCode("__Math_acos__({arg0})")
	static function acos(v:Float):Float;

	@:nativeFunctionCode("__Math_atan2__({arg0}, {arg1})")
	static function atan2(y:Float, x:Float):Float;

	@:nativeFunctionCode("__Math_ceil__({arg0})")
	static function ceil(v:Float):Int;

	@:nativeFunctionCode("__Math_floor__({arg0})")
	static function floor(v:Float):Int;

	@:nativeFunctionCode("__Math_round__({arg0})")
	static function round(v:Float):Int;

	@:nativeFunctionCode("__Math_fceil__({arg0})")
	static function fceil(v:Float):Float;

	@:nativeFunctionCode("__Math_ffloor__({arg0})")
	static function ffloor(v:Float):Float;

	@:nativeFunctionCode("__Math_fround__({arg0})")
	static function fround(v:Float):Float;

	@:nativeFunctionCode("__Math_max__({arg0}, {arg1})")
	static function max(a:Float, b:Float):Float;

	@:nativeFunctionCode("__Math_min__({arg0}, {arg1})")
	static function min(a:Float, b:Float):Float;

	@:runtime public inline static function isNaN(f:Float):Bool {
		return f != f;
	}

	@:nativeFunctionCode("__Math_isFinite__({arg0})")
	static function isFinite(f:Float):Bool;
}

@:keep @:brs_global function __Math_isFinite__(f:Float) {
	if (f != f)
		return false;
	if (f - f != 0.0)
		return false;
	return true;
}

@:keep @:brs_global function __Math_floor__(v:Float) {
	final i = Std.int(v);
	if (v < i)
		return i - 1;
	return i;
}

@:keep @:brs_global function __Math_ceil__(v:Float) {
	final i = Std.int(v);
	if (v > i)
		return i + 1;
	return i;
}

@:keep @:brs_global function __Math_round__(v:Float) {
	final v2 = v + 0.5;
	final i = Std.int(v2);
	if (v2 < i)
		return i - 1;
	return i;
}

@:keep @:brs_global function __Math_ffloor__(v:Float) {
	final i = Std.int(v);
	if (v < i)
		return i - 1.0;
	return i + 0.0;
}

@:keep @:brs_global function __Math_fceil__(v:Float) {
	final i = Std.int(v);
	if (v > i)
		return i + 1.0;
	return i + 0.0;
}

@:keep @:brs_global function __Math_fround__(v:Float) {
	final v2 = v + 0.5;
	final i = Std.int(v2);
	if (v2 < i)
		return i - 1.0;
	return i + 0.0;
}

@:keep @:brs_global function __Math_max__(a:Float, b:Float) {
	if (a >= b)
		return a;
	return b;
}

@:keep @:brs_global function __Math_min__(a:Float, b:Float) {
	if (a <= b)
		return a;
	return b;
}

@:keep @:brs_global function __Math_asin__(v:Float) {
	if (v >= 1.0)
		return Math.PI / 2.0;
	if (v <= -1.0)
		return -(Math.PI / 2.0);
	return Math.atan(v / Math.sqrt(1.0 - v * v));
}

@:keep @:brs_global function __Math_acos__(v:Float) {
	if (v >= 1.0)
		return 0.0;
	if (v <= -1.0)
		return Math.PI;
	return Math.PI / 2.0 - Math.atan(v / Math.sqrt(1.0 - v * v));
}

@:keep @:brs_global function __Math_atan2__(y:Float, x:Float) {
	if (x > 0.0)
		return Math.atan(y / x);
	if (x < 0.0) {
		if (y >= 0.0)
			return Math.atan(y / x) + Math.PI;
		return Math.atan(y / x) - Math.PI;
	}
	if (y > 0.0)
		return Math.PI / 2.0;
	if (y < 0.0)
		return -(Math.PI / 2.0);
	return 0.0;
}
