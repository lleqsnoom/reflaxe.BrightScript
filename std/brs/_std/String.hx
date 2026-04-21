package;

extern class String {
	@:nativeFunctionCode("Len({this})")
	var length(default, null):Int;

	@:nativeFunctionCode("{arg0}")
	function new(string:String):Void;

	@:nativeFunctionCode("UCase({this})")
	function toUpperCase():String;

	@:nativeFunctionCode("LCase({this})")
	function toLowerCase():String;

	@:nativeFunctionCode("Mid({this}, {arg0} + 1, 1)")
	function charAt(index:Int):String;

	@:nativeFunctionCode("Asc(Mid({this}, {arg0} + 1, 1))")
	function charCodeAt(index:Int):Null<Int>;

	@:runtime public inline function indexOf(str:String, ?startIndex:Int):Int {
		var sI = 0;
		if (startIndex != null)
			sI = startIndex;
		return brsInstr(sI + 1, str) - 1;
	}

	@:nativeFunctionCode("Instr({arg0}, {this}, {arg1})")
	private function brsInstr(startPos:Int, substr:String):Int;

	@:runtime public inline function lastIndexOf(str:String, ?startIndex:Int):Int {
		var searchLen = brsLen(str);
		var maxI = brsLength() - searchLen;
		if (startIndex != null) {
			if (startIndex < maxI)
				maxI = startIndex;
		}
		var found = -1;
		var i = 0;
		while (i <= maxI) {
			if (brsInstr(i + 1, str) == i + 1) {
				found = i;
			}
			i++;
		}
		return found;
	}

	@:nativeFunctionCode("Len({this})")
	private function brsLength():Int;

	@:nativeFunctionCode("Len({arg0})")
	private function brsLen(s:String):Int;

	@:nativeFunctionCode("{this}.Split({arg0})")
	function split(delimiter:String):Array<String>;

	@:runtime public inline function substr(startIndex:Int, ?len:Int):String {
		var count = brsLength() - startIndex;
		if (len != null)
			count = len;
		return brsMid(startIndex + 1, count);
	}

	@:runtime public inline function substring(startIndex:Int, ?endIndex:Int):String {
		var sI = startIndex;
		var eI = brsLength();
		if (endIndex != null)
			eI = endIndex;
		if (sI > eI) {
			var tmp = sI;
			sI = eI;
			eI = tmp;
		}
		if (sI < 0)
			sI = 0;
		return brsMid(sI + 1, eI - sI);
	}

	@:nativeFunctionCode("Mid({this}, {arg0}, {arg1})")
	private function brsMid(startPos:Int, count:Int):String;

	@:nativeFunctionCode("Mid({this}, {arg0})")
	private function brsMidFrom(startPos:Int):String;

	@:nativeFunctionCode("{this}")
	function toString():String;

	@:nativeFunctionCode("Chr({arg0})")
	@:pure static function fromCharCode(code:Int):String;
}
