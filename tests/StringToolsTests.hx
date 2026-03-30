package;

import utest.Assert;

class StringToolsTests extends utest.Test {
	function testStringToolsContains() {
		Assert.isTrue(StringTools.contains("Hello World", "World"));
		Assert.isFalse(StringTools.contains("Hello World", "xyz"));
		Assert.isTrue(StringTools.contains("Hello World", "Hello"));
		Assert.isFalse(StringTools.contains("", "a"));
	}

	function testStringToolsStartsEndsWith() {
		var s = "Hello World";
		Assert.isTrue(StringTools.startsWith(s, "Hello"));
		Assert.isFalse(StringTools.startsWith(s, "World"));
		Assert.isTrue(StringTools.startsWith(s, ""));
		Assert.isTrue(StringTools.endsWith(s, "World"));
		Assert.isFalse(StringTools.endsWith(s, "Hello"));
		Assert.isTrue(StringTools.endsWith(s, ""));
	}

	function testStringToolsTrim() {
		Assert.equals("hello", StringTools.trim("  hello  "));
		Assert.equals("hello", StringTools.trim("hello"));
		Assert.equals("", StringTools.trim("   "));
		Assert.equals("hello  ", StringTools.ltrim("  hello  "));
		Assert.equals("hello", StringTools.ltrim("hello"));
		Assert.equals("  hello", StringTools.rtrim("  hello  "));
		Assert.equals("hello", StringTools.rtrim("hello"));
	}

	function testStringToolsPad() {
		Assert.equals("000hi", StringTools.lpad("hi", "0", 5));
		Assert.equals("hello", StringTools.lpad("hello", "0", 3));
		Assert.equals("ababx", StringTools.lpad("x", "ab", 5));
		Assert.equals("hi000", StringTools.rpad("hi", "0", 5));
		Assert.equals("hello", StringTools.rpad("hello", "0", 3));
		Assert.equals("xabab", StringTools.rpad("x", "ab", 5));
	}

	function testStringToolsReplace() {
		Assert.equals("hello there", StringTools.replace("hello world", "world", "there"));
		Assert.equals("bbbbbb", StringTools.replace("aaa", "a", "bb"));
		Assert.equals("a-b-c", StringTools.replace("abc", "", "-"));
		Assert.equals("hello", StringTools.replace("hello", "xyz", "abc"));
	}

	function testStringToolsHex() {
		Assert.equals("FF", StringTools.hex(255));
		Assert.equals("0", StringTools.hex(0));
		Assert.equals("10", StringTools.hex(16));
		Assert.equals("00FF", StringTools.hex(255, 4));
		Assert.equals("00000001", StringTools.hex(1, 8));
	}

	function testStringToolsIsSpace() {
		var nine = Std.parseInt("9");
		var s = " " + String.fromCharCode(nine) + "hello";
		Assert.isTrue(StringTools.isSpace(s, 0));
		Assert.isTrue(StringTools.isSpace(s, 1));
		Assert.isFalse(StringTools.isSpace(s, 2));
		Assert.isFalse(StringTools.isSpace("", 0));
		Assert.isFalse(StringTools.isSpace("a", -1));
	}

	function testStringToolsCodeAt() {
		var s = "ABC";
		Assert.equals(65, StringTools.fastCodeAt(s, 0));
		Assert.equals(67, StringTools.fastCodeAt(s, 2));
		Assert.isTrue(StringTools.isEof(StringTools.fastCodeAt(s, 3)));
		Assert.equals(65, StringTools.unsafeCodeAt(s, 0));
		Assert.equals(66, StringTools.unsafeCodeAt(s, 1));
	}

	function testStringToolsHtmlEscape() {
		Assert.equals("&lt;b&gt;bold&lt;/b&gt;", StringTools.htmlEscape("<b>bold</b>"));
		Assert.equals("a &amp; b", StringTools.htmlEscape("a & b"));
		Assert.equals("<b>bold</b>", StringTools.htmlUnescape("&lt;b&gt;bold&lt;/b&gt;"));
		Assert.equals("a & b", StringTools.htmlUnescape("a &amp; b"));
	}

	function testStringToolsUrlEncode() {
		Assert.equals("hello%20world", StringTools.urlEncode("hello world"));
		Assert.equals("a%3D1%26b%3D2", StringTools.urlEncode("a=1&b=2"));
		Assert.equals("hello world", StringTools.urlDecode("hello%20world"));
		Assert.equals("hello world", StringTools.urlDecode("hello+world"));
	}
}
