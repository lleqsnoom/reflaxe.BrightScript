package;

import utest.Assert;

class ExceptionTests extends utest.Test {
	function testBasic() {
		var caught = false;
		try {
			throw new haxe.Exception("test error");
		} catch (e:Dynamic) {
			caught = true;
		}
		Assert.isTrue(caught);
	}

	function testMessage() {
		var msg = "";
		try {
			throw new haxe.Exception("hello world");
		} catch (e:haxe.Exception) {
			msg = e.message;
		}
		Assert.equals("hello world", msg);
	}

	function testToString() {
		var str = "";
		try {
			throw new haxe.Exception("test msg");
		} catch (e:haxe.Exception) {
			str = e.toString();
		}
		Assert.equals("test msg", str);
	}

	function testDetails() {
		var det = "";
		try {
			throw new haxe.Exception("detail test");
		} catch (e:haxe.Exception) {
			det = e.details();
		}
		Assert.equals("detail test", det);
	}

	function testCatchTyped() {
		var msg = "";
		try {
			throw new haxe.Exception("typed catch");
		} catch (e:haxe.Exception) {
			msg = e.message;
		}
		Assert.equals("typed catch", msg);
	}

	function testCatchString() {
		var caught = false;
		try {
			throw "string error";
		} catch (e:Dynamic) {
			caught = true;
		}
		Assert.isTrue(caught);
	}

	function testCatchInt() {
		var caught = false;
		try {
			throw 42;
		} catch (e:Dynamic) {
			caught = true;
		}
		Assert.isTrue(caught);
	}

	function testRethrow() {
		var msg = "";
		try {
			try {
				throw new haxe.Exception("rethrown");
			} catch (e:haxe.Exception) {
				throw e;
			}
		} catch (e2:haxe.Exception) {
			msg = e2.message;
		}
		Assert.equals("rethrown", msg);
	}

	function testDynamic() {
		var msg = "";
		try {
			throw "dynamic error";
		} catch (e:Dynamic) {
			msg = Std.string(e);
		}
		Assert.isTrue(msg.length > 0);
	}
}
