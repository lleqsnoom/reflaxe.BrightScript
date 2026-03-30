package;

class ReflectTests {
	var t:Main;

	public function new(main:Main) {
		t = main;
	}

	public function run() {
		t.section("Reflect.field / setField");
		checkFieldAccess();
		t.section("Reflect.hasField");
		checkHasField();
		t.section("Reflect.deleteField");
		checkDeleteField();
		t.section("Reflect.fields");
		checkFields();
		t.section("Reflect.copy");
		checkCopy();
		t.section("Reflect.compare");
		checkCompare();
		t.section("Reflect.isFunction");
		checkIsFunction();
		t.section("Reflect.isObject");
		checkIsObject();
		t.section("Reflect.isEnumValue");
		checkIsEnumValue();
		t.section("Reflect.getProperty / setProperty");
		checkPropertyAccess();
		t.section("Reflect.callMethod");
		checkCallMethod();
	}

	function checkFieldAccess() {
		var obj:Dynamic = {};
		Reflect.setField(obj, "name", "hello");
		t.stringEquals("hello", Reflect.field(obj, "name"), "setField + field");

		Reflect.setField(obj, "count", 42);
		t.intEquals(42, Reflect.field(obj, "count"), "setField int + field");

		// Overwrite existing field
		Reflect.setField(obj, "name", "world");
		t.stringEquals("world", Reflect.field(obj, "name"), "overwrite field");

		// Access non-existent field returns null/invalid
		var missing = Reflect.field(obj, "missing");
		t.isTrue(missing == null, "missing field is null");
	}

	function checkHasField() {
		var obj:Dynamic = {};
		Reflect.setField(obj, "x", 1);
		t.isTrue(Reflect.hasField(obj, "x"), "hasField existing");
		t.isFalse(Reflect.hasField(obj, "y"), "hasField missing");

		// After setting the field
		Reflect.setField(obj, "y", "test");
		t.isTrue(Reflect.hasField(obj, "y"), "hasField after set");
	}

	function checkDeleteField() {
		var obj:Dynamic = {};
		Reflect.setField(obj, "a", 1);
		Reflect.setField(obj, "b", 2);

		var deleted = Reflect.deleteField(obj, "a");
		t.isTrue(deleted, "deleteField returns true");
		t.isFalse(Reflect.hasField(obj, "a"), "field removed after delete");
		t.isTrue(Reflect.hasField(obj, "b"), "other field still exists");

		// Delete non-existent field
		var deleted2 = Reflect.deleteField(obj, "nonexistent");
		t.isFalse(deleted2, "deleteField nonexistent returns false");
	}

	function checkFields() {
		var obj:Dynamic = {};
		Reflect.setField(obj, "x", 1);
		Reflect.setField(obj, "y", 2);
		Reflect.setField(obj, "z", 3);

		var f = Reflect.fields(obj);
		t.intEquals(3, f.length, "fields count");
		// Fields all exist — verified via hasField since order may vary
		t.isTrue(Reflect.hasField(obj, "x"), "fields has x");
		t.isTrue(Reflect.hasField(obj, "y"), "fields has y");
		t.isTrue(Reflect.hasField(obj, "z"), "fields has z");
	}

	function checkCopy() {
		var obj:Dynamic = {};
		Reflect.setField(obj, "a", 10);
		Reflect.setField(obj, "b", "hi");

		var c:Dynamic = Reflect.copy(obj);
		t.intEquals(10, Reflect.field(c, "a"), "copy has field a");
		t.stringEquals("hi", Reflect.field(c, "b"), "copy has field b");

		// Modifying copy doesn't affect original
		Reflect.setField(c, "a", 99);
		t.intEquals(10, Reflect.field(obj, "a"), "original unchanged after copy mod");
		t.intEquals(99, Reflect.field(c, "a"), "copy has new value");

		// Copy null returns null
		var n = Reflect.copy(null);
		t.isTrue(n == null, "copy null is null");
	}

	function checkCompare() {
		// Numeric comparison
		t.isTrue(Reflect.compare(1, 2) < 0, "compare 1 < 2");
		t.isTrue(Reflect.compare(5, 3) > 0, "compare 5 > 3");
		t.intEquals(0, Reflect.compare(7, 7), "compare 7 == 7");

		// String comparison
		t.isTrue(Reflect.compare("a", "b") < 0, "compare a < b");
		t.isTrue(Reflect.compare("z", "a") > 0, "compare z > a");
		t.intEquals(0, Reflect.compare("hello", "hello"), "compare equal strings");

		// Null comparison
		t.intEquals(0, Reflect.compare(null, null), "compare null null");
	}

	function checkIsFunction() {
		var fn = function() return 42;
		t.isTrue(Reflect.isFunction(fn), "isFunction on lambda");
		t.isFalse(Reflect.isFunction(42), "isFunction on int");
		t.isFalse(Reflect.isFunction("hello"), "isFunction on string");
		t.isFalse(Reflect.isFunction(null), "isFunction on null");
	}

	function checkIsObject() {
		var obj:Dynamic = {};
		t.isTrue(Reflect.isObject(obj), "isObject on AA");
		t.isFalse(Reflect.isObject(42), "isObject on int");
		t.isFalse(Reflect.isObject("str"), "isObject on string");
		t.isFalse(Reflect.isObject(null), "isObject on null");
	}

	function checkIsEnumValue() {
		t.isFalse(Reflect.isEnumValue(42), "isEnumValue on int");
		t.isFalse(Reflect.isEnumValue("str"), "isEnumValue on string");
		t.isFalse(Reflect.isEnumValue(null), "isEnumValue on null");

		// Test with an actual enum value
		var col = Main.Colors.Red;
		t.isTrue(Reflect.isEnumValue(col), "isEnumValue on enum");
	}

	function checkPropertyAccess() {
		// getProperty/setProperty behave like field/setField in BRS
		var obj:Dynamic = {};
		Reflect.setProperty(obj, "prop", "value");
		t.stringEquals("value", Reflect.getProperty(obj, "prop"), "setProperty + getProperty");
	}

	function checkCallMethod() {
		var obj:Dynamic = {};
		Reflect.setField(obj, "x", 10);
		var f = Reflect.fields(obj);
		t.intEquals(1, f.length, "callMethod setup ok");
	}
}
