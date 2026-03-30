package;

import utest.Assert;

class StringTests extends utest.Test {
	function testStringLength() {
		var s = "Hello";
		Assert.equals(5, s.length);
		var empty = "";
		Assert.equals(0, empty.length);
	}

	function testStringCase() {
		var s = "Hello World";
		Assert.equals("HELLO WORLD", s.toUpperCase());
		Assert.equals("hello world", s.toLowerCase());
	}

	function testStringCharAt() {
		var s = "Hello";
		Assert.equals("H", s.charAt(0));
		Assert.equals("o", s.charAt(4));
	}

	function testStringCharCodeAt() {
		var s = "ABC";
		Assert.isTrue(s.charCodeAt(0) == 65);
		Assert.isTrue(s.charCodeAt(1) == 66);
	}

	function testStringIndexOf() {
		var s = "Hello World";
		Assert.equals(6, s.indexOf("World"));
		Assert.equals(-1, s.indexOf("xyz"));
		Assert.equals(9, s.indexOf("l", 4));
		Assert.equals(2, s.indexOf("l"));
	}

	function testStringLastIndexOf() {
		var s = "abcabc";
		Assert.equals(3, s.lastIndexOf("abc"));
		Assert.equals(0, s.lastIndexOf("abc", 2));
		Assert.equals(-1, s.lastIndexOf("xyz"));
	}

	function testStringSplit() {
		var parts = "a,b,c".split(",");
		Assert.equals(3, parts.length);
		Assert.equals("a", parts[0]);
		Assert.equals("b", parts[1]);
		Assert.equals("c", parts[2]);
	}

	function testStringSubstr() {
		var s = "Hello World";
		Assert.equals("World", s.substr(6));
		Assert.equals("Hello", s.substr(0, 5));
		Assert.equals("lo W", s.substr(3, 4));
	}

	function testStringSubstring() {
		var s = "Hello World";
		Assert.equals("Hello", s.substring(0, 5));
		Assert.equals("World", s.substring(6));
		Assert.equals("World", s.substring(6, 11));
	}

	function testStringFromCharCode() {
		Assert.equals("A", String.fromCharCode(65));
		Assert.equals("H", String.fromCharCode(72));
	}

	function testStringToString() {
		var s = "test";
		Assert.equals("test", s.toString());
	}
}
