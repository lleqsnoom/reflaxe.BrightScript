package brs;

/**
 * BRS native operation helpers. Each method compiles to a single BRS expression
 * via @:nativeFunctionCode, safe to call from @:brs_global functions.
 *
 * String position parameters are 0-based (converted to BRS 1-based internally).
 */
extern class Native {
	// --- Type & equality ---

	@:nativeFunctionCode("Type({arg0})")
	public static function typeOf(v:Dynamic):String;

	@:nativeFunctionCode("({arg0} = {arg1})")
	public static function eq(a:Dynamic, b:Dynamic):Bool;

	@:nativeFunctionCode("({arg0} <> {arg1})")
	public static function neq(a:Dynamic, b:Dynamic):Bool;

	@:nativeFunctionCode("invalid")
	public static function invalid():Dynamic;

	// --- Associative Array ---

	@:nativeFunctionCode("{arg0}.DoesExist({arg1})")
	public static function doesExist(obj:Dynamic, field:String):Bool;

	// --- Array / Collection ---

	@:nativeFunctionCode("{arg0}.Count()")
	public static function count(arr:Dynamic):Int;

	@:nativeFunctionCode("{arg0}.Push({arg1})")
	public static function push(arr:Dynamic, val:Dynamic):Void;

	@:nativeFunctionCode("{arg0}.Delete({arg1})")
	public static function delete(arr:Dynamic, idx:Dynamic):Void;

	@:nativeFunctionCode("{arg0}.Append({arg1})")
	public static function append(arr:Dynamic, other:Dynamic):Void;

	// --- String operations (0-based positions) ---

	@:nativeFunctionCode("Len({arg0})")
	public static function len(s:Dynamic):Int;

	@:nativeFunctionCode("Mid({arg0}, {arg1} + 1, {arg2})")
	public static function mid(s:Dynamic, pos:Int, len:Int):String;

	@:nativeFunctionCode("Mid({arg0}, {arg1} + 1)")
	public static function midFrom(s:Dynamic, pos:Int):String;

	@:nativeFunctionCode("Left({arg0}, {arg1})")
	public static function left(s:Dynamic, len:Int):String;

	@:nativeFunctionCode("Instr(1, {arg0}, {arg1}) - 1")
	public static function instr(s:Dynamic, sub:String):Int;

	@:nativeFunctionCode("Instr({arg0} + 1, {arg1}, {arg2}) - 1")
	public static function instrFrom(startPos:Int, s:Dynamic, sub:String):Int;

	@:nativeFunctionCode("Asc(Mid({arg0}, {arg1} + 1, 1))")
	public static function charCodeAt(s:Dynamic, pos:Int):Int;

	@:nativeFunctionCode("Chr({arg0})")
	public static function chr(code:Int):String;

	// --- Type coercion ---

	@:nativeFunctionCode("0 + {arg0}")
	public static function toInt(v:Dynamic):Int;

	// --- Array element access ---

	@:nativeFunctionCode("{arg0}[{arg1}]")
	public static function arrayGet(arr:Dynamic, idx:Int):Dynamic;

	@:nativeFunctionCode("{arg0}[{arg1}] = {arg2}")
	public static function arraySet(arr:Dynamic, idx:Int, val:Dynamic):Void;

	// --- Dynamic field access (workaround: FDynamic compiles to m.$name) ---

	@:nativeFunctionCode("{arg0}[{arg1}]")
	public static function fieldGet(obj:Dynamic, field:String):Dynamic;

	@:nativeFunctionCode("{arg0}[{arg1}] = {arg2}")
	public static function fieldSet(obj:Dynamic, field:String, val:Dynamic):Void;

	// --- Associative Array methods ---

	@:nativeFunctionCode("{arg0}.Keys()")
	public static function keys(obj:Dynamic):Dynamic;

	@:nativeFunctionCode("{arg0}.Lookup({arg1})")
	public static function lookup(obj:Dynamic, key:String):Dynamic;

	// --- Conversion ---

	@:nativeFunctionCode("__DynToStr__({arg0})")
	public static function dynToStr(v:Dynamic):String;

	@:nativeFunctionCode("{arg0}.Replace({arg1}, {arg2})")
	public static function replace(s:Dynamic, from:String, to:String):String;

	@:nativeFunctionCode("Str({arg0}).Trim()")
	public static function intToStr(v:Int):String;

	// --- Constructors ---

	@:nativeFunctionCode("[]")
	public static function emptyArray():Dynamic;

	@:nativeFunctionCode("{}")
	public static function emptyAA():Dynamic;

	@:nativeFunctionCode("{arg0}.SetModeCaseSensitive()")
	public static function setCaseSensitive(obj:Dynamic):Void;

	// --- Numeric conversion ---

	@:nativeFunctionCode("Int(Val({arg0}))")
	public static function intOfVal(s:Dynamic):Int;

	// --- Case conversion ---

	@:nativeFunctionCode("UCase({arg0})")
	public static function ucase(s:String):String;

	// --- Bitwise operations ---

	@:nativeFunctionCode("({arg0} And {arg1})")
	public static function bitwiseAnd(a:Int, b:Int):Int;

	@:nativeFunctionCode("({arg0} >> {arg1})")
	public static function shiftRight(a:Int, b:Int):Int;
}
