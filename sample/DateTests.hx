package;

class DateTests {
	var t:Main;

	public function new(main:Main) {
		t = main;
	}

	public function run() {
		t.section("DateConstructor");
		checkDateConstructor();
		t.section("DateNow");
		checkDateNow();
		t.section("DateFromTime");
		checkDateFromTime();
		t.section("DateFromString");
		checkDateFromString();
		t.section("DateGetTime");
		checkDateGetTime();
		t.section("DateToString");
		checkDateToString();
	}

	function checkDateConstructor() {
		var d = new Date(2024, 0, 15, 10, 30, 45);
		var yr = d.getFullYear();
		t.intEquals(2024, yr, "year");
		var mo = d.getMonth();
		t.intEquals(0, mo, "month");
		var dy = d.getDate();
		t.intEquals(15, dy, "day");
		var hr = d.getHours();
		t.intEquals(10, hr, "hours");
		var mn = d.getMinutes();
		t.intEquals(30, mn, "minutes");
		var sc = d.getSeconds();
		t.intEquals(45, sc, "seconds");

		var d2 = new Date(2023, 5, 25, 18, 5, 30);
		var yr2 = d2.getFullYear();
		t.intEquals(2023, yr2, "year2");
		var mo2 = d2.getMonth();
		t.intEquals(5, mo2, "month2");
		var dy2 = d2.getDate();
		t.intEquals(25, dy2, "day2");
		var hr2 = d2.getHours();
		t.intEquals(18, hr2, "hours2");
		var mn2 = d2.getMinutes();
		t.intEquals(5, mn2, "minutes2");
		var sc2 = d2.getSeconds();
		t.intEquals(30, sc2, "seconds2");
	}

	function checkDateNow() {
		var d = Date.now();
		var yr = d.getFullYear();
		var yrOk = yr >= 2020;
		t.isTrue(yrOk, "now year >= 2020");
		var tm = d.getTime();
		var tOk = tm > 0;
		t.isTrue(tOk, "now getTime > 0");
		var dy = d.getDay();
		var dyOk = dy >= 0;
		t.isTrue(dyOk, "now getDay >= 0");
	}

	function checkDateFromTime() {
		var epoch = Date.fromTime(0);
		var t1 = epoch.getTime();
		t.floatNear(0.0, t1, "epoch getTime = 0");

		var d2 = Date.fromTime(86400000.0);
		var t2 = d2.getTime();
		t.floatNear(86400000.0, t2, "fromTime 86400000");

		var d3 = Date.fromTime(1705312245000.0);
		var yr3 = d3.getFullYear();
		t.intEquals(2024, yr3, "fromTime year 2024");
	}

	function checkDateFromString() {
		var d = Date.fromString("2024-01-15 10:30:45");
		var yr = d.getFullYear();
		t.intEquals(2024, yr, "fromString year");
		var mo = d.getMonth();
		t.intEquals(0, mo, "fromString month");
		var dy = d.getDate();
		t.intEquals(15, dy, "fromString day");
		var hr = d.getHours();
		t.intEquals(10, hr, "fromString hours");
		var mn = d.getMinutes();
		t.intEquals(30, mn, "fromString minutes");
		var sc = d.getSeconds();
		t.intEquals(45, sc, "fromString seconds");

		var d2 = Date.fromString("2023-06-25");
		var yr2 = d2.getFullYear();
		t.intEquals(2023, yr2, "date-only year");
		var mo2 = d2.getMonth();
		t.intEquals(5, mo2, "date-only month");
		var dy2 = d2.getDate();
		t.intEquals(25, dy2, "date-only day");
		var hr2 = d2.getHours();
		t.intEquals(0, hr2, "date-only hours");
	}

	function checkDateGetTime() {
		var d1 = new Date(2024, 0, 15, 0, 0, 0);
		var d2 = new Date(2024, 0, 16, 0, 0, 0);
		var t1 = d1.getTime();
		var t2 = d2.getTime();
		var t2Later = t2 > t1;
		t.isTrue(t2Later, "d2 later than d1");

		var epoch = Date.fromTime(0);
		var t3 = epoch.getTime();
		t.floatNear(0.0, t3, "epoch getTime = 0");
		var t1Ok = t1 > 0;
		t.isTrue(t1Ok, "getTime positive");
	}

	function checkDateToString() {
		var d = new Date(2024, 0, 15, 10, 30, 45);
		var s = d.toString();
		t.stringEquals("2024-01-15 10:30:45", s, "toString");

		var d2 = new Date(2024, 2, 5, 8, 5, 3);
		var s2 = d2.toString();
		t.stringEquals("2024-03-05 08:05:03", s2, "toString padded");
	}
}
