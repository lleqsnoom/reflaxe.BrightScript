package;

import Main.Colors;
import Main.ColorValues;

using Std;

class LanguageTests {
	var t:Main;

	static final STATIC_ARR:Array<Int> = [];
	static var STATIC_COUNTER = 0;

	final arr:Array<Int> = [];
	var counter = 0;

	public function new(main:Main) {
		t = main;
	}

	public function run() {
		t.section("ForIn");
		checkForIn();
		t.section("ForRange");
		checkForRange();
		t.section("ForShort");
		checkForShort();
		t.section("FloatToInt");
		checkFloatToInt();
		t.section("Vars");
		checkVars();
		t.section("Statics");
		checkStatics();
		t.section("Enum");
		checkEnum();
		t.section("AbstractEnum");
		checkAbstractEnum();
		t.section("Arrow");
		checkArrow();
		t.section("TryCatch");
		checkTryCatch();
		t.section("StringEscape");
		checkStringEscape();
	}

	function checkForIn() {
		var a = [1, 2, 3];
		var sum = 0;
		for (i in a) {
			sum += i;
		}
		t.intEquals(6, sum, "for-in sum");
	}

	function checkForRange() {
		var count = 0;
		for (i in 0...200) {
			count++;
		}
		t.intEquals(200, count, "for range 200");
	}

	function checkForShort() {
		var count = 0;
		for (i in 0...3) {
			count++;
		}
		t.intEquals(3, count, "for range 3");
	}

	function checkFloatToInt() {
		var f = 1.9;
		var i = f.int();
		t.intEquals(1, i, "float 1.9 to int");
	}

	function checkVars() {
		counter++;
		arr.push(1);
		t.intEquals(1, counter, "instance counter");
		t.intEquals(1, arr.length, "instance array length");
	}

	function checkStatics() {
		STATIC_COUNTER++;
		STATIC_ARR.push(100);
		t.intEquals(1, STATIC_COUNTER, "static counter");
		t.intEquals(1, STATIC_ARR.length, "static array length");
	}

	function checkEnum() {
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
		t.stringEquals("red", name, "enum switch Red");
	}

	function checkAbstractEnum() {
		var colorValue:ColorValues = Blue;
		var val:Int = colorValue;
		t.intEquals(255, val, "abstract enum Blue = 0x0000ff");
	}

	function checkArrow() {
		final add = (a:Int, b:Int) -> a + b;
		var result = add(1, 2);
		t.intEquals(3, result, "arrow function 1+2");
	}

	function checkTryCatch() {
		var caught = false;
		try {
			throw 'Error';
		} catch (e:Dynamic) {
			caught = true;
		}
		var wasCaught = caught;
		t.isTrue(wasCaught, "exception caught");
	}

	function checkStringEscape() {
		var str = "Hello\nWorld";
		var len = str.length;
		var lenOk = len > 0;
		t.isTrue(lenOk, "escaped string not empty");
	}
}
