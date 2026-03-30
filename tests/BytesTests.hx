package;

import utest.Assert;
import haxe.io.Bytes;

class BytesTests extends utest.Test {
	function testAlloc() {
		var b = Bytes.alloc(4);
		Assert.equals(4, b.length);
		Assert.equals(0, b.get(0));
		Assert.equals(0, b.get(3));

		var empty = Bytes.alloc(0);
		Assert.equals(0, empty.length);
	}

	function testGetSet() {
		var b = Bytes.alloc(4);
		b.set(0, 65);
		b.set(1, 66);
		b.set(2, 67);
		b.set(3, 255);
		Assert.equals(65, b.get(0));
		Assert.equals(66, b.get(1));
		Assert.equals(67, b.get(2));
		Assert.equals(255, b.get(3));
	}

	function testFill() {
		var b = Bytes.alloc(5);
		b.fill(1, 3, 42);
		Assert.equals(0, b.get(0));
		Assert.equals(42, b.get(1));
		Assert.equals(42, b.get(2));
		Assert.equals(42, b.get(3));
		Assert.equals(0, b.get(4));
	}

	function testSub() {
		var b = Bytes.alloc(5);
		b.set(0, 10);
		b.set(1, 20);
		b.set(2, 30);
		b.set(3, 40);
		b.set(4, 50);
		var s = b.sub(1, 3);
		Assert.equals(3, s.length);
		Assert.equals(20, s.get(0));
		Assert.equals(30, s.get(1));
		Assert.equals(40, s.get(2));
	}

	function testBlit() {
		var src = Bytes.alloc(3);
		src.set(0, 1);
		src.set(1, 2);
		src.set(2, 3);
		var dst = Bytes.alloc(5);
		dst.fill(0, 5, 0);
		dst.blit(1, src, 0, 3);
		Assert.equals(0, dst.get(0));
		Assert.equals(1, dst.get(1));
		Assert.equals(2, dst.get(2));
		Assert.equals(3, dst.get(3));
		Assert.equals(0, dst.get(4));
	}

	function testCompare() {
		var a = Bytes.alloc(3);
		a.set(0, 1);
		a.set(1, 2);
		a.set(2, 3);
		var b = Bytes.alloc(3);
		b.set(0, 1);
		b.set(1, 2);
		b.set(2, 3);
		Assert.equals(0, a.compare(b));

		var c = Bytes.alloc(3);
		c.set(0, 1);
		c.set(1, 3);
		c.set(2, 3);
		Assert.isTrue(a.compare(c) < 0);
		Assert.isTrue(c.compare(a) > 0);

		var shorter = Bytes.alloc(2);
		shorter.set(0, 1);
		shorter.set(1, 2);
		Assert.isTrue(shorter.compare(a) < 0);
	}

	function testOfString() {
		var b = Bytes.ofString("ABC");
		Assert.equals(3, b.length);
		Assert.equals(65, b.get(0));
		Assert.equals(66, b.get(1));
		Assert.equals(67, b.get(2));

		Assert.equals(0, Bytes.ofString("").length);
	}

	function testGetString() {
		var b = Bytes.ofString("Hello World");
		Assert.equals("World", b.getString(6, 5));
		Assert.equals("Hello World", b.getString(0, 11));
	}

	function testToString() {
		var b = Bytes.ofString("Test");
		Assert.equals("Test", b.toString());

		Assert.equals("", Bytes.alloc(0).toString());
	}

	function testToHex() {
		var b = Bytes.alloc(3);
		b.set(0, 0);
		b.set(1, 255);
		b.set(2, 171);
		Assert.equals("00ffab", b.toHex());

		Assert.equals("4142", Bytes.ofString("AB").toHex());
	}

	function testOfHex() {
		var b = Bytes.ofHex("4142");
		Assert.equals(2, b.length);
		Assert.equals(65, b.get(0));
		Assert.equals(66, b.get(1));

		var b2 = Bytes.ofHex("00ff");
		Assert.equals(0, b2.get(0));
		Assert.equals(255, b2.get(1));
	}

	function testInt32() {
		var b = Bytes.alloc(4);
		b.setInt32(0, 305419896);
		Assert.equals(0x78, b.get(0));
		Assert.equals(0x56, b.get(1));
		Assert.equals(0x34, b.get(2));
		Assert.equals(0x12, b.get(3));
		Assert.equals(305419896, b.getInt32(0));
	}

	function testUInt16() {
		var b = Bytes.alloc(4);
		b.setUInt16(0, 0x0102);
		Assert.equals(0x02, b.get(0));
		Assert.equals(0x01, b.get(1));
		Assert.equals(258, b.getUInt16(0));

		b.setUInt16(2, 65535);
		Assert.equals(255, b.get(2));
		Assert.equals(255, b.get(3));
		Assert.equals(65535, b.getUInt16(2));
	}
}
