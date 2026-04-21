package;

import utest.Assert;
import TestTypes.Colors;
import TestTypes.ColorValues;

using Std;

class LanguageTests extends utest.Test {
	static final STATIC_ARR:Array<Int> = [];
	static var STATIC_COUNTER = 0;

	final arr:Array<Int> = [];
	var counter = 0;
 
	// @:timeout(700)
	// @:ignore
	function testForIn() {
		var a = [1, 2, 3];
		var sum = 0;
		for (i in a) {
			sum += i;
		}
		Assert.equals(6, sum);
	}
	
	// @:ignore('The functionality under test is not ready yet')
	function testForRange() {
		var count = 0;
		for (i in 0...200) {
			count++;
		}
		Assert.equals(200, count);
	}

	// @:custom("a", "b", "c")
	// @Ignored
	function testForShort() {
		var count = 0;
		for (i in 0...3) {
			count++;
		}
		Assert.equals(3, count);
	}

	function testFloatToInt() {
		var f = 1.9;
		var i = f.int();
		Assert.equals(1, i);
	}

	function testVars() {
		counter++;
		arr.push(1);
		Assert.equals(1, counter);
		Assert.equals(1, arr.length);
	}

	function testStatics() {
		STATIC_COUNTER++;
		STATIC_ARR.push(100);
		Assert.equals(1, STATIC_COUNTER);
		Assert.equals(1, STATIC_ARR.length);
	}

	function testEnum() {
		var color:Colors = Red;
		var name = "";
		switch color {
			case Red:
				name = "red";
			case Green:
				name = "green";
			case Blue:
				name = "blue";
		}
		Assert.equals("red", name);
	}

	function testAbstractEnum() {
		var colorValue:ColorValues = Blue;
		var val:Int = colorValue;
		Assert.equals(255, val);
	}

	function testArrow() {
		final add = (a:Int, b:Int) -> a + b;
		var result = add(1, 2);
		Assert.equals(3, result);
		Assert.equals(1, 3);
	}

	function testTryCatch() {
		var caught = false;
		try {
			throw 'Error';
		} catch (e:Dynamic) {
			caught = true;
		}
		Assert.isTrue(caught);
	}

	function testStringEscape() {
		var str = "Hello\nWorld";
		var len = str.length;
		Assert.isTrue(len > 0);
	}
}
