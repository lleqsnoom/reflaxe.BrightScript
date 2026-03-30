package;

import utest.Assert;

class MathTests extends utest.Test {
	function testMathConstants() {
		Assert.floatEquals(3.14159265, Math.PI, 0.001);
	}

	function testMathBasic() {
		Assert.floatEquals(5.0, Math.abs(5), 0.001);
		Assert.floatEquals(3.7, Math.abs(-3.7), 0.001);
		Assert.floatEquals(0.0, Math.abs(0), 0.001);
		Assert.floatEquals(3.0, Math.sqrt(9), 0.001);
		Assert.floatEquals(1.41421, Math.sqrt(2), 0.001);
		Assert.floatEquals(0.0, Math.sqrt(0), 0.001);
		Assert.floatEquals(1024.0, Math.pow(2, 10), 0.001);
		Assert.floatEquals(1.0, Math.pow(3, 0), 0.001);
		Assert.floatEquals(0.5, Math.pow(2, -1), 0.001);
		Assert.floatEquals(1.0, Math.exp(0), 0.001);
		Assert.floatEquals(2.71828, Math.exp(1), 0.001);
		Assert.floatEquals(0.0, Math.log(1), 0.001);
	}

	function testMathRounding() {
		Assert.equals(2, Math.floor(2.7));
		Assert.equals(-3, Math.floor(-2.7));
		Assert.equals(3, Math.floor(3.0));
		Assert.equals(3, Math.ceil(2.3));
		Assert.equals(-2, Math.ceil(-2.3));
		Assert.equals(3, Math.ceil(3.0));
		Assert.equals(3, Math.round(2.5));
		Assert.equals(2, Math.round(2.4));
		Assert.equals(0, Math.round(-0.5));
		Assert.equals(-1, Math.round(-1.5));
		Assert.floatEquals(2.0, Math.ffloor(2.7), 0.001);
		Assert.floatEquals(3.0, Math.fceil(2.3), 0.001);
		Assert.floatEquals(3.0, Math.fround(2.5), 0.001);
	}

	function testMathTrig() {
		Assert.floatEquals(0.0, Math.sin(0), 0.001);
		Assert.floatEquals(1.0, Math.cos(0), 0.001);
		Assert.floatEquals(0.0, Math.tan(0), 0.001);
		Assert.floatEquals(0.78539, Math.atan(1), 0.001);
		Assert.floatEquals(1.5707963, Math.asin(1), 0.001);
		Assert.floatEquals(0.0, Math.acos(1), 0.001);
		Assert.floatEquals(1.5707963, Math.acos(0), 0.001);
		Assert.floatEquals(1.5707963, Math.atan2(1, 0), 0.001);
		Assert.floatEquals(0.0, Math.atan2(0, 1), 0.001);
		Assert.floatEquals(0.78539, Math.atan2(1, 1), 0.001);
		Assert.floatEquals(-1.5707963, Math.atan2(-1, 0), 0.001);
	}

	function testMathMinMax() {
		Assert.floatEquals(7.0, Math.max(3, 7), 0.001);
		Assert.floatEquals(-1.0, Math.max(-1, -5), 0.001);
		Assert.floatEquals(3.0, Math.max(3, 3), 0.001);
		Assert.floatEquals(3.0, Math.min(3, 7), 0.001);
		Assert.floatEquals(-5.0, Math.min(-1, -5), 0.001);
		Assert.floatEquals(3.0, Math.min(3, 3), 0.001);
	}

	function testMathRandom() {
		var r = Math.random();
		Assert.isTrue(r >= 0.0);
		Assert.isTrue(r < 1.0);
	}
}
