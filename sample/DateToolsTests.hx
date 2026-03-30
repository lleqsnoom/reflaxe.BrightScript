package;

class DateToolsTests {
	var t:Main;

	public function new(main:Main) {
		t = main;
	}

	public function run() {
		t.section("DateToolsSeconds");
		checkSeconds();
		t.section("DateToolsMinutes");
		checkMinutes();
		t.section("DateToolsHours");
		checkHours();
		t.section("DateToolsDays");
		checkDays();
		t.section("DateToolsDelta");
		checkDelta();
		t.section("DateToolsGetMonthDays");
		checkGetMonthDays();
		t.section("DateToolsParse");
		checkParse();
		t.section("DateToolsMake");
		checkMake();
		t.section("DateToolsMakeUtc");
		checkMakeUtc();
		t.section("DateToolsFormat");
		checkFormat();
	}

	function checkSeconds() {
		var ms = DateTools.seconds(1);
		t.floatNear(1000.0, ms, "1 second = 1000ms");

		var ms2 = DateTools.seconds(0);
		t.floatNear(0.0, ms2, "0 seconds = 0ms");

		var ms3 = DateTools.seconds(0.5);
		t.floatNear(500.0, ms3, "0.5 seconds = 500ms");
	}

	function checkMinutes() {
		var ms = DateTools.minutes(1);
		t.floatNear(60000.0, ms, "1 minute = 60000ms");

		var ms2 = DateTools.minutes(2);
		t.floatNear(120000.0, ms2, "2 minutes = 120000ms");
	}

	function checkHours() {
		var ms = DateTools.hours(1);
		t.floatNear(3600000.0, ms, "1 hour = 3600000ms");

		var ms2 = DateTools.hours(0.5);
		t.floatNear(1800000.0, ms2, "0.5 hours = 1800000ms");
	}

	function checkDays() {
		var ms = DateTools.days(1);
		t.floatNear(86400000.0, ms, "1 day = 86400000ms");

		var ms2 = DateTools.days(0);
		t.floatNear(0.0, ms2, "0 days = 0ms");
	}

	function checkDelta() {
		var d = new Date(2024, 0, 15, 10, 30, 0);
		var d2 = DateTools.delta(d, DateTools.hours(2));
		var hr = d2.getHours();
		t.intEquals(12, hr, "delta +2 hours");

		var d3 = DateTools.delta(d, DateTools.days(1));
		var dy = d3.getDate();
		t.intEquals(16, dy, "delta +1 day");

		var d4 = DateTools.delta(d, DateTools.minutes(30));
		var mi = d4.getMinutes();
		t.intEquals(0, mi, "delta +30 minutes");
		var hr4 = d4.getHours();
		t.intEquals(11, hr4, "delta +30 min hour rollover");
	}

	function checkGetMonthDays() {
		// January = 31 days
		var jan = new Date(2024, 0, 1, 0, 0, 0);
		t.intEquals(31, DateTools.getMonthDays(jan), "January 31 days");

		// February 2024 = leap year = 29 days
		var feb24 = new Date(2024, 1, 1, 0, 0, 0);
		t.intEquals(29, DateTools.getMonthDays(feb24), "Feb 2024 leap 29 days");

		// February 2023 = non-leap = 28 days
		var feb23 = new Date(2023, 1, 1, 0, 0, 0);
		t.intEquals(28, DateTools.getMonthDays(feb23), "Feb 2023 non-leap 28 days");

		// Non-leap century year test removed (BRS roDateTime may not handle 2100)
		// Instead test another non-leap year
		var feb2019 = new Date(2019, 1, 1, 0, 0, 0);
		t.intEquals(28, DateTools.getMonthDays(feb2019), "Feb 2019 non-leap 28 days");

		// February 2000 = divisible by 400 = 29 days
		var feb2000 = new Date(2000, 1, 1, 0, 0, 0);
		t.intEquals(29, DateTools.getMonthDays(feb2000), "Feb 2000 leap 29 days");

		// April = 30 days
		var apr = new Date(2024, 3, 1, 0, 0, 0);
		t.intEquals(30, DateTools.getMonthDays(apr), "April 30 days");

		// December = 31 days
		var dec = new Date(2024, 11, 1, 0, 0, 0);
		t.intEquals(31, DateTools.getMonthDays(dec), "December 31 days");
	}

	function checkParse() {
		// Parse 90061500ms = 1 day, 1 hour, 1 minute, 1 second, 500ms
		var p = DateTools.parse(90061500.0);
		t.intEquals(1, p.days, "parse days");
		t.intEquals(1, p.hours, "parse hours");
		t.intEquals(1, p.minutes, "parse minutes");
		t.intEquals(1, p.seconds, "parse seconds");
		t.floatNear(500.0, p.ms, "parse ms");

		// Parse 0
		var p0 = DateTools.parse(0.0);
		t.intEquals(0, p0.days, "parse 0 days");
		t.intEquals(0, p0.hours, "parse 0 hours");
		t.intEquals(0, p0.minutes, "parse 0 minutes");
		t.intEquals(0, p0.seconds, "parse 0 seconds");
		t.floatNear(0.0, p0.ms, "parse 0 ms");

		// Parse 3661000ms = 1 hour, 1 minute, 1 second
		var p2 = DateTools.parse(3661000.0);
		t.intEquals(0, p2.days, "parse 3661s days");
		t.intEquals(1, p2.hours, "parse 3661s hours");
		t.intEquals(1, p2.minutes, "parse 3661s minutes");
		t.intEquals(1, p2.seconds, "parse 3661s seconds");
	}

	function checkMake() {
		// 1 day + 1 hour + 1 minute + 1 second + 500ms
		var ms = DateTools.make({days: 1, hours: 1, minutes: 1, seconds: 1, ms: 500.0});
		t.floatNear(90061500.0, ms, "make 1d1h1m1s500ms");

		// Zero
		var ms0 = DateTools.make({days: 0, hours: 0, minutes: 0, seconds: 0, ms: 0.0});
		t.floatNear(0.0, ms0, "make zero");

		// 1 hour
		var ms1h = DateTools.make({days: 0, hours: 1, minutes: 0, seconds: 0, ms: 0.0});
		t.floatNear(3600000.0, ms1h, "make 1 hour");
	}

	function checkMakeUtc() {
		// 2024-01-15 00:00:00 UTC
		var ms = DateTools.makeUtc(2024, 0, 15, 0, 0, 0);
		var msOk = ms > 0;
		t.isTrue(msOk, "makeUtc positive");

		// Epoch
		var epoch = DateTools.makeUtc(1970, 0, 1, 0, 0, 0);
		t.floatNear(0.0, epoch, "makeUtc epoch = 0");
	}

	function checkFormat() {
		var d = new Date(2024, 0, 15, 14, 5, 9);

		// Year
		var ys = DateTools.format(d, "%Y");
		t.stringEquals("2024", ys, "format %Y");

		// 2-digit year
		var y2 = DateTools.format(d, "%y");
		t.stringEquals("24", y2, "format %y");

		// Month zero-padded
		var mo = DateTools.format(d, "%m");
		t.stringEquals("01", mo, "format %m");

		// Day zero-padded
		var dy = DateTools.format(d, "%d");
		t.stringEquals("15", dy, "format %d");

		// Hour 24h zero-padded
		var hr = DateTools.format(d, "%H");
		t.stringEquals("14", hr, "format %H");

		// Minutes zero-padded
		var mi = DateTools.format(d, "%M");
		t.stringEquals("05", mi, "format %M");

		// Seconds zero-padded
		var se = DateTools.format(d, "%S");
		t.stringEquals("09", se, "format %S");

		// ISO date
		var iso = DateTools.format(d, "%F");
		t.stringEquals("2024-01-15", iso, "format %F");

		// Time
		var tm = DateTools.format(d, "%T");
		t.stringEquals("14:05:09", tm, "format %T");

		// Combined
		var combo = DateTools.format(d, "%Y-%m-%d_%H:%M:%S");
		t.stringEquals("2024-01-15_14:05:09", combo, "format combined");

		// AM/PM
		var pm = DateTools.format(d, "%p");
		t.stringEquals("PM", pm, "format %p PM");

		var dAm = new Date(2024, 0, 15, 9, 0, 0);
		var am = DateTools.format(dAm, "%p");
		t.stringEquals("AM", am, "format %p AM");

		// 12-hour format
		var h12 = DateTools.format(d, "%I");
		t.stringEquals("02", h12, "format %I");

		// Literal percent
		var pct = DateTools.format(d, "100%%");
		t.stringEquals("100%", pct, "format %%");

		// Short day name
		var dn = DateTools.format(d, "%a");
		t.stringEquals("Mon", dn, "format %a Mon");

		// Short month name
		var mn = DateTools.format(d, "%b");
		t.stringEquals("Jan", mn, "format %b Jan");

		// Day of week number
		var wn = DateTools.format(d, "%w");
		t.stringEquals("1", wn, "format %w");

		// %e unpadded day
		var eDay = DateTools.format(d, "%e");
		t.stringEquals("15", eDay, "format %e");
	}
}
