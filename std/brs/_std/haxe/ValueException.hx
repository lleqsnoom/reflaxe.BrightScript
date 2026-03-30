package haxe;

@:coreApi
extern class ValueException extends Exception {
	@:nativeFunctionCode("{this}.value")
	public var value(default, null):Any;

	@:nativeFunctionCode("__ValueException_new__({arg0})")
	public function new(value:Any, ?previous:Exception, ?native:Any):Void;

	@:nativeFunctionCode("{this}.value")
	override private function unwrap():Any;
}

@:keep @:brs_global function __ValueException_new__(value:Dynamic):Dynamic {
	return untyped __brs__('__DynToStr__({0})', value);
}
