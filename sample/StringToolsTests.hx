package;

class StringToolsTests {
	var t:Main;

	public function new(main:Main) {
		t = main;
	}

	public function run() {
		t.section("StringToolsContains");
		checkStringToolsContains();
		t.section("StringToolsStartsEndsWith");
		checkStringToolsStartsEndsWith();
		t.section("StringToolsTrim");
		checkStringToolsTrim();
		t.section("StringToolsPad");
		checkStringToolsPad();
		t.section("StringToolsReplace");
		checkStringToolsReplace();
		t.section("StringToolsHex");
		checkStringToolsHex();
		t.section("StringToolsIsSpace");
		checkStringToolsIsSpace();
		t.section("StringToolsCodeAt");
		checkStringToolsCodeAt();
		t.section("StringToolsHtmlEscape");
		checkStringToolsHtmlEscape();
		t.section("StringToolsUrlEncode");
		checkStringToolsUrlEncode();
	}

	function checkStringToolsContains() {
		var s = "Hello World";
		var c1 = StringTools.contains(s, "World");
		t.isTrue(c1, "contains World");
		var c2 = StringTools.contains(s, "xyz");
		t.isFalse(c2, "not contains xyz");
		var c3 = StringTools.contains(s, "Hello");
		t.isTrue(c3, "contains Hello");
		var c4 = StringTools.contains("", "a");
		t.isFalse(c4, "empty not contains a");
	}

	function checkStringToolsStartsEndsWith() {
		var s = "Hello World";
		var sw1 = StringTools.startsWith(s, "Hello");
		t.isTrue(sw1, "startsWith Hello");
		var sw2 = StringTools.startsWith(s, "World");
		t.isFalse(sw2, "not startsWith World");
		var sw3 = StringTools.startsWith(s, "");
		t.isTrue(sw3, "startsWith empty");
		var ew1 = StringTools.endsWith(s, "World");
		t.isTrue(ew1, "endsWith World");
		var ew2 = StringTools.endsWith(s, "Hello");
		t.isFalse(ew2, "not endsWith Hello");
		var ew3 = StringTools.endsWith(s, "");
		t.isTrue(ew3, "endsWith empty");
	}

	function checkStringToolsTrim() {
		var r1 = StringTools.trim("  hello  ");
		t.stringEquals("hello", r1, "trim");
		var r2 = StringTools.trim("hello");
		t.stringEquals("hello", r2, "trim no spaces");
		var r3 = StringTools.trim("   ");
		t.stringEquals("", r3, "trim all spaces");
		var r4 = StringTools.ltrim("  hello  ");
		t.stringEquals("hello  ", r4, "ltrim");
		var r5 = StringTools.ltrim("hello");
		t.stringEquals("hello", r5, "ltrim no spaces");
		var r6 = StringTools.rtrim("  hello  ");
		t.stringEquals("  hello", r6, "rtrim");
		var r7 = StringTools.rtrim("hello");
		t.stringEquals("hello", r7, "rtrim no spaces");
	}

	function checkStringToolsPad() {
		var r1 = StringTools.lpad("hi", "0", 5);
		t.stringEquals("000hi", r1, "lpad zeros");
		var r2 = StringTools.lpad("hello", "0", 3);
		t.stringEquals("hello", r2, "lpad no pad needed");
		var r3 = StringTools.lpad("x", "ab", 5);
		t.stringEquals("ababx", r3, "lpad multi char");
		var r4 = StringTools.rpad("hi", "0", 5);
		t.stringEquals("hi000", r4, "rpad zeros");
		var r5 = StringTools.rpad("hello", "0", 3);
		t.stringEquals("hello", r5, "rpad no pad needed");
		var r6 = StringTools.rpad("x", "ab", 5);
		t.stringEquals("xabab", r6, "rpad multi char");
	}

	function checkStringToolsReplace() {
		var r1 = StringTools.replace("hello world", "world", "there");
		t.stringEquals("hello there", r1, "replace word");
		var r2 = StringTools.replace("aaa", "a", "bb");
		t.stringEquals("bbbbbb", r2, "replace all occurrences");
		var r3 = StringTools.replace("abc", "", "-");
		t.stringEquals("a-b-c", r3, "replace empty sub");
		var r4 = StringTools.replace("hello", "xyz", "abc");
		t.stringEquals("hello", r4, "replace not found");
	}

	function checkStringToolsHex() {
		var r1 = StringTools.hex(255);
		t.stringEquals("FF", r1, "hex 255");
		var r2 = StringTools.hex(0);
		t.stringEquals("0", r2, "hex 0");
		var r3 = StringTools.hex(16);
		t.stringEquals("10", r3, "hex 16");
		var r4 = StringTools.hex(255, 4);
		t.stringEquals("00FF", r4, "hex 255 pad 4");
		var r5 = StringTools.hex(1, 8);
		t.stringEquals("00000001", r5, "hex 1 pad 8");
	}

	function checkStringToolsIsSpace() {
		var nine = Std.parseInt("9");
		var s = " " + String.fromCharCode(nine) + "hello";
		var v1 = StringTools.isSpace(s, 0);
		t.isTrue(v1, "space is space");
		var v2 = StringTools.isSpace(s, 1);
		t.isTrue(v2, "tab is space");
		var v3 = StringTools.isSpace(s, 2);
		t.isFalse(v3, "h is not space");
		var v4 = StringTools.isSpace("", 0);
		t.isFalse(v4, "empty string");
		var v5 = StringTools.isSpace("a", -1);
		t.isFalse(v5, "negative index");
	}

	function checkStringToolsCodeAt() {
		var s = "ABC";
		var fc0 = StringTools.fastCodeAt(s, 0);
		t.intEquals(65, fc0, "fastCodeAt 0");
		var fc2 = StringTools.fastCodeAt(s, 2);
		t.intEquals(67, fc2, "fastCodeAt 2");
		var fc3 = StringTools.fastCodeAt(s, 3);
		var isEof = StringTools.isEof(fc3);
		t.isTrue(isEof, "fastCodeAt out of bounds is EOF");
		var uc0 = StringTools.unsafeCodeAt(s, 0);
		t.intEquals(65, uc0, "unsafeCodeAt 0");
		var uc1 = StringTools.unsafeCodeAt(s, 1);
		t.intEquals(66, uc1, "unsafeCodeAt 1");
	}

	function checkStringToolsHtmlEscape() {
		var r1 = StringTools.htmlEscape("<b>bold</b>");
		t.stringEquals("&lt;b&gt;bold&lt;/b&gt;", r1, "htmlEscape tags");
		var r2 = StringTools.htmlEscape("a & b");
		t.stringEquals("a &amp; b", r2, "htmlEscape amp");
		var r3 = StringTools.htmlUnescape("&lt;b&gt;bold&lt;/b&gt;");
		t.stringEquals("<b>bold</b>", r3, "htmlUnescape tags");
		var r4 = StringTools.htmlUnescape("a &amp; b");
		t.stringEquals("a & b", r4, "htmlUnescape amp");
	}

	function checkStringToolsUrlEncode() {
		var r1 = StringTools.urlEncode("hello world");
		t.stringEquals("hello%20world", r1, "urlEncode space");
		var r2 = StringTools.urlEncode("a=1&b=2");
		t.stringEquals("a%3D1%26b%3D2", r2, "urlEncode params");
		var r3 = StringTools.urlDecode("hello%20world");
		t.stringEquals("hello world", r3, "urlDecode percent");
		var r4 = StringTools.urlDecode("hello+world");
		t.stringEquals("hello world", r4, "urlDecode plus");
	}
}
