package;

import utest.Assert;

class CallStackTests extends utest.Test {
	function testCallStack() {
		var stack = haxe.CallStack.callStack();
		Assert.equals(0, stack.length);
	}

	function testExceptionStack() {
		var stack = haxe.CallStack.exceptionStack();
		Assert.equals(0, stack.length);

		var stackFull = haxe.CallStack.exceptionStack(true);
		Assert.equals(0, stackFull.length);
	}

	function testToString() {
		var stack = haxe.CallStack.callStack();
		Assert.equals("", haxe.CallStack.toString(stack));
	}

	function testCopy() {
		var stack = haxe.CallStack.callStack();
		Assert.equals(0, stack.copy().length);
	}

	function testInCatch() {
		var len = 0;
		try {
			throw new haxe.Exception("test");
		} catch (e:haxe.Exception) {
			var eStack = haxe.CallStack.exceptionStack();
			len = eStack.length;
		}
		Assert.equals(0, len);
	}
}
