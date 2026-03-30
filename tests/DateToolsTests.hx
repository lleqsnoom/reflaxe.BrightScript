package;

import utest.Assert;

class DateToolsTests extends utest.Test {
	function testSeconds() {
		Assert.floatEquals(1000.0, DateTools.seconds(1));
		Assert.floatEquals(0.0, DateTools.seconds(0));
		Assert.floatEquals(500.0, DateTools.seconds(0.5));
	}

	function testMinutes() {
		Assert.floatEquals(60000.0, DateTools.minutes(1));
		Assert.floatEquals(120000.0, DateTools.minutes(2));
	}

	function testHours() {
		Assert.floatEquals(3600000.0, DateTools.hours(1));
		Assert.floatEquals(1800000.0, DateTools.hours(0.5));
	}

	function testDays() {
		Assert.floatEquals(86400000.0, DateTools.days(1));
		Assert.floatEquals(0.0, DateTools.days(0));
	}

	function testDelta() {
		var d = new Date(2024, 0, 15, 10, 30, 0);
		var d2 = DateTools.delta(d, DateTools.hours(2));
		Assert.equals(12, d2.getHours());

		var d3 = DateTools.delta(d, DateTools.days(1));
		Assert.equals(16, d3.getDate());

		var d4 = DateTools.delta(d, DateTools.minutes(30));
		Assert.equals(0, d4.getMinutes());
		Assert.equals(11, d4.getHours());
	}

	function testGetMonthDays() {
		var jan = new Date(2024, 0, 1, 0, 0, 0);
		Assert.equals(31, DateTools.getMonthDays(jan));

		var feb24 = new Date(2024, 1, 1, 0, 0, 0);
		Assert.equals(29, DateTools.getMonthDays(feb24));

		var feb23 = new Date(2023, 1, 1, 0, 0, 0);
		Assert.equals(28, DateTools.getMonthDays(feb23));

		var feb2019 = new Date(2019, 1, 1, 0, 0, 0);
		Assert.equals(28, DateTools.getMonthDays(feb2019));

		var feb2000 = new Date(2000, 1, 1, 0, 0, 0);
		Assert.equals(29, DateTools.getMonthDays(feb2000));

		var apr = new Date(2024, 3, 1, 0, 0, 0);
		Assert.equals(30, DateTools.getMonthDays(apr));

		var dec = new Date(2024, 11, 1, 0, 0, 0);
		Assert.equals(31, DateTools.getMonthDays(dec));
	}

	function testParse() {
		var p = DateTools.parse(90061500.0);
		Assert.equals(1, p.days);
		Assert.equals(1, p.hours);
		Assert.equals(1, p.minutes);
		Assert.equals(1, p.seconds);
		Assert.floatEquals(500.0, p.ms);

		var p0 = DateTools.parse(0.0);
		Assert.equals(0, p0.days);
		Assert.equals(0, p0.hours);
		Assert.equals(0, p0.minutes);
		Assert.equals(0, p0.seconds);
		Assert.floatEquals(0.0, p0.ms);

		var p2 = DateTools.parse(3661000.0);
		Assert.equals(0, p2.days);
		Assert.equals(1, p2.hours);
		Assert.equals(1, p2.minutes);
		Assert.equals(1, p2.seconds);
	}

	function testMake() {
		var ms = DateTools.make({days: 1, hours: 1, minutes: 1, seconds: 1, ms: 500.0});
		Assert.floatEquals(90061500.0, ms);

		var ms0 = DateTools.make({days: 0, hours: 0, minutes: 0, seconds: 0, ms: 0.0});
		Assert.floatEquals(0.0, ms0);

		var ms1h = DateTools.make({days: 0, hours: 1, minutes: 0, seconds: 0, ms: 0.0});
		Assert.floatEquals(3600000.0, ms1h);
	}

	function testMakeUtc() {
		var ms = DateTools.makeUtc(2024, 0, 15, 0, 0, 0);
		Assert.isTrue(ms > 0);

		var epoch = DateTools.makeUtc(1970, 0, 1, 0, 0, 0);
		Assert.floatEquals(0.0, epoch);
	}

	function testFormat() {
		var d = new Date(2024, 0, 15, 14, 5, 9);

		Assert.equals("2024", DateTools.format(d, "%Y"));
		Assert.equals("24", DateTools.format(d, "%y"));
		Assert.equals("01", DateTools.format(d, "%m"));
		Assert.equals("15", DateTools.format(d, "%d"));
		Assert.equals("14", DateTools.format(d, "%H"));
		Assert.equals("05", DateTools.format(d, "%M"));
		Assert.equals("09", DateTools.format(d, "%S"));
		Assert.equals("2024-01-15", DateTools.format(d, "%F"));
		Assert.equals("14:05:09", DateTools.format(d, "%T"));
		Assert.equals("2024-01-15_14:05:09", DateTools.format(d, "%Y-%m-%d_%H:%M:%S"));
		Assert.equals("PM", DateTools.format(d, "%p"));

		var dAm = new Date(2024, 0, 15, 9, 0, 0);
		Assert.equals("AM", DateTools.format(dAm, "%p"));

		Assert.equals("02", DateTools.format(d, "%I"));
		Assert.equals("100%", DateTools.format(d, "100%%"));
		Assert.equals("Mon", DateTools.format(d, "%a"));
		Assert.equals("Jan", DateTools.format(d, "%b"));
		Assert.equals("1", DateTools.format(d, "%w"));
		Assert.equals("15", DateTools.format(d, "%e"));
	}
}
