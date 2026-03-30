package;

class TimerTests {
	var t:Main;

	public function new(main:Main) {
		t = main;
	}

	public function run() {
		t.section("TimerStamp");
		checkStamp();
		t.section("TimerStampIncreasing");
		checkStampIncreasing();
		t.section("TimerDelay");
		checkDelay();
		t.section("TimerMeasure");
		checkMeasure();
		t.section("TimerNewStop");
		checkNewStop();
	}

	function checkStamp() {
		var s = haxe.Timer.stamp();
		var isNonNeg = s >= 0;
		t.isTrue(isNonNeg, "stamp returns non-negative");
	}

	function checkStampIncreasing() {
		var s1 = haxe.Timer.stamp();
		var s2 = haxe.Timer.stamp();
		var ok = s2 >= s1;
		t.isTrue(ok, "second stamp >= first stamp");
	}

	function checkDelay() {
		// Blocking delay in BRS — just verify it completes
		haxe.Timer.delay(function() {
			trace("delay fired");
		}, 1);
		t.isTrue(true, "delay completes without error");
	}

	function checkMeasure() {
		var result = haxe.Timer.measure(function() {
			return 42;
		});
		t.intEquals(42, result, "measure returns function result");
	}

	function checkNewStop() {
		var timer = new haxe.Timer(100);
		timer.stop();
		t.isTrue(true, "new/stop completes without error");
	}
}
