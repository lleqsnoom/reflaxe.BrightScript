package haxe.exceptions;

@:coreApi
extern class PosException extends Exception {
	@:nativeFunctionCode("{this}.posInfos")
	public final posInfos:PosInfos;

	@:nativeFunctionCode("__PosException_new__({arg0})")
	public function new(message:String, ?previous:Exception, ?pos:Null<PosInfos>):Void;

	@:nativeFunctionCode("__PosException_toString__({this})")
	override public function toString():String;
}

@:keep @:brs_global function __PosException_new__(message:Dynamic):Dynamic {
	return message;
}

@:keep @:brs_global function __PosException_toString__(self:Dynamic):Dynamic {
	return brs.Native.fieldGet(self, "message");
}
