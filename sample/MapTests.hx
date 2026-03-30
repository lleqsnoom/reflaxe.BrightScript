package;

import Main.Colors;
import Main.MapKey;

class MapTests {
	var t:Main;

	public function new(main:Main) {
		t = main;
	}

	public function run() {
		t.section("StringMapBasic");
		checkStringMapBasic();
		t.section("StringMapIteration");
		checkStringMapIteration();
		t.section("StringMapOverwrite");
		checkStringMapOverwrite();
		t.section("StringMapCopyClear");
		checkStringMapCopyClear();
		t.section("StringMapToString");
		checkStringMapToString();
		t.section("IntMapBasic");
		checkIntMapBasic();
		t.section("IntMapIteration");
		checkIntMapIteration();
		t.section("MapArrayAccess");
		checkMapArrayAccess();
		t.section("MapForIn");
		checkMapForIn();
		t.section("ObjectMapBasic");
		checkObjectMapBasic();
		t.section("ObjectMapIteration");
		checkObjectMapIteration();
		t.section("EnumValueMapBasic");
		checkEnumValueMapBasic();
		t.section("EnumValueMapIteration");
		checkEnumValueMapIteration();
	}

	function checkStringMapBasic() {
		var sm = new Map<String, Int>();
		sm.set("one", 1);
		sm.set("two", 2);
		sm.set("three", 3);
		var g1 = sm.get("one");
		var g1ok = g1 == 1;
		t.isTrue(g1ok, "get one");
		var g2 = sm.get("two");
		var g2ok = g2 == 2;
		t.isTrue(g2ok, "get two");
		var e1 = sm.exists("one");
		t.isTrue(e1, "exists one");
		var e2 = sm.exists("four");
		t.isFalse(e2, "not exists four");
		var rm1 = sm.remove("one");
		t.isTrue(rm1, "remove one");
		var rm2 = sm.remove("four");
		t.isFalse(rm2, "remove missing");
		var e3 = sm.exists("one");
		t.isFalse(e3, "not exists after remove");
	}

	function checkStringMapIteration() {
		var sm = new Map<String, Int>();
		sm.set("a", 1);
		sm.set("b", 2);
		sm.set("c", 3);
		var keyCount = 0;
		for (key in sm.keys()) {
			keyCount++;
		}
		t.intEquals(3, keyCount, "key count");
		var valCount = 0;
		for (val in sm.iterator()) {
			valCount++;
		}
		t.intEquals(3, valCount, "value count");
	}

	function checkStringMapOverwrite() {
		var sm = new Map<String, Int>();
		sm.set("key", 1);
		var g1 = sm.get("key");
		var g1ok = g1 == 1;
		t.isTrue(g1ok, "initial value");
		sm.set("key", 2);
		var g2 = sm.get("key");
		var g2ok = g2 == 2;
		t.isTrue(g2ok, "overwritten value");
	}

	function checkStringMapCopyClear() {
		var sm = new Map<String, Int>();
		sm.set("a", 1);
		sm.set("b", 2);
		var cp = sm.copy();
		cp.set("c", 3);
		var e1 = sm.exists("c");
		t.isFalse(e1, "original lacks copy key");
		var e2 = cp.exists("a");
		t.isTrue(e2, "copy has original key");
		var e3 = cp.exists("c");
		t.isTrue(e3, "copy has new key");
		sm.clear();
		var e4 = sm.exists("a");
		t.isFalse(e4, "empty after clear");
		var e5 = cp.exists("a");
		t.isTrue(e5, "copy unaffected by clear");
	}

	function checkStringMapToString() {
		var sm = new Map<String, Int>();
		sm.set("a", 1);
		var s = sm.toString();
		var hasKey = StringTools.contains(s, "a");
		t.isTrue(hasKey, "toString contains key");
		var hasArrow = StringTools.contains(s, "=>");
		t.isTrue(hasArrow, "toString contains =>");
	}

	function checkIntMapBasic() {
		var im = new Map<Int, String>();
		im.set(1, "one");
		im.set(2, "two");
		im.set(3, "three");
		var g1 = im.get(1);
		t.stringEquals("one", g1, "get 1");
		var g2 = im.get(2);
		t.stringEquals("two", g2, "get 2");
		var e1 = im.exists(1);
		t.isTrue(e1, "exists 1");
		var e2 = im.exists(4);
		t.isFalse(e2, "not exists 4");
		var rm1 = im.remove(1);
		t.isTrue(rm1, "remove 1");
		var rm2 = im.remove(4);
		t.isFalse(rm2, "remove missing 4");
		var e3 = im.exists(1);
		t.isFalse(e3, "not exists after remove");
	}

	function checkIntMapIteration() {
		var im = new Map<Int, String>();
		im.set(10, "ten");
		im.set(20, "twenty");
		im.set(30, "thirty");
		var keySum = 0;
		for (key in im.keys()) {
			keySum += key;
		}
		t.intEquals(60, keySum, "keys sum");
		var valCount = 0;
		for (val in im.iterator()) {
			valCount++;
		}
		t.intEquals(3, valCount, "value count");
	}

	function checkMapArrayAccess() {
		var mp = new Map<String, Int>();
		mp.set("x", 10);
		mp.set("y", 20);
		var gx = mp["x"];
		var gxOk = gx == 10;
		t.isTrue(gxOk, "array access x");
		var gy = mp["y"];
		var gyOk = gy == 20;
		t.isTrue(gyOk, "array access y");
		mp.set("x", 30);
		var gx2 = mp["x"];
		var gx2Ok = gx2 == 30;
		t.isTrue(gx2Ok, "array access overwrite");
	}

	function checkMapForIn() {
		var sm = new Map<String, Int>();
		sm.set("a", 10);
		sm.set("b", 20);
		sm.set("c", 30);
		var keyCount = 0;
		for (key in sm.keys()) {
			keyCount++;
		}
		t.intEquals(3, keyCount, "for-in key count");
		var valCount = 0;
		for (val in sm.iterator()) {
			valCount++;
		}
		t.intEquals(3, valCount, "for-in val count");
	}

	function checkObjectMapBasic() {
		var om = new haxe.ds.ObjectMap<MapKey, String>();
		var k1 = new MapKey(1);
		var k2 = new MapKey(2);
		var k3 = new MapKey(3);
		om.set(k1, "one");
		om.set(k2, "two");
		om.set(k3, "three");
		var g1 = om.get(k1);
		t.stringEquals("one", g1, "get k1");
		var g2 = om.get(k2);
		t.stringEquals("two", g2, "get k2");
		var e1 = om.exists(k1);
		t.isTrue(e1, "exists k1");
		var k4 = new MapKey(4);
		var e2 = om.exists(k4);
		t.isFalse(e2, "not exists k4");
		om.set(k1, "ONE");
		var g3 = om.get(k1);
		t.stringEquals("ONE", g3, "overwrite k1");
		var rm1 = om.remove(k2);
		t.isTrue(rm1, "remove k2");
		var rm2 = om.remove(k4);
		t.isFalse(rm2, "remove missing k4");
		var e3 = om.exists(k2);
		t.isFalse(e3, "not exists after remove");
	}

	function checkObjectMapIteration() {
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
		t.intEquals(3, keyCount, "key count");
		var valCount = 0;
		for (val in om.iterator()) {
			valCount++;
		}
		t.intEquals(3, valCount, "val count");
		om.clear();
		var e1 = om.exists(k1);
		t.isFalse(e1, "not exists after clear");
	}

	function checkEnumValueMapBasic() {
		var em = new haxe.ds.EnumValueMap<Colors, String>();
		em.set(Colors.Red, "red");
		em.set(Colors.Green, "green");
		em.set(Colors.Blue, "blue");
		var g1 = em.get(Colors.Red);
		t.stringEquals("red", g1, "get Red");
		var g2 = em.get(Colors.Blue);
		t.stringEquals("blue", g2, "get Blue");
		var e1 = em.exists(Colors.Red);
		t.isTrue(e1, "exists Red");
		var e2 = em.exists(Colors.Green);
		t.isTrue(e2, "exists Green");
		em.set(Colors.Red, "RED");
		var g3 = em.get(Colors.Red);
		t.stringEquals("RED", g3, "overwrite Red");
		var rm1 = em.remove(Colors.Green);
		t.isTrue(rm1, "remove Green");
		var rm2 = em.remove(Colors.Green);
		t.isFalse(rm2, "remove Green again");
		var e3 = em.exists(Colors.Green);
		t.isFalse(e3, "not exists after remove");
	}

	function checkEnumValueMapIteration() {
		var em = new haxe.ds.EnumValueMap<Colors, String>();
		em.set(Colors.Red, "red");
		em.set(Colors.Green, "green");
		em.set(Colors.Blue, "blue");
		var keyCount = 0;
		for (k in em.keys()) {
			keyCount++;
		}
		t.intEquals(3, keyCount, "key count");
		var valCount = 0;
		for (v in em.iterator()) {
			valCount++;
		}
		t.intEquals(3, valCount, "val count");
		em.clear();
		var e1 = em.exists(Colors.Red);
		t.isFalse(e1, "not exists after clear");
	}
}
