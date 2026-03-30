package;

import utest.Assert;

class StringBufTests extends utest.Test {
	function testStringBufBasic() {
		var buf = new StringBuf();
		buf.add("Hello");
		buf.add(" ");
		buf.add("World");
		Assert.equals("Hello World", buf.toString());

		var buf2 = new StringBuf();
		buf2.add(42);
		buf2.add(true);
		buf2.add(3.14);
		var result2 = buf2.toString();
		Assert.isTrue(StringTools.contains(result2, "42"));
		Assert.isTrue(StringTools.contains(result2, "true"));
		Assert.isTrue(StringTools.contains(result2, "3.14"));

		var buf3 = new StringBuf();
		Assert.equals("", buf3.toString());
	}

	function testStringBufAddChar() {
		var buf = new StringBuf();
		buf.addChar(72);
		buf.addChar(105);
		Assert.equals("Hi", buf.toString());
		buf.addChar(33);
		Assert.equals("Hi!", buf.toString());
	}

	function testStringBufAddSub() {
		var buf = new StringBuf();
		buf.addSub("Hello World", 6);
		Assert.equals("World", buf.toString());

		var buf2 = new StringBuf();
		buf2.addSub("Hello World", 0, 5);
		Assert.equals("Hello", buf2.toString());

		var buf3 = new StringBuf();
		buf3.addSub("abcdef", 2, 3);
		Assert.equals("cde", buf3.toString());
	}

	function testStringBufLength() {
		var buf = new StringBuf();
		Assert.equals(0, buf.length);
		buf.add("Hi");
		Assert.equals(2, buf.length);
		buf.addChar(33);
		Assert.equals(3, buf.length);
		buf.addSub("abcdef", 1, 3);
		Assert.equals(6, buf.length);
	}

	function testStringBufEdgeCases() {
		var buf = new StringBuf();
		buf.add("");
		Assert.equals("", buf.toString());
		Assert.equals(0, buf.length);

		buf.add("test");
		buf.add("");
		Assert.equals("test", buf.toString());

		var buf2 = new StringBuf();
		buf2.addSub("hello", 0, 0);
		Assert.equals("", buf2.toString());

		var buf3 = new StringBuf();
		buf3.add("a");
		buf3.add("b");
		buf3.add("c");
		var s1 = buf3.toString();
		var s2 = buf3.toString();
		Assert.equals("abc", s1);
		Assert.equals(s1, s2);
	}
}
