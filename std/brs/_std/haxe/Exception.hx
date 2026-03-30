package haxe;

@:coreApi
extern class Exception {
	public var message(get, never):String;
	public var stack(get, never):CallStack;
	public var previous(get, never):Null<Exception>;
	public var native(get, never):Any;

	@:nativeFunctionCode("{this}.message")
	private function get_message():String;

	@:nativeFunctionCode("[]")
	private function get_stack():CallStack;

	@:nativeFunctionCode("{this}.previous")
	private function get_previous():Null<Exception>;

	@:nativeFunctionCode("{this}._native")
	final private function get_native():Any;

	@:nativeFunctionCode("__Exception_caught__({arg0})")
	static private function caught(value:Any):Exception;

	@:nativeFunctionCode("__Exception_thrown__({arg0})")
	static private function thrown(value:Any):Any;

	@:nativeFunctionCode("__Exception_new__({arg0})")
	public function new(message:String, ?previous:Exception, ?native:Any):Void;

	@:nativeFunctionCode("{this}._native")
	private function unwrap():Any;

	@:nativeFunctionCode("{this}.message")
	public function toString():String;

	@:nativeFunctionCode("__Exception_details__({this})")
	public function details():String;
}

@:keep @:brs_global function __Exception_new__(message:Dynamic):Dynamic {
	return message;
}

@:keep @:brs_global function __Exception_caught__(value:Dynamic):Dynamic {
	var t:String = brs.Native.typeOf(value);
	var isAA:Bool = brs.Native.eq(t, "roAssociativeArray");
	if (isAA == true) {
		var hasMsg:Bool = brs.Native.doesExist(value, "message");
		if (hasMsg == true)
			return value;
	}
	untyped __brs__('
	__ex = {"message": __DynToStr__({0}), "previous": invalid, "_native": invalid, "__exception__": true}
	__ex._native = __ex', value);
	return untyped __brs__('__ex');
}

@:keep @:brs_global function __Exception_thrown__(value:Dynamic):Dynamic {
	var t:String = brs.Native.typeOf(value);
	var isStr:Bool = brs.Native.eq(t, "roString");
	if (isStr == true)
		return value;
	return untyped __brs__('__DynToStr__({0})', value);
}

@:keep @:brs_global function __Exception_details__(self:Dynamic):Dynamic {
	return brs.Native.fieldGet(self, "message");
}
