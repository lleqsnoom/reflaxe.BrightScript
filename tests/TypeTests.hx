package;

import utest.Assert;
import TestTypes.Colors;
import TestTypes.MapKey;

class TypeTests extends utest.Test {
	function testTypeof() {
		Assert.equals(0, Type.enumIndex(Type.typeof(null)));
		Assert.equals(1, Type.enumIndex(Type.typeof(42)));
		Assert.equals(2, Type.enumIndex(Type.typeof(3.14)));
		Assert.equals(3, Type.enumIndex(Type.typeof(true)));

		var fn = function() return 1;
		Assert.equals(5, Type.enumIndex(Type.typeof(fn)));

		Assert.equals(6, Type.enumIndex(Type.typeof("hello")));
		Assert.equals(6, Type.enumIndex(Type.typeof([1, 2, 3])));

		var red:Dynamic = Colors.Red;
		Assert.equals(7, Type.enumIndex(Type.typeof(red)));

		var obj:Dynamic = {};
		Assert.equals(4, Type.enumIndex(Type.typeof(obj)));

		var inst = new MapKey(5);
		var instDyn:Dynamic = inst;
		Assert.equals(6, Type.enumIndex(Type.typeof(instDyn)));

		Assert.equals(3, Type.enumIndex(Type.typeof(false)));
	}

	function testEnumIndex() {
		Assert.equals(0, Type.enumIndex(Colors.Red));
		Assert.equals(1, Type.enumIndex(Colors.Green));
		Assert.equals(2, Type.enumIndex(Colors.Blue));
	}

	function testEnumEq() {
		Assert.isTrue(Type.enumEq(Colors.Red, Colors.Red));
		Assert.isTrue(Type.enumEq(Colors.Blue, Colors.Blue));

		Assert.isFalse(Type.enumEq(Colors.Red, Colors.Blue));
		Assert.isFalse(Type.enumEq(Colors.Green, Colors.Red));

		Assert.isTrue(Type.enumEq(null, null));
		Assert.isFalse(Type.enumEq(Colors.Red, null));
		Assert.isFalse(Type.enumEq(null, Colors.Blue));
	}

	function testEnumParameters() {
		var params = Type.enumParameters(Colors.Red);
		Assert.equals(0, params.length);

		var params2 = Type.enumParameters(Colors.Blue);
		Assert.equals(0, params2.length);
	}

	function testGetClass() {
		var inst = new MapKey(10);
		var cls = Type.getClass(inst);
		Assert.isTrue(cls != null);

		Assert.isTrue(Type.getClass(42) == null);
		Assert.isTrue(Type.getClass("hello") == null);
	}

	function testGetClassFields() {
		var inst = new LanguageTests();
		var cls = Type.getClass(inst);
		Assert.isTrue(cls != null);

		if (cls != null) {
			var fields = Type.getClassFields(cls);
			Assert.isTrue(fields.length > 0);
		}
	}

	function testCreateInstance() {
		var inst = new MapKey(1);
		var cls = Type.getClass(inst);
		Assert.isTrue(cls != null);

		if (cls != null) {
			var newInst:Dynamic = Type.createInstance(cls, [99]);
			Assert.isTrue(newInst != null);
			if (newInst != null) {
				Assert.equals(99, Reflect.field(newInst, "id"));
			}
		}
	}

	function testCreateEnumIndex() {
		var e:Dynamic = Type.createEnumIndex(null, 0);
		Assert.equals(0, Type.enumIndex(e));

		var e2:Dynamic = Type.createEnumIndex(null, 2);
		Assert.equals(2, Type.enumIndex(e2));

		Assert.isTrue(Type.enumEq(e, Colors.Red));
		Assert.isTrue(Type.enumEq(e2, Colors.Blue));
		Assert.isFalse(Type.enumEq(e, Colors.Blue));
	}

	function testStubs() {
		Assert.isTrue(Type.getSuperClass(null) == null);
		Assert.isTrue(Type.resolveClass("Main") == null);
		Assert.isTrue(Type.resolveEnum("Colors") == null);
		Assert.equals(0, Type.allEnums(null).length);
		Assert.equals(0, Type.getEnumConstructs(null).length);
		Assert.isTrue(Type.getEnum(Colors.Red) == null);
		Assert.isTrue(Type.getEnumName(null) == null);
	}
}
