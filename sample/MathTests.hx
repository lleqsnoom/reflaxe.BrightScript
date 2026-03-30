package;

class MathTests {
	var t:Main;

	public function new(main:Main) {
		t = main;
	}

	public function run() {
		t.section("MathConstants");
		checkMathConstants();
		t.section("MathBasic");
		checkMathBasic();
		t.section("MathRounding");
		checkMathRounding();
		t.section("MathTrig");
		checkMathTrig();
		t.section("MathMinMax");
		checkMathMinMax();
		t.section("MathRandom");
		checkMathRandom();
	}

	function checkMathConstants() {
		t.floatNear(3.14159265, Math.PI, "PI");
	}

	function checkMathBasic() {
		var v1 = Math.abs(5);
		t.floatNear(5.0, v1, "abs(5)");
		var v2 = Math.abs(-3.7);
		t.floatNear(3.7, v2, "abs(-3.7)");
		var v3 = Math.abs(0);
		t.floatNear(0.0, v3, "abs(0)");
		var v4 = Math.sqrt(9);
		t.floatNear(3.0, v4, "sqrt(9)");
		var v5 = Math.sqrt(2);
		t.floatNear(1.41421, v5, "sqrt(2)");
		var v6 = Math.sqrt(0);
		t.floatNear(0.0, v6, "sqrt(0)");
		var v7 = Math.pow(2, 10);
		t.floatNear(1024.0, v7, "pow(2,10)");
		var v8 = Math.pow(3, 0);
		t.floatNear(1.0, v8, "pow(3,0)");
		var v9 = Math.pow(2, -1);
		t.floatNear(0.5, v9, "pow(2,-1)");
		var v10 = Math.exp(0);
		t.floatNear(1.0, v10, "exp(0)");
		var v11 = Math.exp(1);
		t.floatNear(2.71828, v11, "exp(1)");
		var v12 = Math.log(1);
		t.floatNear(0.0, v12, "log(1)");
	}

	function checkMathRounding() {
		var v1 = Math.floor(2.7);
		t.intEquals(2, v1, "floor(2.7)");
		var v2 = Math.floor(-2.7);
		t.intEquals(-3, v2, "floor(-2.7)");
		var v3 = Math.floor(3.0);
		t.intEquals(3, v3, "floor(3.0)");
		var v4 = Math.ceil(2.3);
		t.intEquals(3, v4, "ceil(2.3)");
		var v5 = Math.ceil(-2.3);
		t.intEquals(-2, v5, "ceil(-2.3)");
		var v6 = Math.ceil(3.0);
		t.intEquals(3, v6, "ceil(3.0)");
		var v7 = Math.round(2.5);
		t.intEquals(3, v7, "round(2.5)");
		var v8 = Math.round(2.4);
		t.intEquals(2, v8, "round(2.4)");
		var v9 = Math.round(-0.5);
		t.intEquals(0, v9, "round(-0.5)");
		var v10 = Math.round(-1.5);
		t.intEquals(-1, v10, "round(-1.5)");
		var v11 = Math.ffloor(2.7);
		t.floatNear(2.0, v11, "ffloor(2.7)");
		var v12 = Math.fceil(2.3);
		t.floatNear(3.0, v12, "fceil(2.3)");
		var v13 = Math.fround(2.5);
		t.floatNear(3.0, v13, "fround(2.5)");
	}

	function checkMathTrig() {
		var v1 = Math.sin(0);
		t.floatNear(0.0, v1, "sin(0)");
		var v2 = Math.cos(0);
		t.floatNear(1.0, v2, "cos(0)");
		var v3 = Math.tan(0);
		t.floatNear(0.0, v3, "tan(0)");
		var v4 = Math.atan(1);
		t.floatNear(0.78539, v4, "atan(1)");
		var v5 = Math.asin(1);
		t.floatNear(1.5707963, v5, "asin(1)");
		var v6 = Math.acos(1);
		t.floatNear(0.0, v6, "acos(1)");
		var v7 = Math.acos(0);
		t.floatNear(1.5707963, v7, "acos(0)");
		var v8 = Math.atan2(1, 0);
		t.floatNear(1.5707963, v8, "atan2(1,0)");
		var v9 = Math.atan2(0, 1);
		t.floatNear(0.0, v9, "atan2(0,1)");
		var v10 = Math.atan2(1, 1);
		t.floatNear(0.78539, v10, "atan2(1,1)");
		var v11 = Math.atan2(-1, 0);
		t.floatNear(-1.5707963, v11, "atan2(-1,0)");
	}

	function checkMathMinMax() {
		var v1 = Math.max(3, 7);
		t.floatNear(7.0, v1, "max(3,7)");
		var v2 = Math.max(-1, -5);
		t.floatNear(-1.0, v2, "max(-1,-5)");
		var v3 = Math.max(3, 3);
		t.floatNear(3.0, v3, "max(3,3)");
		var v4 = Math.min(3, 7);
		t.floatNear(3.0, v4, "min(3,7)");
		var v5 = Math.min(-1, -5);
		t.floatNear(-5.0, v5, "min(-1,-5)");
		var v6 = Math.min(3, 3);
		t.floatNear(3.0, v6, "min(3,3)");
	}

	function checkMathRandom() {
		var r = Math.random();
		var ok1 = r >= 0.0;
		t.isTrue(ok1, "random >= 0");
		var ok2 = r < 1.0;
		t.isTrue(ok2, "random < 1");
	}
}
