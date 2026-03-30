package;

class ERegTests {
	var t:Main;

	public function new(main:Main) {
		t = main;
	}

	public function run() {
		t.section("ERegMatch");
		checkERegMatch();
		t.section("ERegMatched");
		checkERegMatched();
		t.section("ERegMatchedLeftRight");
		checkERegMatchedLeftRight();
		t.section("ERegMatchedPos");
		checkERegMatchedPos();
		t.section("ERegMatchSub");
		checkERegMatchSub();
		t.section("ERegSplit");
		checkERegSplit();
		t.section("ERegReplace");
		checkERegReplace();
		t.section("ERegMap");
		checkERegMap();
		t.section("ERegEscape");
		checkERegEscape();
	}

	function checkERegMatch() {
		var r = new EReg("world", "i");
		var m1 = r.match("Hello World");
		t.isTrue(m1, "case insensitive match");
		var m2 = r.match("Hello");
		t.isFalse(m2, "no match");

		var r2 = new EReg("[0-9]+", "");
		var m3 = r2.match("abc123def");
		t.isTrue(m3, "digit match");
		var m4 = r2.match("abcdef");
		t.isFalse(m4, "no digit match");

		var r3 = new EReg(".", "");
		var m5 = r3.match("");
		t.isFalse(m5, "empty string no match");
	}

	function checkERegMatched() {
		var r = new EReg("([a-z]+)@([a-z]+)", "");
		r.match("test@host.com");
		var m0 = r.matched(0);
		t.stringEquals("test@host", m0, "matched 0 full");
		var m1 = r.matched(1);
		t.stringEquals("test", m1, "matched 1 group");
		var m2 = r.matched(2);
		t.stringEquals("host", m2, "matched 2 group");

		var r2 = new EReg("[0-9]+", "");
		r2.match("abc123def");
		var m3 = r2.matched(0);
		t.stringEquals("123", m3, "matched digits");
	}

	function checkERegMatchedLeftRight() {
		var r = new EReg("[0-9]+", "");
		r.match("abc123def");
		var left1 = r.matchedLeft();
		t.stringEquals("abc", left1, "matchedLeft");
		var right1 = r.matchedRight();
		t.stringEquals("def", right1, "matchedRight");

		var r2 = new EReg("[a-z]+", "");
		r2.match("hello123");
		var left2 = r2.matchedLeft();
		t.stringEquals("", left2, "matchedLeft at start");
		var right2 = r2.matchedRight();
		t.stringEquals("123", right2, "matchedRight at start");

		var r3 = new EReg("[0-9]+", "");
		r3.match("abc456");
		var left3 = r3.matchedLeft();
		t.stringEquals("abc", left3, "matchedLeft at end");
		var right3 = r3.matchedRight();
		t.stringEquals("", right3, "matchedRight at end");
	}

	function checkERegMatchedPos() {
		var r = new EReg("[0-9]+", "");
		r.match("abc123def");
		var p = r.matchedPos();
		t.intEquals(3, p.pos, "matchedPos pos");
		t.intEquals(3, p.len, "matchedPos len");

		var r2 = new EReg("hello", "");
		r2.match("hello world");
		var p2 = r2.matchedPos();
		t.intEquals(0, p2.pos, "matchedPos start pos");
		t.intEquals(5, p2.len, "matchedPos start len");
	}

	function checkERegMatchSub() {
		var r = new EReg("[0-9]+", "");
		var ms1 = r.matchSub("abc123def456", 4);
		t.isTrue(ms1, "matchSub from 4");
		var mt1 = r.matched(0);
		t.stringEquals("23", mt1, "matchSub matched text");
		var mpos = r.matchedPos();
		t.intEquals(4, mpos.pos, "matchSub pos");

		var r2 = new EReg("[0-9]+", "");
		var ms2 = r2.matchSub("abc123def456", 0, 3);
		t.isFalse(ms2, "matchSub len 3 no match");

		var r3 = new EReg("[0-9]+", "");
		var ms3 = r3.matchSub("abcdef", 0);
		t.isFalse(ms3, "matchSub no digits");
	}

	function checkERegSplit() {
		var r = new EReg("[,]", "");
		var parts = r.split("a,b,c");
		t.intEquals(2, parts.length, "split non-global length");
		t.stringEquals("a", parts[0], "split 0");
		t.stringEquals("b,c", parts[1], "split 1 remainder");

		var rg = new EReg("[,]", "g");
		var partsG = rg.split("a,b,c");
		t.intEquals(3, partsG.length, "split global length");
		t.stringEquals("a", partsG[0], "split g 0");
		t.stringEquals("b", partsG[1], "split g 1");
		t.stringEquals("c", partsG[2], "split g 2");

		var r2 = new EReg("[,]", "");
		var parts2 = r2.split("abc");
		t.intEquals(1, parts2.length, "split no match length");
		t.stringEquals("abc", parts2[0], "split no match value");
	}

	function checkERegReplace() {
		var r = new EReg("world", "i");
		var rr1 = r.replace("Hello World World", "Earth");
		t.stringEquals("Hello Earth World", rr1, "replace first");

		var rg = new EReg("o", "g");
		var rr2 = rg.replace("foo boo", "0");
		t.stringEquals("f00 b00", rr2, "replace global");

		var r2 = new EReg("xyz", "");
		var rr3 = r2.replace("hello", "world");
		t.stringEquals("hello", rr3, "replace no match");

		var r3 = new EReg("([a-z]+)=([a-z0-9]+)", "g");
		var rr4 = r3.replace("a=1 b=2", "$2=$1");
		t.stringEquals("1=a 2=b", rr4, "replace with groups");
	}

	function checkERegMap() {
		var r = new EReg("[0-9]+", "");
		var result = r.map("abc123def456", function(re:EReg):String {
			var mt = re.matched(0);
			return "[" + mt + "]";
		});
		t.stringEquals("abc[123]def456", result, "map first match");

		var rg = new EReg("[0-9]+", "g");
		var resultG = rg.map("abc123def456", function(re:EReg):String {
			var mt = re.matched(0);
			return "[" + mt + "]";
		});
		t.stringEquals("abc[123]def[456]", resultG, "map global");

		var r2 = new EReg("[0-9]+", "");
		var result2 = r2.map("abcdef", function(re:EReg):String {
			return "X";
		});
		t.stringEquals("abcdef", result2, "map no match");
	}

	function checkERegEscape() {
		var e1 = EReg.escape("hello.world");
		var e1Len = e1.length;
		var lenOk = e1Len > 11;
		t.isTrue(lenOk, "escape dot adds backslash");

		var pattern = EReg.escape("1+1=2");
		var r = new EReg(pattern, "");
		var m1 = r.match("does 1+1=2 work");
		t.isTrue(m1, "escaped pattern matches literal");
		var m2 = r.match("does 111112 work");
		t.isFalse(m2, "escaped pattern no meta match");
	}
}
