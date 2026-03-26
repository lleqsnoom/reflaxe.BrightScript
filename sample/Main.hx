package;

using Std;

class Main {
	static final STATIC_ARR:Array<Int> = [];
	static var STATIC_COUNTER = 0;

	final arr:Array<Int> = [];
	var counter = 0;

	public static function main() {
		new Main("Hello world!", 1, false, 0.5);
	}

	public function new(msg:String, i:Int, b:Bool, f:Float) {
		trace('---- checkForIn ----');
		checkForIn();
		trace('---- checkFor ----');
		checkFor();
		trace('---- checkForShort ----');
		checkForShort();
		trace('---- checkFloatToInt ----');
		checkFloatToInt();
		trace('---- checkArray ----');
		checkArray();
		trace('---- checkVars ----');
		checkVars();
		trace('---- checkStatics ----');
		checkStatics();
		trace('---- checkStatics ----');
		checkEnum();
		trace('---- checkAbstractEnum ----');
		checkAbstractEnum();
		trace('---- checkArrow ----');
		checkArrow();
		trace('---- checkTryCatch ----');
		checkTryCatch();
		trace('---- checkQuickrray ----');
		checkQuickrray();
		trace('---- checkStringsEscape ----');
		checkStringsEscape();
		trace(msg);
	}

	function checkStringsEscape() {
		var str = "Hello\nWorld";
		trace('str: $str');
	}

	function checkForIn() {
		var arr = [1, 2, 3];
		for (i in arr) {
			trace('i: $i');
		}
	}

	function checkTryCatch() {
		try {
			throw 'Error';
		} catch (e:Dynamic) {
			trace('Error: $e');
		}
	}

	function checkEnum() {
		var color:Colors = null;
		color = Red;
		switch color {
			case Red:
				trace('Color: red');
			case Green:
				trace('Color: green');
			case Blue:
				trace('Color: blue');
		}
	}

	function checkAbstractEnum() {
		var colorValue:ColorValues = Blue;
		trace('colorValue: $colorValue');
	}

	function checkArray() {
		final threeStepIntArray = [1, 2, 3, 4];
		trace('threeStepIntArray: ' + threeStepIntArray.length);
		final threeStepStrArray = new Array<String>();
		threeStepStrArray.push("A");
		threeStepStrArray.push("B");
		threeStepStrArray.push("C");
		trace('Int: ' + 1);
		trace('Float: ' + 1.1);
		trace('Bool: ' + true);
		trace('String: ' + 'Hello');
		trace('arr: $threeStepStrArray');
		return 10;
	}

	function checkArrow() {
		final arrow = (x:Int) -> 'your int is: $x';
		trace('arrow(1): ' + arrow(1));
	}

	function checkStatics() {
		STATIC_COUNTER++;
		STATIC_ARR.push(100);
		trace('STATIC_COUNTER: $STATIC_COUNTER, STATIC_ARR: $STATIC_ARR');
	}

	function checkVars() {
		counter++;
		arr.push(1);
		trace('counter: $counter, arr: $arr');
	}

	function checkFloatToInt() {
		var f = 1.9;
		var i = f.int();
		trace("i: " + i);
	}

	function checkFor() {
		var fori = 0;
		for (i in 0...200) {
			fori++;
		}
		trace("fori: " + fori);
	}

	function checkForShort() {
		var fori = 0;
		for (i in 0...3) {
			fori++;
		}
		trace("fori: " + fori);
	}

	function checkQuickrray() {
		final quickArr = [for (i in 0...1) i];
		trace("quickArr: " + quickArr);
	}
}

enum Colors {
	Red;
	Green;
	Blue;
}

enum abstract ColorValues(Int) from Int to Int {
	final Red = 0xff0000;
	final Green = 0x00ff00;
	final Blue = 0x0000ff;
}
