package;

extern class DateTools {
	@:nativeFunctionCode("({arg0} * 86400000.0)")
	public static function days(n:Float):Float;

	@:nativeFunctionCode("({arg0} * 3600000.0)")
	public static function hours(n:Float):Float;

	@:nativeFunctionCode("({arg0} * 60000.0)")
	public static function minutes(n:Float):Float;

	@:nativeFunctionCode("({arg0} * 1000.0)")
	public static function seconds(n:Float):Float;

	@:nativeFunctionCode("__DateTools_delta__({arg0}, {arg1})")
	public static function delta(d:Date, t:Float):Date;

	@:nativeFunctionCode("__DateTools_format__({arg0}, {arg1})")
	public static function format(d:Date, f:String):String;

	@:nativeFunctionCode("__DateTools_getMonthDays__({arg0})")
	public static function getMonthDays(d:Date):Int;

	@:nativeFunctionCode("__DateTools_parse__({arg0})")
	public static function parse(t:Float):{ms:Float, seconds:Int, minutes:Int, hours:Int, days:Int};

	@:nativeFunctionCode("__DateTools_make__({arg0})")
	public static function make(o:{ms:Float, seconds:Int, minutes:Int, hours:Int, days:Int}):Float;

	@:nativeFunctionCode("__DateTools_makeUtc__({arg0}, {arg1}, {arg2}, {arg3}, {arg4}, {arg5})")
	public static function makeUtc(year:Int, month:Int, day:Int, hour:Int, min:Int, sec:Int):Float;
}

// --- Helper: zero-pad to 2 digits ---

private extern class BrsDateToolsPad {
	@:nativeFunctionCode("Right(\"0\" + Str({arg0}).Trim(), 2)")
	static function pad2(n:Int):String;
}

// --- @:brs_global helper functions ---

@:keep @:brs_global function __DateTools_delta__(d:Dynamic, t:Float):Dynamic {
	untyped __brs__('__dtNewSecs = {0}.s + Int({1} / 1000)', d, t);
	return untyped __brs__('{"s": __dtNewSecs}');
}

@:keep @:brs_global function __DateTools_format__(d:Dynamic, f:String):String {
	// Extract all date components once
	untyped __brs__('
		__DateTools_yr__ = Int(__Date_getFullYear__({0}))
		__DateTools_mo__ = Int(__Date_getMonth__({0}))
		__DateTools_dy__ = Int(__Date_getDate__({0}))
		__DateTools_dow__ = Int(__Date_getDay__({0}))
		__DateTools_hr__ = Int(__Date_getHours__({0}))
		__DateTools_mi__ = Int(__Date_getMinutes__({0}))
		__DateTools_se__ = Int(__Date_getSeconds__({0}))
		__DateTools_tm__ = __Date_getTime__({0})
	', d);

	var dayShort:Dynamic = untyped __brs__('["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]');
	var dayLong:Dynamic = untyped __brs__('["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]');
	var monShort:Dynamic = untyped __brs__('["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]');
	var monLong:Dynamic = untyped __brs__('["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]');

	var result:String = "";
	var fLen:Int = brs.Native.len(f);
	var p:Int = 0;

	while (p < fLen) {
		var ch:String = brs.Native.mid(f, p, 1);
		if (ch == "%") {
			if (p + 1 < fLen) {
				var spec:String = brs.Native.mid(f, p + 1, 1);
				if (spec == "%") {
					result = result + "%";
				} else if (spec == "a") {
					result = result + untyped __brs__('{0}[__DateTools_dow__]', dayShort);
				} else if (spec == "A") {
					result = result + untyped __brs__('{0}[__DateTools_dow__]', dayLong);
				} else if (spec == "b") {
					result = result + untyped __brs__('{0}[__DateTools_mo__]', monShort);
				} else if (spec == "h") {
					result = result + untyped __brs__('{0}[__DateTools_mo__]', monShort);
				} else if (spec == "B") {
					result = result + untyped __brs__('{0}[__DateTools_mo__]', monLong);
				} else if (spec == "C") {
					result = result + BrsDateToolsPad.pad2(untyped __brs__('Int(__DateTools_yr__ / 100)'));
				} else if (spec == "d") {
					result = result + BrsDateToolsPad.pad2(untyped __brs__('__DateTools_dy__'));
				} else if (spec == "D") {
					var mm:String = BrsDateToolsPad.pad2(untyped __brs__('__DateTools_mo__ + 1'));
					var dd:String = BrsDateToolsPad.pad2(untyped __brs__('__DateTools_dy__'));
					var yy:String = BrsDateToolsPad.pad2(untyped __brs__('__DateTools_yr__ MOD 100'));
					result = result + mm + "/" + dd + "/" + yy;
				} else if (spec == "e") {
					result = result + untyped __brs__('Str(__DateTools_dy__).Trim()');
				} else if (spec == "F") {
					var ys:String = untyped __brs__('Str(__DateTools_yr__).Trim()');
					var ms:String = BrsDateToolsPad.pad2(untyped __brs__('__DateTools_mo__ + 1'));
					var ds:String = BrsDateToolsPad.pad2(untyped __brs__('__DateTools_dy__'));
					result = result + ys + "-" + ms + "-" + ds;
				} else if (spec == "H") {
					result = result + BrsDateToolsPad.pad2(untyped __brs__('__DateTools_hr__'));
				} else if (spec == "I") {
					var h12:Int = untyped __brs__('__DateTools_hr__ MOD 12');
					if (h12 == 0) h12 = 12;
					result = result + BrsDateToolsPad.pad2(h12);
				} else if (spec == "k") {
					result = result + untyped __brs__('Right(" " + Str(__DateTools_hr__).Trim(), 2)');
				} else if (spec == "l") {
					var h12:Int = untyped __brs__('__DateTools_hr__ MOD 12');
					if (h12 == 0) h12 = 12;
					result = result + untyped __brs__('Right(" " + Str({0}).Trim(), 2)', h12);
				} else if (spec == "m") {
					result = result + BrsDateToolsPad.pad2(untyped __brs__('__DateTools_mo__ + 1'));
				} else if (spec == "M") {
					result = result + BrsDateToolsPad.pad2(untyped __brs__('__DateTools_mi__'));
				} else if (spec == "n") {
					result = result + brs.Native.chr(10);
				} else if (spec == "p") {
					var ampm:String = "AM";
					if (untyped __brs__('__DateTools_hr__') > 11)
						ampm = "PM";
					result = result + ampm;
				} else if (spec == "r") {
					var h12:Int = untyped __brs__('__DateTools_hr__ MOD 12');
					if (h12 == 0) h12 = 12;
					var ampm:String = "AM";
					if (untyped __brs__('__DateTools_hr__') > 11)
						ampm = "PM";
					result = result + BrsDateToolsPad.pad2(h12) + ":" + BrsDateToolsPad.pad2(untyped __brs__('__DateTools_mi__')) + ":" + BrsDateToolsPad.pad2(untyped __brs__('__DateTools_se__')) + " " + ampm;
				} else if (spec == "R") {
					result = result + BrsDateToolsPad.pad2(untyped __brs__('__DateTools_hr__')) + ":" + BrsDateToolsPad.pad2(untyped __brs__('__DateTools_mi__'));
				} else if (spec == "s") {
					result = result + untyped __brs__('Str(Int(__DateTools_tm__ / 1000)).Trim()');
				} else if (spec == "S") {
					result = result + BrsDateToolsPad.pad2(untyped __brs__('__DateTools_se__'));
				} else if (spec == "t") {
					result = result + brs.Native.chr(9);
				} else if (spec == "T") {
					result = result + BrsDateToolsPad.pad2(untyped __brs__('__DateTools_hr__')) + ":" + BrsDateToolsPad.pad2(untyped __brs__('__DateTools_mi__')) + ":" + BrsDateToolsPad.pad2(untyped __brs__('__DateTools_se__'));
				} else if (spec == "u") {
					var dw:Int = untyped __brs__('__DateTools_dow__');
					if (dw == 0) dw = 7;
					result = result + untyped __brs__('Str({0}).Trim()', dw);
				} else if (spec == "w") {
					result = result + untyped __brs__('Str(__DateTools_dow__).Trim()');
				} else if (spec == "y") {
					result = result + BrsDateToolsPad.pad2(untyped __brs__('__DateTools_yr__ MOD 100'));
				} else if (spec == "Y") {
					result = result + untyped __brs__('Str(__DateTools_yr__).Trim()');
				} else {
					// Unknown specifier — output literally
					result = result + "%" + spec;
				}
				p = p + 2;
			} else {
				// Trailing % at end of string
				result = result + "%";
				p = p + 1;
			}
		} else {
			result = result + ch;
			p = p + 1;
		}
	}
	return result;
}

@:keep @:brs_global function __DateTools_getMonthDays__(d:Dynamic):Int {
	untyped __brs__('
		__dtm_month = Int(__Date_getMonth__({0}))
		__dtm_year = Int(__Date_getFullYear__({0}))
		__dtm_days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	', d);

	var month:Int = untyped __brs__('__dtm_month');

	if (month != 1) {
		return untyped __brs__('__dtm_days[__dtm_month]');
	}

	var year:Int = untyped __brs__('__dtm_year');

	// February: check leap year
	var mod4:Int = untyped __brs__('({0} MOD 4)', year);
	var mod100:Int = untyped __brs__('({0} MOD 100)', year);
	var mod400:Int = untyped __brs__('({0} MOD 400)', year);

	var isLeap:Bool = false;
	if (mod4 == 0) {
		if (mod100 != 0) {
			isLeap = true;
		} else if (mod400 == 0) {
			isLeap = true;
		}
	}

	if (isLeap == true)
		return 29;
	return 28;
}

@:keep @:brs_global function __DateTools_parse__(t:Float):Dynamic {
	untyped __brs__('
		__dtp_s = {0} / 1000.0
		__dtp_m = __dtp_s / 60.0
		__dtp_h = __dtp_m / 60.0
		__dtp_msVal = {0} - Int({0} / 1000) * 1000
		__dtp_secVal = Int(__dtp_s) MOD 60
		__dtp_minVal = Int(__dtp_m) MOD 60
		__dtp_hrVal = Int(__dtp_h) MOD 24
		__dtp_dayVal = Int(__dtp_h / 24)
	', t);

	return untyped __brs__('{"ms": __dtp_msVal, "seconds": __dtp_secVal, "minutes": __dtp_minVal, "hours": __dtp_hrVal, "days": __dtp_dayVal}');
}

@:keep @:brs_global function __DateTools_make__(o:Dynamic):Float {
	untyped __brs__('
		__dtm_ms = {0}["ms"]
		__dtm_sec = {0}["seconds"]
		__dtm_min = {0}["minutes"]
		__dtm_hr = {0}["hours"]
		__dtm_day = {0}["days"]
		__dtm_result = __dtm_ms + 1000.0 * (__dtm_sec + 60.0 * (__dtm_min + 60.0 * (__dtm_hr + 24.0 * __dtm_day)))
	', o);
	return untyped __brs__('__dtm_result');
}

@:keep @:brs_global function __DateTools_makeUtc__(year:Int, month:Int, day:Int, hour:Int, min:Int, sec:Int):Float {
	untyped __brs__('
		__dtmo = Int({1}) + 1
		__dtiso = Str(Int({0})).Trim() + "-" + Right("0" + Str(__dtmo).Trim(), 2) + "-" + Right("0" + Str(Int({2})).Trim(), 2) + "T" + Right("0" + Str(Int({3})).Trim(), 2) + ":" + Right("0" + Str(Int({4})).Trim(), 2) + ":" + Right("0" + Str(Int({5})).Trim(), 2) + "Z"
		__dtobj = CreateObject("roDateTime")
		__dtobj.FromISO8601String(__dtiso)
		__dtsecs = __dtobj.AsSeconds()
	', year, month, day, hour, min, sec);
	return untyped __brs__('__dtsecs * 1000.0');
}
