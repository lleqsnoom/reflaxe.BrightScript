package;

class JsonTests {
	var t:Main;

	public function new(main:Main) {
		t = main;
	}

	public function run() {
		t.section("JsonParseArray");
		checkParseArray();
		t.section("JsonStringify");
		checkStringify();
		t.section("JsonStringifyArray");
		checkStringifyArray();
		t.section("JsonRoundtrip");
		checkRoundtrip();
		t.section("JsonRoundtripNested");
		checkRoundtripNested();
		t.section("JsonRoundtripTypes");
		checkRoundtripTypes();
	}

	function checkParseArray() {
		var arr:Dynamic = haxe.Json.parse("[1,2,3]");
		t.intEquals(1, arr[0], "parse array element 0");
		t.intEquals(2, arr[1], "parse array element 1");
		t.intEquals(3, arr[2], "parse array element 2");
	}

	function checkStringify() {
		var obj:Dynamic = {};
		Reflect.setField(obj, "name", "world");
		Reflect.setField(obj, "num", 7);
		var json:String = haxe.Json.stringify(obj);
		var reparsed:Dynamic = haxe.Json.parse(json);
		t.stringEquals("world", reparsed.name, "stringify object string field");
		t.intEquals(7, reparsed.num, "stringify object int field");
	}

	function checkStringifyArray() {
		var arr:Dynamic = haxe.Json.parse("[10,20,30]");
		var json:String = haxe.Json.stringify(arr);
		var reparsed:Dynamic = haxe.Json.parse(json);
		t.intEquals(10, reparsed[0], "stringify array round-trip 0");
		t.intEquals(30, reparsed[2], "stringify array round-trip 2");
	}

	function checkRoundtrip() {
		var obj:Dynamic = {};
		Reflect.setField(obj, "key", "value");
		Reflect.setField(obj, "count", 42);
		var json:String = haxe.Json.stringify(obj);
		var obj2:Dynamic = haxe.Json.parse(json);
		t.stringEquals("value", obj2.key, "roundtrip string field");
		t.intEquals(42, obj2.count, "roundtrip int field");
	}

	function checkRoundtripNested() {
		var inner:Dynamic = {};
		Reflect.setField(inner, "b", "deep");
		var obj:Dynamic = {};
		Reflect.setField(obj, "a", inner);
		Reflect.setField(obj, "arr", haxe.Json.parse("[10,20]"));
		var json:String = haxe.Json.stringify(obj);
		var obj2:Dynamic = haxe.Json.parse(json);
		t.stringEquals("deep", obj2.a.b, "roundtrip nested object");
		t.intEquals(10, obj2.arr[0], "roundtrip nested array 0");
		t.intEquals(20, obj2.arr[1], "roundtrip nested array 1");
	}

	function checkRoundtripTypes() {
		var arr:Dynamic = haxe.Json.parse("[true,false,null,42]");
		t.isTrue(arr[0] == true, "parse bool true");
		t.isTrue(arr[1] == false, "parse bool false");
		t.isTrue(arr[2] == null, "parse null");
		t.intEquals(42, arr[3], "parse int in array");
	}
}
