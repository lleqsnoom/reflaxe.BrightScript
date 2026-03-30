package;

import utest.Assert;

class DateTests extends utest.Test {
	function testDateConstructor() {
		var d = new Date(2024, 0, 15, 10, 30, 45);
		Assert.equals(2024, d.getFullYear());
		Assert.equals(0, d.getMonth());
		Assert.equals(15, d.getDate());
		Assert.equals(10, d.getHours());
		Assert.equals(30, d.getMinutes());
		Assert.equals(45, d.getSeconds());

		var d2 = new Date(2023, 5, 25, 18, 5, 30);
		Assert.equals(2023, d2.getFullYear());
		Assert.equals(5, d2.getMonth());
		Assert.equals(25, d2.getDate());
		Assert.equals(18, d2.getHours());
		Assert.equals(5, d2.getMinutes());
		Assert.equals(30, d2.getSeconds());
	}

	function testDateNow() {
		var d = Date.now();
		var yr = d.getFullYear();
		Assert.isTrue(yr >= 2020);
		var tm = d.getTime();
		Assert.isTrue(tm > 0);
		var dy = d.getDay();
		Assert.isTrue(dy >= 0);
	}

	function testDateFromTime() {
		var epoch = Date.fromTime(0);
		Assert.floatEquals(0.0, epoch.getTime());

		var d2 = Date.fromTime(86400000.0);
		Assert.floatEquals(86400000.0, d2.getTime());

		var d3 = Date.fromTime(1705312245000.0);
		Assert.equals(2024, d3.getFullYear());
	}

	function testDateFromString() {
		var d = Date.fromString("2024-01-15 10:30:45");
		Assert.equals(2024, d.getFullYear());
		Assert.equals(0, d.getMonth());
		Assert.equals(15, d.getDate());
		Assert.equals(10, d.getHours());
		Assert.equals(30, d.getMinutes());
		Assert.equals(45, d.getSeconds());

		var d2 = Date.fromString("2023-06-25");
		Assert.equals(2023, d2.getFullYear());
		Assert.equals(5, d2.getMonth());
		Assert.equals(25, d2.getDate());
		Assert.equals(0, d2.getHours());
	}

	function testDateGetTime() {
		var d1 = new Date(2024, 0, 15, 0, 0, 0);
		var d2 = new Date(2024, 0, 16, 0, 0, 0);
		Assert.isTrue(d2.getTime() > d1.getTime());

		var epoch = Date.fromTime(0);
		Assert.floatEquals(0.0, epoch.getTime());
		Assert.isTrue(d1.getTime() > 0);
	}

	function testDateToString() {
		var d = new Date(2024, 0, 15, 10, 30, 45);
		Assert.equals("2024-01-15 10:30:45", d.toString());

		var d2 = new Date(2024, 2, 5, 8, 5, 3);
		Assert.equals("2024-03-05 08:05:03", d2.toString());
	}
}
