package;

import utest.Assert;

class TimerTests extends utest.Test {
	function testStamp() {
		var s = haxe.Timer.stamp();
		Assert.isTrue(s >= 0);
	}

	function testStampIncreasing() {
		var s1 = haxe.Timer.stamp();
		var s2 = haxe.Timer.stamp();
		Assert.isTrue(s2 >= s1);
	}

	function testDelay() {
		haxe.Timer.delay(function() {
			trace("delay fired");
		}, 1);
		Assert.isTrue(true);
	}

	function testMeasure() {
		var result = haxe.Timer.measure(function() {
			return 42;
		});
		Assert.equals(42, result);
	}

	function testNewStop() {
		var timer = new haxe.Timer(100);
		timer.stop();
		Assert.isTrue(true);
	}
}
