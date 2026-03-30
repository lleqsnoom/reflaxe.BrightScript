package;

import utest.Assert;
import TestTypes.Colors;
import TestTypes.MapKey;

class MapTests extends utest.Test {
	function testStringMapBasic() {
		var sm = new Map<String, Int>();
		sm.set("one", 1);
		sm.set("two", 2);
		sm.set("three", 3);
		Assert.isTrue(sm.get("one") == 1);
		Assert.isTrue(sm.get("two") == 2);
		Assert.isTrue(sm.exists("one"));
		Assert.isFalse(sm.exists("four"));
		Assert.isTrue(sm.remove("one"));
		Assert.isFalse(sm.remove("four"));
		Assert.isFalse(sm.exists("one"));
	}

	function testStringMapIteration() {
		var sm = new Map<String, Int>();
		sm.set("a", 1);
		sm.set("b", 2);
		sm.set("c", 3);
		var keyCount = 0;
		for (key in sm.keys()) {
			keyCount++;
		}
		Assert.equals(3, keyCount);
		var valCount = 0;
		for (val in sm.iterator()) {
			valCount++;
		}
		Assert.equals(3, valCount);
	}

	function testStringMapOverwrite() {
		var sm = new Map<String, Int>();
		sm.set("key", 1);
		Assert.isTrue(sm.get("key") == 1);
		sm.set("key", 2);
		Assert.isTrue(sm.get("key") == 2);
	}

	function testStringMapCopyClear() {
		var sm = new Map<String, Int>();
		sm.set("a", 1);
		sm.set("b", 2);
		var cp = sm.copy();
		cp.set("c", 3);
		Assert.isFalse(sm.exists("c"));
		Assert.isTrue(cp.exists("a"));
		Assert.isTrue(cp.exists("c"));
		sm.clear();
		Assert.isFalse(sm.exists("a"));
		Assert.isTrue(cp.exists("a"));
	}

	function testStringMapToString() {
		var sm = new Map<String, Int>();
		sm.set("a", 1);
		var s = sm.toString();
		Assert.isTrue(StringTools.contains(s, "a"));
		Assert.isTrue(StringTools.contains(s, "=>"));
	}

	function testIntMapBasic() {
		var im = new Map<Int, String>();
		im.set(1, "one");
		im.set(2, "two");
		im.set(3, "three");
		Assert.equals("one", im.get(1));
		Assert.equals("two", im.get(2));
		Assert.isTrue(im.exists(1));
		Assert.isFalse(im.exists(4));
		Assert.isTrue(im.remove(1));
		Assert.isFalse(im.remove(4));
		Assert.isFalse(im.exists(1));
	}

	function testIntMapIteration() {
		var im = new Map<Int, String>();
		im.set(10, "ten");
		im.set(20, "twenty");
		im.set(30, "thirty");
		var keySum = 0;
		for (key in im.keys()) {
			keySum += key;
		}
		Assert.equals(60, keySum);
		var valCount = 0;
		for (val in im.iterator()) {
			valCount++;
		}
		Assert.equals(3, valCount);
	}

	function testMapArrayAccess() {
		var mp = new Map<String, Int>();
		mp.set("x", 10);
		mp.set("y", 20);
		Assert.isTrue(mp["x"] == 10);
		Assert.isTrue(mp["y"] == 20);
		mp.set("x", 30);
		Assert.isTrue(mp["x"] == 30);
	}

	function testMapForIn() {
		var sm = new Map<String, Int>();
		sm.set("a", 10);
		sm.set("b", 20);
		sm.set("c", 30);
		var keyCount = 0;
		for (key in sm.keys()) {
			keyCount++;
		}
		Assert.equals(3, keyCount);
		var valCount = 0;
		for (val in sm.iterator()) {
			valCount++;
		}
		Assert.equals(3, valCount);
	}

	function testObjectMapBasic() {
		var om = new haxe.ds.ObjectMap<MapKey, String>();
		var k1 = new MapKey(1);
		var k2 = new MapKey(2);
		var k3 = new MapKey(3);
		om.set(k1, "one");
		om.set(k2, "two");
		om.set(k3, "three");
		Assert.equals("one", om.get(k1));
		Assert.equals("two", om.get(k2));
		Assert.isTrue(om.exists(k1));
		var k4 = new MapKey(4);
		Assert.isFalse(om.exists(k4));
		om.set(k1, "ONE");
		Assert.equals("ONE", om.get(k1));
		Assert.isTrue(om.remove(k2));
		Assert.isFalse(om.remove(k4));
		Assert.isFalse(om.exists(k2));
	}

	function testObjectMapIteration() {
		var om = new haxe.ds.ObjectMap<MapKey, Int>();
		var k1 = new MapKey(10);
		var k2 = new MapKey(20);
		var k3 = new MapKey(30);
		om.set(k1, 100);
		om.set(k2, 200);
		om.set(k3, 300);
		var keyCount = 0;
		for (key in om.keys()) {
			keyCount++;
		}
		Assert.equals(3, keyCount);
		var valCount = 0;
		for (val in om.iterator()) {
			valCount++;
		}
		Assert.equals(3, valCount);
		om.clear();
		Assert.isFalse(om.exists(k1));
	}

	function testEnumValueMapBasic() {
		var em = new haxe.ds.EnumValueMap<Colors, String>();
		em.set(Colors.Red, "red");
		em.set(Colors.Green, "green");
		em.set(Colors.Blue, "blue");
		Assert.equals("red", em.get(Colors.Red));
		Assert.equals("blue", em.get(Colors.Blue));
		Assert.isTrue(em.exists(Colors.Red));
		Assert.isTrue(em.exists(Colors.Green));
		em.set(Colors.Red, "RED");
		Assert.equals("RED", em.get(Colors.Red));
		Assert.isTrue(em.remove(Colors.Green));
		Assert.isFalse(em.remove(Colors.Green));
		Assert.isFalse(em.exists(Colors.Green));
	}

	function testEnumValueMapIteration() {
		var em = new haxe.ds.EnumValueMap<Colors, String>();
		em.set(Colors.Red, "red");
		em.set(Colors.Green, "green");
		em.set(Colors.Blue, "blue");
		var keyCount = 0;
		for (k in em.keys()) {
			keyCount++;
		}
		Assert.equals(3, keyCount);
		var valCount = 0;
		for (v in em.iterator()) {
			valCount++;
		}
		Assert.equals(3, valCount);
		em.clear();
		Assert.isFalse(em.exists(Colors.Red));
	}
}
