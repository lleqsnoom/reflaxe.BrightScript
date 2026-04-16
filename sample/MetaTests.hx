package;

class MetaTests {
	var t:Main;

	public function new(main:Main) {
		t = main;
	}

	public function run() {
		t.section("MetaGetTypeNull");
		checkGetTypeNull();
		t.section("MetaGetFieldsNull");
		checkGetFieldsNull();
		t.section("MetaGetStaticsNull");
		checkGetStaticsNull();
		t.section("MetaGetTypeValid");
		checkGetType();
		t.section("MetaGetFieldsValid");
		checkGetFields();
		t.section("MetaGetStaticsValid");
		checkGetStatics();
	}
	
	function checkGetType() {
		var obj = new MetaTypeTestClass();
		var meta = haxe.rtti.Meta.getType(obj);
		t.isTrue(meta == "MetaTypeTestClass", "getType() returns class name");
	}

	function checkGetFields() {
		var obj = new MetaTypeTestClass();
		var fields = haxe.rtti.Meta.getFields(obj);
		t.isTrue(fields != null, "getFields() returns non-null");
		t.isTrue(fields.field1 != null, "getFields() contains field1");
		t.isTrue(fields.field2 != null, "getFields() contains field2");
	}

	function checkGetStatics() {
		var obj = new MetaTypeTestClass();
		var statics = haxe.rtti.Meta.getStatics(obj);
		t.isTrue(statics != null, "getStatics() returns non-null");
		t.isTrue(statics.static1 != null, "getStatics() contains static1");
		t.isTrue(statics.static2 != null, "getStatics() contains static2");
	}

	function checkGetTypeNull() {
		var obj:Dynamic = {name: "test"};
		var meta = haxe.rtti.Meta.getType(obj);
		t.isTrue(meta == null, "getType() returns null");
	}

	function checkGetFieldsNull() {
		var obj:Dynamic = {name: "test"};
		var fields = haxe.rtti.Meta.getFields(obj);
		t.isTrue(fields == null, "getFields() returns null");
	}

	function checkGetStaticsNull() {
		var obj:Dynamic = {name: "test"};
		var statics = haxe.rtti.Meta.getStatics(obj);
		t.isTrue(statics == null, "getStatics() returns null");
	}
}


class MetaTypeTestClass {
	public var field1:Int;
	public var field2:String;

	public static var static1:Bool;
	public static var static2:Float;

	public function new() {
		field1 = 42;
		field2 = "hello";
	}
}