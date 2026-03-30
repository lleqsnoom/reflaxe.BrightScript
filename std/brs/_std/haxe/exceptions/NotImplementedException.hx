package haxe.exceptions;

@:coreApi
extern class NotImplementedException extends PosException {
	@:nativeFunctionCode("__NotImplementedException_new__({arg0})")
	public function new(message:String = "Not implemented", ?previous:Exception, ?pos:Null<PosInfos>):Void;
}

@:keep @:brs_global function __NotImplementedException_new__(message:Dynamic):Dynamic {
	untyped __brs__('
	__msg = {0}
	if __msg = invalid then
		__msg = "Not implemented"
	end if', message);
	return untyped __brs__('__PosException_new__(__msg)');
}
