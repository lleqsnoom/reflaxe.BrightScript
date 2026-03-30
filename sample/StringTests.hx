package;

class StringTests {
	var t:Main;

	public function new(main:Main) {
		t = main;
	}

	public function run() {
		t.section("StringLength");
		checkStringLength();
		t.section("StringCase");
		checkStringCase();
		t.section("StringCharAt");
		checkStringCharAt();
		t.section("StringCharCodeAt");
		checkStringCharCodeAt();
		t.section("StringIndexOf");
		checkStringIndexOf();
		t.section("StringLastIndexOf");
		checkStringLastIndexOf();
		t.section("StringSplit");
		checkStringSplit();
		t.section("StringSubstr");
		checkStringSubstr();
		t.section("StringSubstring");
		checkStringSubstring();
		t.section("StringFromCharCode");
		checkStringFromCharCode();
		t.section("StringToString");
		checkStringToString();
	}

	function checkStringLength() {
		var s = "Hello";
		t.intEquals(5, s.length, "string length");
		var empty = "";
		t.intEquals(0, empty.length, "empty string length");
	}

	function checkStringCase() {
		var s = "Hello World";
		var up = s.toUpperCase();
		t.stringEquals("HELLO WORLD", up, "toUpperCase");
		var lo = s.toLowerCase();
		t.stringEquals("hello world", lo, "toLowerCase");
	}

	function checkStringCharAt() {
		var s = "Hello";
		var c0 = s.charAt(0);
		t.stringEquals("H", c0, "charAt 0");
		var c4 = s.charAt(4);
		t.stringEquals("o", c4, "charAt 4");
	}

	function checkStringCharCodeAt() {
		var s = "ABC";
		var code = s.charCodeAt(0);
		var codeOk = code == 65;
		t.isTrue(codeOk, "charCodeAt 0 = 65");
		var code2 = s.charCodeAt(1);
		var codeOk2 = code2 == 66;
		t.isTrue(codeOk2, "charCodeAt 1 = 66");
	}

	function checkStringIndexOf() {
		var s = "Hello World";
		var idx1 = s.indexOf("World");
		t.intEquals(6, idx1, "indexOf World");
		var idx2 = s.indexOf("xyz");
		t.intEquals(-1, idx2, "indexOf missing");
		var idx3 = s.indexOf("l", 4);
		t.intEquals(9, idx3, "indexOf l from 4");
		var idx4 = s.indexOf("l");
		t.intEquals(2, idx4, "indexOf l");
	}

	function checkStringLastIndexOf() {
		var s = "abcabc";
		var li1 = s.lastIndexOf("abc");
		t.intEquals(3, li1, "lastIndexOf abc");
		var li2 = s.lastIndexOf("abc", 2);
		t.intEquals(0, li2, "lastIndexOf abc from 2");
		var li3 = s.lastIndexOf("xyz");
		t.intEquals(-1, li3, "lastIndexOf missing");
	}

	function checkStringSplit() {
		var parts = "a,b,c".split(",");
		t.intEquals(3, parts.length, "split length");
		t.stringEquals("a", parts[0], "split 0");
		t.stringEquals("b", parts[1], "split 1");
		t.stringEquals("c", parts[2], "split 2");
	}

	function checkStringSubstr() {
		var s = "Hello World";
		var r1 = s.substr(6);
		t.stringEquals("World", r1, "substr from 6");
		var r2 = s.substr(0, 5);
		t.stringEquals("Hello", r2, "substr 0,5");
		var r3 = s.substr(3, 4);
		t.stringEquals("lo W", r3, "substr 3,4");
	}

	function checkStringSubstring() {
		var s = "Hello World";
		var r1 = s.substring(0, 5);
		t.stringEquals("Hello", r1, "substring 0,5");
		var r2 = s.substring(6);
		t.stringEquals("World", r2, "substring from 6");
		var r3 = s.substring(6, 11);
		t.stringEquals("World", r3, "substring 6,11");
	}

	function checkStringFromCharCode() {
		var a = String.fromCharCode(65);
		t.stringEquals("A", a, "fromCharCode 65");
		var h = String.fromCharCode(72);
		t.stringEquals("H", h, "fromCharCode 72");
	}

	function checkStringToString() {
		var s = "test";
		var r = s.toString();
		t.stringEquals("test", r, "toString");
	}
}
