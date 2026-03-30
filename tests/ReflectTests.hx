package;

import utest.Assert;
import TestTypes.Colors;

class ReflectTests extends utest.Test {
	function testFieldAccess() {
		var obj:Dynamic = {};
		Reflect.setField(obj, "name", "hello");
		Assert.equals("hello", Reflect.field(obj, "name"));

		Reflect.setField(obj, "count", 42);
		Assert.equals(42, Reflect.field(obj, "count"));

		Reflect.setField(obj, "name", "world");
		Assert.equals("world", Reflect.field(obj, "name"));

		var missing = Reflect.field(obj, "missing");
		Assert.isTrue(missing == null);
	}

	function testHasField() {
		var obj:Dynamic = {};
		Reflect.setField(obj, "x", 1);
		Assert.isTrue(Reflect.hasField(obj, "x"));
		Assert.isFalse(Reflect.hasField(obj, "y"));

		Reflect.setField(obj, "y", "test");
		Assert.isTrue(Reflect.hasField(obj, "y"));
	}

	function testDeleteField() {
		var obj:Dynamic = {};
		Reflect.setField(obj, "a", 1);
		Reflect.setField(obj, "b", 2);

		Assert.isTrue(Reflect.deleteField(obj, "a"));
		Assert.isFalse(Reflect.hasField(obj, "a"));
		Assert.isTrue(Reflect.hasField(obj, "b"));

		Assert.isFalse(Reflect.deleteField(obj, "nonexistent"));
	}

	function testFields() {
		var obj:Dynamic = {};
		Reflect.setField(obj, "x", 1);
		Reflect.setField(obj, "y", 2);
		Reflect.setField(obj, "z", 3);

		var f = Reflect.fields(obj);
		Assert.equals(3, f.length);
		Assert.isTrue(Reflect.hasField(obj, "x"));
		Assert.isTrue(Reflect.hasField(obj, "y"));
		Assert.isTrue(Reflect.hasField(obj, "z"));
	}

	function testCopy() {
		var obj:Dynamic = {};
		Reflect.setField(obj, "a", 10);
		Reflect.setField(obj, "b", "hi");

		var c:Dynamic = Reflect.copy(obj);
		Assert.equals(10, Reflect.field(c, "a"));
		Assert.equals("hi", Reflect.field(c, "b"));

		Reflect.setField(c, "a", 99);
		Assert.equals(10, Reflect.field(obj, "a"));
		Assert.equals(99, Reflect.field(c, "a"));

		var n = Reflect.copy(null);
		Assert.isTrue(n == null);
	}

	function testCompare() {
		Assert.isTrue(Reflect.compare(1, 2) < 0);
		Assert.isTrue(Reflect.compare(5, 3) > 0);
		Assert.equals(0, Reflect.compare(7, 7));

		Assert.isTrue(Reflect.compare("a", "b") < 0);
		Assert.isTrue(Reflect.compare("z", "a") > 0);
		Assert.equals(0, Reflect.compare("hello", "hello"));

		Assert.equals(0, Reflect.compare(null, null));
	}

	function testIsFunction() {
		var fn = function() return 42;
		Assert.isTrue(Reflect.isFunction(fn));
		Assert.isFalse(Reflect.isFunction(42));
		Assert.isFalse(Reflect.isFunction("hello"));
		Assert.isFalse(Reflect.isFunction(null));
	}

	function testIsObject() {
		var obj:Dynamic = {};
		Assert.isTrue(Reflect.isObject(obj));
		Assert.isFalse(Reflect.isObject(42));
		Assert.isFalse(Reflect.isObject("str"));
		Assert.isFalse(Reflect.isObject(null));
	}

	function testIsEnumValue() {
		Assert.isFalse(Reflect.isEnumValue(42));
		Assert.isFalse(Reflect.isEnumValue("str"));
		Assert.isFalse(Reflect.isEnumValue(null));

		var col = Colors.Red;
		Assert.isTrue(Reflect.isEnumValue(col));
	}

	function testPropertyAccess() {
		var obj:Dynamic = {};
		Reflect.setProperty(obj, "prop", "value");
		Assert.equals("value", Reflect.getProperty(obj, "prop"));
	}

	function testCallMethod() {
		var obj:Dynamic = {};
		Reflect.setField(obj, "x", 10);
		var f = Reflect.fields(obj);
		Assert.equals(1, f.length);
	}
}
