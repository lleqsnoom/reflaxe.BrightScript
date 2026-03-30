package haxe.exceptions;

@:coreApi
extern class ArgumentException extends PosException {
	@:nativeFunctionCode("{this}.argument")
	public final var argument:String;

	@:nativeFunctionCode("__ArgumentException_new__({arg0})")
	public function new(argument:String, ?message:String, ?previous:Exception, ?pos:Null<PosInfos>):Void;
}

@:keep @:brs_global function __ArgumentException_new__(argument:Dynamic):Dynamic {
	return untyped __brs__('"Invalid argument " + Chr(34) + {0} + Chr(34)', argument);
}
