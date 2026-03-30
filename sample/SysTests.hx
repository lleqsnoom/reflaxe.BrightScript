package;

class SysTests {
	var t:Main;

	public function new(main:Main) {
		t = main;
	}

	public function run() {
		t.section("SysPrint");
		checkPrint();
		t.section("SysTime");
		checkTime();
		t.section("SysInfo");
		checkInfo();
		t.section("SysEnv");
		checkEnv();
	}

	function checkPrint() {
		// Sys.print should not crash — output goes to console
		Sys.print("hello");
		Sys.print(" ");
		Sys.println("world");
		t.isTrue(true, "print/println do not crash");
	}

	function checkTime() {
		var t1 = Sys.time();
		t.isTrue(t1 >= 0, "time() >= 0");

		var t2 = Sys.cpuTime();
		t.isTrue(t2 >= 0, "cpuTime() >= 0");
	}

	function checkInfo() {
		var name = Sys.systemName();
		t.stringEquals("BrightScript", name, "systemName()");

		var args = Sys.args();
		t.isTrue(args != null, "args() returns array");

		var path = Sys.programPath();
		t.isTrue(path != null, "programPath() returns string");
	}

	function checkEnv() {
		var env = Sys.getEnv("NONEXISTENT_VAR_12345");
		t.isTrue(env == null, "getEnv missing returns null");

		var envMap = Sys.environment();
		t.isTrue(envMap != null, "environment() returns map");
	}
}
