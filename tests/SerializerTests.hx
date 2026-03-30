package;

import utest.Assert;

class SerializerTests extends utest.Test {
	function testNull() {
		var s = new haxe.Serializer();
		s.serialize(null);
		Assert.equals("n", s.toString());
	}

	function testInt() {
		Assert.equals("z", haxe.Serializer.run(0));
		Assert.equals("i42", haxe.Serializer.run(42));
		Assert.equals("i-7", haxe.Serializer.run(-7));
		Assert.equals("i1000", haxe.Serializer.run(1000));
	}

	function testBool() {
		Assert.equals("t", haxe.Serializer.run(true));
		Assert.equals("f", haxe.Serializer.run(false));
	}

	function testFloat() {
		Assert.equals("d1.5", haxe.Serializer.run(1.5));
	}

	function testString() {
		Assert.equals("y5:hello", haxe.Serializer.run("hello"));
		Assert.equals("y0:", haxe.Serializer.run(""));
		Assert.equals("y5:a%20b", haxe.Serializer.run("a b"));
	}

	function testArray() {
		Assert.equals("ai1i2i3h", haxe.Serializer.run([1, 2, 3]));
		Assert.equals("ah", haxe.Serializer.run([]));
	}

	function testObject() {
		var obj:Dynamic = {};
		Reflect.setField(obj, "x", 1);
		Reflect.setField(obj, "y", 2);
		var r:String = haxe.Serializer.run(obj);
		Assert.isTrue(StringTools.startsWith(r, "o"));
		Assert.isTrue(StringTools.endsWith(r, "g"));
		Assert.isTrue(StringTools.contains(r, "y1:x"));
		Assert.isTrue(StringTools.contains(r, "y1:y"));
	}

	function testEnum() {
		var red:Dynamic = {};
		Reflect.setField(red, "_index", 0);
		var r:String = haxe.Serializer.run(red);
		Assert.isTrue(StringTools.contains(r, ":0:0"));

		var green:Dynamic = {};
		Reflect.setField(green, "_index", 1);
		var g:String = haxe.Serializer.run(green);
		Assert.isTrue(StringTools.contains(g, ":1:0"));
	}

	function testRun() {
		Assert.equals("n", haxe.Serializer.run(null));
		Assert.equals("t", haxe.Serializer.run(true));
	}

	function testUnserNull() {
		var v:Dynamic = haxe.Unserializer.run("n");
		Assert.isTrue(v == null);
	}

	function testUnserInt() {
		Assert.equals(0, haxe.Unserializer.run("z"));
		Assert.equals(42, haxe.Unserializer.run("i42"));
		Assert.equals(-7, haxe.Unserializer.run("i-7"));
		Assert.equals(1000, haxe.Unserializer.run("i1000"));
	}

	function testUnserBool() {
		Assert.isTrue(haxe.Unserializer.run("t") == true);
		Assert.isTrue(haxe.Unserializer.run("f") == false);
	}

	function testUnserFloat() {
		Assert.floatEquals(1.5, haxe.Unserializer.run("d1.5"));
		Assert.floatEquals(-3.14, haxe.Unserializer.run("d-3.14"));
	}

	function testUnserString() {
		Assert.equals("hello", haxe.Unserializer.run("y5:hello"));
		Assert.equals("", haxe.Unserializer.run("y0:"));
		Assert.equals("a b", haxe.Unserializer.run("y5:a%20b"));
	}

	function testUnserArray() {
		var v:Dynamic = haxe.Unserializer.run("ai1i2i3h");
		Assert.equals(1, v[0]);
		Assert.equals(2, v[1]);
		Assert.equals(3, v[2]);

		var empty:Dynamic = haxe.Unserializer.run("ah");
		Assert.isTrue(empty[0] == null);

		var v2:Dynamic = haxe.Unserializer.run("au3i7h");
		Assert.isTrue(v2[0] == null);
		Assert.isTrue(v2[1] == null);
		Assert.isTrue(v2[2] == null);
		Assert.equals(7, v2[3]);
	}

	function testUnserObject() {
		var v:Dynamic = haxe.Unserializer.run("oy1:xi1y1:yi2g");
		Assert.equals(1, v.x);
		Assert.equals(2, v.y);
	}

	function testUnserEnum() {
		var v:Dynamic = haxe.Unserializer.run("jy0::1:0");
		Assert.equals(1, v._index);

		var v2:Dynamic = haxe.Unserializer.run("jy0::0:2i42y5:hello");
		Assert.equals(0, v2._index);
		Assert.equals(42, v2.params[0]);
		Assert.equals("hello", v2.params[1]);
	}

	function testRoundtrip() {
		var r1:Dynamic = haxe.Unserializer.run(haxe.Serializer.run(42));
		Assert.equals(42, r1);

		var r2:Dynamic = haxe.Unserializer.run(haxe.Serializer.run("hello world"));
		Assert.equals("hello world", r2);

		Assert.isTrue(haxe.Unserializer.run(haxe.Serializer.run(true)) == true);
		Assert.isTrue(haxe.Unserializer.run(haxe.Serializer.run(false)) == false);
		Assert.isTrue(haxe.Unserializer.run(haxe.Serializer.run(null)) == null);

		var arr:Dynamic = haxe.Unserializer.run(haxe.Serializer.run([10, 20, 30]));
		Assert.equals(10, arr[0]);
		Assert.equals(20, arr[1]);
		Assert.equals(30, arr[2]);

		var obj:Dynamic = {};
		Reflect.setField(obj, "name", "test");
		Reflect.setField(obj, "value", 99);
		var rObj:Dynamic = haxe.Unserializer.run(haxe.Serializer.run(obj));
		Assert.equals("test", rObj.name);
		Assert.equals(99, rObj.value);

		Assert.floatEquals(3.14, haxe.Unserializer.run(haxe.Serializer.run(3.14)));

		var r7:Dynamic = haxe.Unserializer.run(haxe.Serializer.run(0));
		Assert.equals(0, r7);
	}

	function testStringCache() {
		var s = new haxe.Serializer();
		s.serialize("hello");
		s.serialize("hello");
		Assert.equals("y5:helloR0", s.toString());

		var u = new haxe.Unserializer("y5:helloR0");
		Assert.equals("hello", u.unserialize());
		Assert.equals("hello", u.unserialize());

		var s2 = new haxe.Serializer();
		s2.serialize("aaa");
		s2.serialize("bbb");
		s2.serialize("aaa");
		Assert.isTrue(StringTools.contains(s2.toString(), "R0"));
	}
}
