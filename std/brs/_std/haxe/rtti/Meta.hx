package haxe.rtti;

 class Meta {
	public static function getFields(t:Dynamic):Dynamic {
		try {
			return t.__static__.__hx_meta__.fields;
		} catch (e:Dynamic) {
			return null;
		}
	}

	public static function getStatics(t:Dynamic):Dynamic {
		try {
			return t.__static__.__hx_meta__.statics;
		} catch (e:Dynamic) {
			return null;
		}
	}

	public static function getType(t:Dynamic):Dynamic {
		try {
			return t.__static__.__hx_name__;
		} catch (e:Dynamic) {
			return null;
		}
	}
}
