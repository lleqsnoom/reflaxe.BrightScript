package;

class StringBufTests {
	var t:Main;

	public function new(main:Main) {
		t = main;
	}

	public function run() {
		t.section("StringBufBasic");
		checkStringBufBasic();
		t.section("StringBufAddChar");
		checkStringBufAddChar();
		t.section("StringBufAddSub");
		checkStringBufAddSub();
		t.section("StringBufLength");
		checkStringBufLength();
		t.section("StringBufEdgeCases");
		checkStringBufEdgeCases();
	}

	function checkStringBufBasic() {
		var buf = new StringBuf();
		buf.add("Hello");
		buf.add(" ");
		buf.add("World");
		var result = buf.toString();
		t.stringEquals("Hello World", result, "basic concat");

		var buf2 = new StringBuf();
		buf2.add(42);
		buf2.add(true);
		buf2.add(3.14);
		var result2 = buf2.toString();
		var has42 = StringTools.contains(result2, "42");
		t.isTrue(has42, "mixed types contains 42");
		var hasTrue = StringTools.contains(result2, "true");
		t.isTrue(hasTrue, "mixed types contains true");
		var hasPi = StringTools.contains(result2, "3.14");
		t.isTrue(hasPi, "mixed types contains 3.14");

		var buf3 = new StringBuf();
		var empty = buf3.toString();
		t.stringEquals("", empty, "empty buf");
	}

	function checkStringBufAddChar() {
		var buf = new StringBuf();
		buf.addChar(72);
		buf.addChar(105);
		var r1 = buf.toString();
		t.stringEquals("Hi", r1, "addChar Hi");
		buf.addChar(33);
		var r2 = buf.toString();
		t.stringEquals("Hi!", r2, "addChar append !");
	}

	function checkStringBufAddSub() {
		var buf = new StringBuf();
		buf.addSub("Hello World", 6);
		var r1 = buf.toString();
		t.stringEquals("World", r1, "addSub from 6");

		var buf2 = new StringBuf();
		buf2.addSub("Hello World", 0, 5);
		var r2 = buf2.toString();
		t.stringEquals("Hello", r2, "addSub 0,5");

		var buf3 = new StringBuf();
		buf3.addSub("abcdef", 2, 3);
		var r3 = buf3.toString();
		t.stringEquals("cde", r3, "addSub 2,3");
	}

	function checkStringBufLength() {
		var buf = new StringBuf();
		t.intEquals(0, buf.length, "empty length");
		buf.add("Hi");
		t.intEquals(2, buf.length, "after add Hi");
		buf.addChar(33);
		t.intEquals(3, buf.length, "after addChar");
		buf.addSub("abcdef", 1, 3);
		t.intEquals(6, buf.length, "after addSub");
	}

	function checkStringBufEdgeCases() {
		var buf = new StringBuf();
		buf.add("");
		var r1 = buf.toString();
		t.stringEquals("", r1, "add empty string");
		t.intEquals(0, buf.length, "empty add length");

		buf.add("test");
		buf.add("");
		var r2 = buf.toString();
		t.stringEquals("test", r2, "add then empty");

		var buf2 = new StringBuf();
		buf2.addSub("hello", 0, 0);
		var r3 = buf2.toString();
		t.stringEquals("", r3, "addSub zero len");

		var buf3 = new StringBuf();
		buf3.add("a");
		buf3.add("b");
		buf3.add("c");
		var s1 = buf3.toString();
		var s2 = buf3.toString();
		t.stringEquals("abc", s1, "toString first call");
		t.stringEquals(s1, s2, "toString idempotent");
	}
}
