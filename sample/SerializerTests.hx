package;

class SerializerTests {
	var t:Main;

	public function new(main:Main) {
		t = main;
	}

	public function run() {
		t.section("SerializerNull");
		checkNull();
		t.section("SerializerInt");
		checkInt();
		t.section("SerializerBool");
		checkBool();
		t.section("SerializerFloat");
		checkFloat();
		t.section("SerializerString");
		checkString();
		t.section("SerializerArray");
		checkArray();
		t.section("SerializerObject");
		checkObject();
		t.section("SerializerEnum");
		checkEnum();
		t.section("SerializerRun");
		checkRun();
		t.section("UnserializerNull");
		checkUnserNull();
		t.section("UnserializerInt");
		checkUnserInt();
		t.section("UnserializerBool");
		checkUnserBool();
		t.section("UnserializerFloat");
		checkUnserFloat();
		t.section("UnserializerString");
		checkUnserString();
		t.section("UnserializerArray");
		checkUnserArray();
		t.section("UnserializerObject");
		checkUnserObject();
		t.section("UnserializerEnum");
		checkUnserEnum();
		t.section("SerializerRoundtrip");
		checkRoundtrip();
		t.section("SerializerStringCache");
		checkStringCache();
	}

	// --- Serializer tests ---

	function checkNull() {
		var s = new haxe.Serializer();
		s.serialize(null);
		t.stringEquals("n", s.toString(), "null serializes to n");
	}

	function checkInt() {
		t.stringEquals("z", haxe.Serializer.run(0), "int 0 serializes to z");
		t.stringEquals("i42", haxe.Serializer.run(42), "int 42 serializes to i42");
		t.stringEquals("i-7", haxe.Serializer.run(-7), "int -7 serializes to i-7");
		t.stringEquals("i1000", haxe.Serializer.run(1000), "int 1000");
	}

	function checkBool() {
		t.stringEquals("t", haxe.Serializer.run(true), "true serializes to t");
		t.stringEquals("f", haxe.Serializer.run(false), "false serializes to f");
	}

	function checkFloat() {
		var r:String = haxe.Serializer.run(1.5);
		t.stringEquals("d1.5", r, "float 1.5 serializes to d1.5");
	}

	function checkString() {
		t.stringEquals("y5:hello", haxe.Serializer.run("hello"), "string hello");
		t.stringEquals("y0:", haxe.Serializer.run(""), "empty string");
		t.stringEquals("y5:a%20b", haxe.Serializer.run("a b"), "string with space");
	}

	function checkArray() {
		var r:String = haxe.Serializer.run([1, 2, 3]);
		t.stringEquals("ai1i2i3h", r, "array [1,2,3]");

		var empty:String = haxe.Serializer.run([]);
		t.stringEquals("ah", empty, "empty array");
	}

	function checkObject() {
		var obj:Dynamic = {};
		Reflect.setField(obj, "x", 1);
		Reflect.setField(obj, "y", 2);
		var r:String = haxe.Serializer.run(obj);
		// Object fields: o + field pairs + g
		t.isTrue(StringTools.startsWith(r, "o"), "object starts with o");
		t.isTrue(StringTools.endsWith(r, "g"), "object ends with g");
		// Should contain x=>1 and y=>2
		t.isTrue(StringTools.contains(r, "y1:x"), "contains field x");
		t.isTrue(StringTools.contains(r, "y1:y"), "contains field y");
	}

	function checkEnum() {
		// Create enum-like AA values (matching BRS enum representation)
		var red:Dynamic = {};
		Reflect.setField(red, "_index", 0);
		var r:String = haxe.Serializer.run(red);
		// Enum format: j<enum_name_str>:<index>:<param_count>
		t.isTrue(StringTools.contains(r, ":0:0"), "enum index 0, 0 params");

		var green:Dynamic = {};
		Reflect.setField(green, "_index", 1);
		var g:String = haxe.Serializer.run(green);
		t.isTrue(StringTools.contains(g, ":1:0"), "enum index 1, 0 params");
	}

	function checkRun() {
		var r:String = haxe.Serializer.run(null);
		t.stringEquals("n", r, "run(null) = n");

		var r2:String = haxe.Serializer.run(true);
		t.stringEquals("t", r2, "run(true) = t");
	}

	// --- Unserializer tests ---

	function checkUnserNull() {
		var v:Dynamic = haxe.Unserializer.run("n");
		t.isTrue(v == null, "unserialize null");
	}

	function checkUnserInt() {
		var v:Dynamic = haxe.Unserializer.run("z");
		t.intEquals(0, v, "unserialize zero");

		var v2:Dynamic = haxe.Unserializer.run("i42");
		t.intEquals(42, v2, "unserialize 42");

		var v3:Dynamic = haxe.Unserializer.run("i-7");
		t.intEquals(-7, v3, "unserialize -7");

		var v4:Dynamic = haxe.Unserializer.run("i1000");
		t.intEquals(1000, v4, "unserialize 1000");
	}

	function checkUnserBool() {
		var v:Dynamic = haxe.Unserializer.run("t");
		t.isTrue(v == true, "unserialize true");

		var v2:Dynamic = haxe.Unserializer.run("f");
		t.isTrue(v2 == false, "unserialize false");
	}

	function checkUnserFloat() {
		var v:Dynamic = haxe.Unserializer.run("d1.5");
		t.floatNear(1.5, v, "unserialize 1.5");

		var v2:Dynamic = haxe.Unserializer.run("d-3.14");
		t.floatNear(-3.14, v2, "unserialize -3.14");
	}

	function checkUnserString() {
		var v:Dynamic = haxe.Unserializer.run("y5:hello");
		t.stringEquals("hello", v, "unserialize hello");

		var v2:Dynamic = haxe.Unserializer.run("y0:");
		t.stringEquals("", v2, "unserialize empty string");

		var v3:Dynamic = haxe.Unserializer.run("y5:a%20b");
		t.stringEquals("a b", v3, "unserialize string with space");
	}

	function checkUnserArray() {
		var v:Dynamic = haxe.Unserializer.run("ai1i2i3h");
		t.intEquals(1, v[0], "array[0] = 1");
		t.intEquals(2, v[1], "array[1] = 2");
		t.intEquals(3, v[2], "array[2] = 3");

		var empty:Dynamic = haxe.Unserializer.run("ah");
		t.isTrue(empty[0] == null, "empty array has no element 0");

		// Array with null runs (u format)
		var v2:Dynamic = haxe.Unserializer.run("au3i7h");
		t.isTrue(v2[0] == null, "array null[0]");
		t.isTrue(v2[1] == null, "array null[1]");
		t.isTrue(v2[2] == null, "array null[2]");
		t.intEquals(7, v2[3], "array[3] = 7");
	}

	function checkUnserObject() {
		var v:Dynamic = haxe.Unserializer.run("oy1:xi1y1:yi2g");
		t.intEquals(1, v.x, "object x = 1");
		t.intEquals(2, v.y, "object y = 2");
	}

	function checkUnserEnum() {
		// j format: enum by index
		// j + enum_name_str + : + index + : + param_count
		var v:Dynamic = haxe.Unserializer.run("jy0::1:0");
		t.intEquals(1, v._index, "enum by index = 1");

		// j format with params
		var v2:Dynamic = haxe.Unserializer.run("jy0::0:2i42y5:hello");
		t.intEquals(0, v2._index, "enum with params index = 0");
		t.intEquals(42, v2.params[0], "enum param[0] = 42");
		t.stringEquals("hello", v2.params[1], "enum param[1] = hello");
	}

	// --- Round-trip tests ---

	function checkRoundtrip() {
		// Int round-trip
		var r1:Dynamic = haxe.Unserializer.run(haxe.Serializer.run(42));
		t.intEquals(42, r1, "roundtrip int 42");

		// String round-trip
		var r2:Dynamic = haxe.Unserializer.run(haxe.Serializer.run("hello world"));
		t.stringEquals("hello world", r2, "roundtrip string");

		// Bool round-trip
		var r3:Dynamic = haxe.Unserializer.run(haxe.Serializer.run(true));
		t.isTrue(r3 == true, "roundtrip true");

		var r4:Dynamic = haxe.Unserializer.run(haxe.Serializer.run(false));
		t.isTrue(r4 == false, "roundtrip false");

		// Null round-trip
		var r5:Dynamic = haxe.Unserializer.run(haxe.Serializer.run(null));
		t.isTrue(r5 == null, "roundtrip null");

		// Array round-trip
		var arr:Dynamic = haxe.Unserializer.run(haxe.Serializer.run([10, 20, 30]));
		t.intEquals(10, arr[0], "roundtrip array[0]");
		t.intEquals(20, arr[1], "roundtrip array[1]");
		t.intEquals(30, arr[2], "roundtrip array[2]");

		// Object round-trip
		var obj:Dynamic = {};
		Reflect.setField(obj, "name", "test");
		Reflect.setField(obj, "value", 99);
		var rObj:Dynamic = haxe.Unserializer.run(haxe.Serializer.run(obj));
		t.stringEquals("test", rObj.name, "roundtrip object name");
		t.intEquals(99, rObj.value, "roundtrip object value");

		// Float round-trip
		var r6:Dynamic = haxe.Unserializer.run(haxe.Serializer.run(3.14));
		t.floatNear(3.14, r6, "roundtrip float 3.14");

		// Zero round-trip
		var r7:Dynamic = haxe.Unserializer.run(haxe.Serializer.run(0));
		t.intEquals(0, r7, "roundtrip zero");
	}

	function checkStringCache() {
		// Serialize same string twice — second should use cache reference R
		var s = new haxe.Serializer();
		s.serialize("hello");
		s.serialize("hello");
		var r:String = s.toString();
		// First: y5:hello, Second: R0
		t.stringEquals("y5:helloR0", r, "string cache produces R0");

		// Unserialize with cache reference
		var u = new haxe.Unserializer("y5:helloR0");
		var v1:Dynamic = u.unserialize();
		var v2:Dynamic = u.unserialize();
		t.stringEquals("hello", v1, "cache first value");
		t.stringEquals("hello", v2, "cache reference value");

		// Multiple different strings
		var s2 = new haxe.Serializer();
		s2.serialize("aaa");
		s2.serialize("bbb");
		s2.serialize("aaa");
		var r2:String = s2.toString();
		t.isTrue(StringTools.contains(r2, "R0"), "cache ref for repeated string");
	}
}
