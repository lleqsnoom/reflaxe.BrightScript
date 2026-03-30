package haxe;

extern class Json {
	@:nativeFunctionCode("ParseJson({arg0})")
	public static function parse(text:String):Dynamic;

	@:nativeFunctionCode("FormatJson({arg0})")
	public static function stringify(value:Dynamic, ?replacer:Dynamic, ?space:String):String;
}
