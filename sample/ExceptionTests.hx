package;

class ExceptionTests {
	var t:Main;

	public function new(main:Main) {
		t = main;
	}

	public function run() {
		t.section("ExceptionBasic");
		checkBasic();
		t.section("ExceptionMessage");
		checkMessage();
		t.section("ExceptionToString");
		checkToString();
		t.section("ExceptionDetails");
		checkDetails();
		t.section("ExceptionCatchTyped");
		checkCatchTyped();
		t.section("ExceptionCatchString");
		checkCatchString();
		t.section("ExceptionCatchInt");
		checkCatchInt();
		t.section("ExceptionRethrow");
		checkRethrow();
		t.section("ExceptionDynamic");
		checkDynamic();
	}

	function checkBasic() {
		var caught = false;
		try {
			throw new haxe.Exception("test error");
		} catch (e:Dynamic) {
			caught = true;
		}
		t.isTrue(caught, "Exception thrown and caught");
	}

	function checkMessage() {
		var msg = "";
		try {
			throw new haxe.Exception("hello world");
		} catch (error:haxe.Exception) {
			msg = error.message;
		}
		t.stringEquals("hello world", msg, "Exception.message");
	}

	function checkToString() {
		var str = "";
		try {
			throw new haxe.Exception("test msg");
		} catch (e:haxe.Exception) {
			str = e.toString();
		}
		t.stringEquals("test msg", str, "Exception.toString()");
	}

	function checkDetails() {
		var det = "";
		try {
			throw new haxe.Exception("detail test");
		} catch (e:haxe.Exception) {
			det = e.details();
		}
		t.stringEquals("detail test", det, "Exception.details() without previous");
	}

	function checkCatchTyped() {
		var msg = "";
		try {
			throw new haxe.Exception("typed catch");
		} catch (e:haxe.Exception) {
			msg = e.message;
		}
		t.stringEquals("typed catch", msg, "catch (e:haxe.Exception)");
	}

	function checkCatchString() {
		var caught = false;
		try {
			throw "string error";
		} catch (e:Dynamic) {
			caught = true;
		}
		t.isTrue(caught, "catch string as Dynamic");
	}

	function checkCatchInt() {
		var caught = false;
		try {
			throw 42;
		} catch (e:Dynamic) {
			caught = true;
		}
		t.isTrue(caught, "catch int as Dynamic");
	}

	function checkRethrow() {
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
		t.stringEquals("rethrown", msg, "rethrown exception message");
	}

	function checkDynamic() {
		var msg = "";
		try {
			throw "dynamic error";
		} catch (e:Dynamic) {
			msg = Std.string(e);
		}
		var hasContent = msg.length > 0;
		t.isTrue(hasContent, "dynamic catch has content");
	}
}
