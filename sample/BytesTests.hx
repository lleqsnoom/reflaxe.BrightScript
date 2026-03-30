package;

import haxe.io.Bytes;

class BytesTests {
	var t:Main;

	public function new(main:Main) {
		t = main;
	}

	public function run() {
		t.section("BytesAlloc");
		checkAlloc();
		t.section("BytesGetSet");
		checkGetSet();
		t.section("BytesFill");
		checkFill();
		t.section("BytesSub");
		checkSub();
		t.section("BytesBlit");
		checkBlit();
		t.section("BytesCompare");
		checkCompare();
		t.section("BytesOfString");
		checkOfString();
		t.section("BytesGetString");
		checkGetString();
		t.section("BytesToString");
		checkToString();
		t.section("BytesToHex");
		checkToHex();
		t.section("BytesOfHex");
		checkOfHex();
		t.section("BytesInt32");
		checkInt32();
		t.section("BytesUInt16");
		checkUInt16();
	}

	function checkAlloc() {
		var b = Bytes.alloc(4);
		t.intEquals(4, b.length, "alloc length 4");
		t.intEquals(0, b.get(0), "alloc zeroed 0");
		t.intEquals(0, b.get(3), "alloc zeroed 3");

		var empty = Bytes.alloc(0);
		t.intEquals(0, empty.length, "alloc length 0");
	}

	function checkGetSet() {
		var b = Bytes.alloc(4);
		b.set(0, 65);
		b.set(1, 66);
		b.set(2, 67);
		b.set(3, 255);
		t.intEquals(65, b.get(0), "get/set 0=65");
		t.intEquals(66, b.get(1), "get/set 1=66");
		t.intEquals(67, b.get(2), "get/set 2=67");
		t.intEquals(255, b.get(3), "get/set 3=255");
	}

	function checkFill() {
		var b = Bytes.alloc(5);
		b.fill(1, 3, 42);
		t.intEquals(0, b.get(0), "fill before range");
		t.intEquals(42, b.get(1), "fill pos 1");
		t.intEquals(42, b.get(2), "fill pos 2");
		t.intEquals(42, b.get(3), "fill pos 3");
		t.intEquals(0, b.get(4), "fill after range");
	}

	function checkSub() {
		var b = Bytes.alloc(5);
		b.set(0, 10);
		b.set(1, 20);
		b.set(2, 30);
		b.set(3, 40);
		b.set(4, 50);
		var s = b.sub(1, 3);
		t.intEquals(3, s.length, "sub length");
		t.intEquals(20, s.get(0), "sub byte 0");
		t.intEquals(30, s.get(1), "sub byte 1");
		t.intEquals(40, s.get(2), "sub byte 2");
	}

	function checkBlit() {
		var src = Bytes.alloc(3);
		src.set(0, 1);
		src.set(1, 2);
		src.set(2, 3);
		var dst = Bytes.alloc(5);
		dst.fill(0, 5, 0);
		dst.blit(1, src, 0, 3);
		t.intEquals(0, dst.get(0), "blit before");
		t.intEquals(1, dst.get(1), "blit byte 1");
		t.intEquals(2, dst.get(2), "blit byte 2");
		t.intEquals(3, dst.get(3), "blit byte 3");
		t.intEquals(0, dst.get(4), "blit after");
	}

	function checkCompare() {
		var a = Bytes.alloc(3);
		a.set(0, 1);
		a.set(1, 2);
		a.set(2, 3);
		var b = Bytes.alloc(3);
		b.set(0, 1);
		b.set(1, 2);
		b.set(2, 3);
		t.intEquals(0, a.compare(b), "compare equal");

		var c = Bytes.alloc(3);
		c.set(0, 1);
		c.set(1, 3);
		c.set(2, 3);
		var cmpAC = a.compare(c);
		var acLess = cmpAC < 0;
		t.isTrue(acLess, "compare less");

		var cmpCA = c.compare(a);
		var caGreater = cmpCA > 0;
		t.isTrue(caGreater, "compare greater");

		var shorter = Bytes.alloc(2);
		shorter.set(0, 1);
		shorter.set(1, 2);
		var cmpShort = shorter.compare(a);
		var shortLess = cmpShort < 0;
		t.isTrue(shortLess, "compare shorter < longer");
	}

	function checkOfString() {
		var b = Bytes.ofString("ABC");
		t.intEquals(3, b.length, "ofString length");
		t.intEquals(65, b.get(0), "ofString A=65");
		t.intEquals(66, b.get(1), "ofString B=66");
		t.intEquals(67, b.get(2), "ofString C=67");

		var empty = Bytes.ofString("");
		t.intEquals(0, empty.length, "ofString empty");
	}

	function checkGetString() {
		var b = Bytes.ofString("Hello World");
		var part = b.getString(6, 5);
		t.stringEquals("World", part, "getString World");
		var full = b.getString(0, 11);
		t.stringEquals("Hello World", full, "getString full");
	}

	function checkToString() {
		var b = Bytes.ofString("Test");
		t.stringEquals("Test", b.toString(), "toString");

		var empty = Bytes.alloc(0);
		t.stringEquals("", empty.toString(), "toString empty");
	}

	function checkToHex() {
		var b = Bytes.alloc(3);
		b.set(0, 0);
		b.set(1, 255);
		b.set(2, 171);
		t.stringEquals("00ffab", b.toHex(), "toHex 00ffab");

		var b2 = Bytes.ofString("AB");
		t.stringEquals("4142", b2.toHex(), "toHex AB=4142");
	}

	function checkOfHex() {
		var b = Bytes.ofHex("4142");
		t.intEquals(2, b.length, "ofHex length");
		t.intEquals(65, b.get(0), "ofHex A=65");
		t.intEquals(66, b.get(1), "ofHex B=66");

		var b2 = Bytes.ofHex("00ff");
		t.intEquals(0, b2.get(0), "ofHex 0x00");
		t.intEquals(255, b2.get(1), "ofHex 0xff");
	}

	function checkInt32() {
		var b = Bytes.alloc(4);
		b.setInt32(0, 305419896);
		t.intEquals(0x78, b.get(0), "setInt32 byte 0");
		t.intEquals(0x56, b.get(1), "setInt32 byte 1");
		t.intEquals(0x34, b.get(2), "setInt32 byte 2");
		t.intEquals(0x12, b.get(3), "setInt32 byte 3");
		var v = b.getInt32(0);
		t.intEquals(305419896, v, "getInt32 roundtrip");
	}

	function checkUInt16() {
		var b = Bytes.alloc(4);
		b.setUInt16(0, 0x0102);
		t.intEquals(0x02, b.get(0), "setUInt16 low byte");
		t.intEquals(0x01, b.get(1), "setUInt16 high byte");
		var v = b.getUInt16(0);
		t.intEquals(258, v, "getUInt16 roundtrip");

		b.setUInt16(2, 65535);
		t.intEquals(255, b.get(2), "setUInt16 0xFFFF low");
		t.intEquals(255, b.get(3), "setUInt16 0xFFFF high");
		var v2 = b.getUInt16(2);
		t.intEquals(65535, v2, "getUInt16 0xFFFF roundtrip");
	}
}
