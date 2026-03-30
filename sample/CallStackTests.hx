package;

class CallStackTests {
	var t:Main;

	public function new(main:Main) {
		t = main;
	}

	public function run() {
		t.section("CallStackBasic");
		checkCallStack();
		t.section("CallStackException");
		checkExceptionStack();
		t.section("CallStackToString");
		checkToString();
		t.section("CallStackCopy");
		checkCopy();
		t.section("CallStackInCatch");
		checkInCatch();
	}

	function checkCallStack() {
		var stack = haxe.CallStack.callStack();
		t.intEquals(0, stack.length, "callStack() returns empty array");
	}

	function checkExceptionStack() {
		var stack = haxe.CallStack.exceptionStack();
		t.intEquals(0, stack.length, "exceptionStack() returns empty array");

		var stackFull = haxe.CallStack.exceptionStack(true);
		t.intEquals(0, stackFull.length, "exceptionStack(true) returns empty array");
	}

	function checkToString() {
		var stack = haxe.CallStack.callStack();
		var str = haxe.CallStack.toString(stack);
		t.stringEquals("", str, "toString() returns empty string");
	}

	function checkCopy() {
		var stack = haxe.CallStack.callStack();
		var cp = stack.copy();
		t.intEquals(0, cp.length, "copy() of empty stack is empty");
	}

	function checkInCatch() {
		var len = 0;
		try {
			throw new haxe.Exception("test");
		} catch (e:haxe.Exception) {
			var eStack = haxe.CallStack.exceptionStack();
			len = eStack.length;
		}
		t.intEquals(0, len, "exceptionStack() in catch is empty");
	}
}
