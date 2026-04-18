package haxe.rtti;

 class Meta {
	public static function getFields(t:Dynamic):Dynamic {
		if (t == null)
			return null;

		final tc = t.__static__ ?? t;
		try {
			return tc.__hx_meta__.fields;
		} catch (e:Dynamic) {
			return null;
		}
	}

	public static function getStatics(t:Dynamic):Dynamic {
		if (t == null)
			return null;
		
		final tc = t.__static__ ?? t;
		try {
			return tc.__hx_meta__.statics;
		} catch (e:Dynamic) {
			return null;
		}
	}

	public static function getType(t:Dynamic):Dynamic {
		if (t == null)
			return null;

		final tc = t.__static__ ?? t;
		try {
			return tc.__hx_name__;
		} catch (e:Dynamic) {
			return null;
		}
	}
}
