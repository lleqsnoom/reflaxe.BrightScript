package;

import utest.Assert;

class ERegTests extends utest.Test {
	function testERegMatch() {
		var r = new EReg("world", "i");
		Assert.isTrue(r.match("Hello World"));
		Assert.isFalse(r.match("Hello"));

		var r2 = new EReg("[0-9]+", "");
		Assert.isTrue(r2.match("abc123def"));
		Assert.isFalse(r2.match("abcdef"));

		var r3 = new EReg(".", "");
		Assert.isFalse(r3.match(""));
	}

	function testERegMatched() {
		var r = new EReg("([a-z]+)@([a-z]+)", "");
		r.match("test@host.com");
		Assert.equals("test@host", r.matched(0));
		Assert.equals("test", r.matched(1));
		Assert.equals("host", r.matched(2));

		var r2 = new EReg("[0-9]+", "");
		r2.match("abc123def");
		Assert.equals("123", r2.matched(0));
	}

	function testERegMatchedLeftRight() {
		var r = new EReg("[0-9]+", "");
		r.match("abc123def");
		Assert.equals("abc", r.matchedLeft());
		Assert.equals("def", r.matchedRight());

		var r2 = new EReg("[a-z]+", "");
		r2.match("hello123");
		Assert.equals("", r2.matchedLeft());
		Assert.equals("123", r2.matchedRight());

		var r3 = new EReg("[0-9]+", "");
		r3.match("abc456");
		Assert.equals("abc", r3.matchedLeft());
		Assert.equals("", r3.matchedRight());
	}

	function testERegMatchedPos() {
		var r = new EReg("[0-9]+", "");
		r.match("abc123def");
		var p = r.matchedPos();
		Assert.equals(3, p.pos);
		Assert.equals(3, p.len);

		var r2 = new EReg("hello", "");
		r2.match("hello world");
		var p2 = r2.matchedPos();
		Assert.equals(0, p2.pos);
		Assert.equals(5, p2.len);
	}

	function testERegMatchSub() {
		var r = new EReg("[0-9]+", "");
		Assert.isTrue(r.matchSub("abc123def456", 4));
		Assert.equals("23", r.matched(0));
		var mpos = r.matchedPos();
		Assert.equals(4, mpos.pos);

		var r2 = new EReg("[0-9]+", "");
		Assert.isFalse(r2.matchSub("abc123def456", 0, 3));

		var r3 = new EReg("[0-9]+", "");
		Assert.isFalse(r3.matchSub("abcdef", 0));
	}

	function testERegSplit() {
		var r = new EReg("[,]", "");
		var parts = r.split("a,b,c");
		Assert.equals(2, parts.length);
		Assert.equals("a", parts[0]);
		Assert.equals("b,c", parts[1]);

		var rg = new EReg("[,]", "g");
		var partsG = rg.split("a,b,c");
		Assert.equals(3, partsG.length);
		Assert.equals("a", partsG[0]);
		Assert.equals("b", partsG[1]);
		Assert.equals("c", partsG[2]);

		var r2 = new EReg("[,]", "");
		var parts2 = r2.split("abc");
		Assert.equals(1, parts2.length);
		Assert.equals("abc", parts2[0]);
	}

	function testERegReplace() {
		var r = new EReg("world", "i");
		Assert.equals("Hello Earth World", r.replace("Hello World World", "Earth"));

		var rg = new EReg("o", "g");
		Assert.equals("f00 b00", rg.replace("foo boo", "0"));

		var r2 = new EReg("xyz", "");
		Assert.equals("hello", r2.replace("hello", "world"));

		var r3 = new EReg("([a-z]+)=([a-z0-9]+)", "g");
		Assert.equals("1=a 2=b", r3.replace("a=1 b=2", "$2=$1"));
	}

	function testERegMap() {
		var r = new EReg("[0-9]+", "");
		var result = r.map("abc123def456", function(re:EReg):String {
			return "[" + re.matched(0) + "]";
		});
		Assert.equals("abc[123]def456", result);

		var rg = new EReg("[0-9]+", "g");
		var resultG = rg.map("abc123def456", function(re:EReg):String {
			return "[" + re.matched(0) + "]";
		});
		Assert.equals("abc[123]def[456]", resultG);

		var r2 = new EReg("[0-9]+", "");
		var result2 = r2.map("abcdef", function(re:EReg):String {
			return "X";
		});
		Assert.equals("abcdef", result2);
	}

	function testERegEscape() {
		var e1 = EReg.escape("hello.world");
		Assert.isTrue(e1.length > 11);

		var pattern = EReg.escape("1+1=2");
		var r = new EReg(pattern, "");
		Assert.isTrue(r.match("does 1+1=2 work"));
		Assert.isFalse(r.match("does 111112 work"));
	}
}
