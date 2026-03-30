package;

extern class StringBuf {
	@:nativeFunctionCode("{this}.length")
	var length(default, null):Int;

	@:nativeFunctionCode("__StringBuf_new__()")
	function new();

	@:nativeFunctionCode("__StringBuf_add__({this}, {arg0})")
	function add(x:Dynamic):Void;

	@:nativeFunctionCode("__StringBuf_addChar__({this}, {arg0})")
	function addChar(c:Int):Void;

	@:runtime public inline function addSub(s:String, pos:Int, ?len:Int):Void {
		if (len != null)
			brsAddSubLen(s, pos, len);
		else
			brsAddSubAll(s, pos);
	}

	@:nativeFunctionCode("__StringBuf_addSub_len__({this}, {arg0}, {arg1}, {arg2})")
	private function brsAddSubLen(s:String, pos:Int, len:Int):Void;

	@:nativeFunctionCode("__StringBuf_addSub_all__({this}, {arg0}, {arg1})")
	private function brsAddSubAll(s:String, pos:Int):Void;

	@:nativeFunctionCode("{this}.b")
	function toString():String;
}

@:keep @:brs_global function __StringBuf_new__():Dynamic {
	return untyped __brs__('{"b": "", "length": 0}');
}

@:keep @:brs_global function __StringBuf_add__(self:Dynamic, x:Dynamic) {
	var s = Std.string(x);
	untyped __brs__('{0}.b = {0}.b + {1}', self, s);
	untyped __brs__('{0}.length = {0}.length + Len({1})', self, s);
}

@:keep @:brs_global function __StringBuf_addChar__(self:Dynamic, c:Int) {
	untyped __brs__('{0}.b = {0}.b + Chr({1})', self, c);
	untyped __brs__('{0}.length = {0}.length + 1', self);
}

@:keep @:brs_global function __StringBuf_addSub_len__(self:Dynamic, s:String, pos:Int, len:Int) {
	untyped __brs__('{0}.b = {0}.b + Mid({1}, {2} + 1, {3})', self, s, pos, len);
	untyped __brs__('{0}.length = {0}.length + {1}', self, len);
}

@:keep @:brs_global function __StringBuf_addSub_all__(self:Dynamic, s:String, pos:Int) {
	untyped __brs__('{0}.b = {0}.b + Mid({1}, {2} + 1)', self, s, pos);
	untyped __brs__('{0}.length = {0}.length + Len({1}) - {2}', self, s, pos);
}
