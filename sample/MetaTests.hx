package;

class MetaTests {
	var t:Main;

	public function new(main:Main) {
		t = main;
	}

	public function run() {
		t.section("MetaGetType");
		checkGetType();
		t.section("MetaGetFields");
		checkGetFields();
		t.section("MetaGetStatics");
		checkGetStatics();
	}

	function checkGetType() {
		var obj:Dynamic = {name: "test"};
		var meta = haxe.rtti.Meta.getType(obj);
		t.isTrue(meta == null, "getType() returns null");
	}

	function checkGetFields() {
		var obj:Dynamic = {name: "test"};
		var fields = haxe.rtti.Meta.getFields(obj);
		t.isTrue(fields == null, "getFields() returns null");
	}

	function checkGetStatics() {
		var obj:Dynamic = {name: "test"};
		var statics = haxe.rtti.Meta.getStatics(obj);
		t.isTrue(statics == null, "getStatics() returns null");
	}
}
