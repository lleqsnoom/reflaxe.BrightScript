package haxe.rtti;

/**
	Accesses compile-time metadata at runtime via __hx_meta__ tables.
**/
extern class Meta {
	@:nativeFunctionCode("({arg0}).__hx_meta__[\"fields\"]")
	public static function getFields(t:Dynamic):Dynamic;

	@:nativeFunctionCode("({arg0}).__hx_meta__[\"statics\"]")
	public static function getStatics(t:Dynamic):Dynamic;

	@:nativeFunctionCode("invalid")
	public static function getType(t:Dynamic):Dynamic;
}
