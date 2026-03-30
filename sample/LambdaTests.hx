package;

class LambdaTests {
	var t:Main;

	public function new(main:Main) {
		t = main;
	}

	public function run() {
		t.section("LambdaArray");
		checkArray();
		t.section("LambdaMap");
		checkMap();
		t.section("LambdaMapi");
		checkMapi();
		t.section("LambdaFilter");
		checkFilter();
		t.section("LambdaFold");
		checkFold();
		t.section("LambdaFoldi");
		checkFoldi();
		t.section("LambdaCount");
		checkCount();
		t.section("LambdaFind");
		checkFind();
		t.section("LambdaFindIndex");
		checkFindIndex();
		t.section("LambdaExists");
		checkExists();
		t.section("LambdaForeach");
		checkForeach();
		t.section("LambdaIter");
		checkIter();
		t.section("LambdaEmpty");
		checkEmpty();
		t.section("LambdaIndexOf");
		checkIndexOf();
		t.section("LambdaConcat");
		checkConcat();
		t.section("LambdaFlatten");
		checkFlatten();
		t.section("LambdaFlatMap");
		checkFlatMap();
		t.section("LambdaHas");
		checkHas();
	}

	function checkArray() {
		var arr = [10, 20, 30];
		var result = Lambda.array(arr);
		t.intEquals(3, result.length, "array length");
		t.intEquals(10, result[0], "array[0]");
		t.intEquals(20, result[1], "array[1]");
		t.intEquals(30, result[2], "array[2]");

		// Result is a copy
		result[0] = 99;
		t.intEquals(10, arr[0], "array is copy");

		// Empty array
		var empty:Array<Int> = [];
		var r2 = Lambda.array(empty);
		t.intEquals(0, r2.length, "array empty");
	}

	function checkMap() {
		var arr = [1, 2, 3];
		var result = Lambda.map(arr, function(x:Int):Int {
			return x * 10;
		});
		t.intEquals(3, result.length, "map length");
		t.intEquals(10, result[0], "map[0]");
		t.intEquals(20, result[1], "map[1]");
		t.intEquals(30, result[2], "map[2]");

		// Map to string
		var doubled = Lambda.map(arr, function(x:Int):Int {
			return x + x;
		});
		t.intEquals(2, doubled[0], "map doubled[0]");
		t.intEquals(6, doubled[2], "map doubled[2]");

		// Empty
		var empty:Array<Int> = [];
		var r2 = Lambda.map(empty, function(x:Int):Int {
			return x * 2;
		});
		t.intEquals(0, r2.length, "map empty");
	}

	function checkMapi() {
		var arr = [10, 20, 30];
		var result = Lambda.mapi(arr, function(i:Int, x:Int):Int {
			return i * 100 + x;
		});
		t.intEquals(3, result.length, "mapi length");
		t.intEquals(10, result[0], "mapi[0] = 0*100+10");
		t.intEquals(120, result[1], "mapi[1] = 1*100+20");
		t.intEquals(230, result[2], "mapi[2] = 2*100+30");
	}

	function checkFilter() {
		var arr = [1, 2, 3, 4, 5, 6];
		var big = Lambda.filter(arr, function(x:Int):Bool {
			return x > 3;
		});
		t.intEquals(3, big.length, "filter length");
		t.intEquals(4, big[0], "filter[0]");
		t.intEquals(5, big[1], "filter[1]");
		t.intEquals(6, big[2], "filter[2]");

		// Filter none match
		var none = Lambda.filter(arr, function(x:Int):Bool {
			return x > 100;
		});
		t.intEquals(0, none.length, "filter none");

		// Filter all match
		var all = Lambda.filter(arr, function(x:Int):Bool {
			return x > 0;
		});
		t.intEquals(6, all.length, "filter all");
	}

	function checkFold() {
		var arr = [1, 2, 3, 4];
		var sum = Lambda.fold(arr, function(x:Int, acc:Int):Int {
			return acc + x;
		}, 0);
		t.intEquals(10, sum, "fold sum");

		// Fold with initial value
		var sum2 = Lambda.fold(arr, function(x:Int, acc:Int):Int {
			return acc + x;
		}, 100);
		t.intEquals(110, sum2, "fold with initial");

		// Fold product
		var product = Lambda.fold(arr, function(x:Int, acc:Int):Int {
			return acc * x;
		}, 1);
		t.intEquals(24, product, "fold product");

		// Empty fold
		var empty:Array<Int> = [];
		var r = Lambda.fold(empty, function(x:Int, acc:Int):Int {
			return acc + x;
		}, 42);
		t.intEquals(42, r, "fold empty returns first");
	}

	function checkFoldi() {
		var arr = [10, 20, 30];
		var result = Lambda.foldi(arr, function(x:Int, acc:Int, i:Int):Int {
			return acc + i * 100 + x;
		}, 0);
		// 0 + 0*100+10 + 1*100+20 + 2*100+30 = 360
		t.intEquals(360, result, "foldi indexed sum");
	}

	function checkCount() {
		var arr = [1, 2, 3, 4, 5];

		// Count all
		var total = Lambda.count(arr);
		t.intEquals(5, total, "count all");

		// Count with predicate
		var big = Lambda.count(arr, function(x:Int):Bool {
			return x > 3;
		});
		t.intEquals(2, big, "count > 3");

		// Count empty
		var empty:Array<Int> = [];
		var ce = Lambda.count(empty);
		t.intEquals(0, ce, "count empty");

		// Count none match
		var none = Lambda.count(arr, function(x:Int):Bool {
			return x > 100;
		});
		t.intEquals(0, none, "count none match");
	}

	function checkFind() {
		var arr = [1, 2, 3, 4, 5];
		var found = Lambda.find(arr, function(x:Int):Bool {
			return x > 3;
		});
		t.intEquals(4, found, "find first > 3");

		// Find no match
		var notFound = Lambda.find(arr, function(x:Int):Bool {
			return x > 100;
		});
		t.isTrue(notFound == null, "find no match is null");

		// Find first element
		var first = Lambda.find(arr, function(x:Int):Bool {
			return x == 1;
		});
		t.intEquals(1, first, "find first element");
	}

	function checkFindIndex() {
		var arr = [10, 20, 30, 40];
		var idx = Lambda.findIndex(arr, function(x:Int):Bool {
			return x == 30;
		});
		t.intEquals(2, idx, "findIndex of 30");

		// Not found
		var notFound = Lambda.findIndex(arr, function(x:Int):Bool {
			return x == 99;
		});
		t.intEquals(-1, notFound, "findIndex not found");

		// First element
		var first = Lambda.findIndex(arr, function(x:Int):Bool {
			return x == 10;
		});
		t.intEquals(0, first, "findIndex first");
	}

	function checkExists() {
		var arr = [1, 2, 3, 4, 5];
		var has3 = Lambda.exists(arr, function(x:Int):Bool {
			return x == 3;
		});
		t.isTrue(has3, "exists 3");

		var has99 = Lambda.exists(arr, function(x:Int):Bool {
			return x == 99;
		});
		t.isFalse(has99, "exists 99");

		// Empty
		var empty:Array<Int> = [];
		var hasAny = Lambda.exists(empty, function(x:Int):Bool {
			return true;
		});
		t.isFalse(hasAny, "exists empty");
	}

	function checkForeach() {
		var arr = [2, 4, 6, 8];
		var allPositive = Lambda.foreach(arr, function(x:Int):Bool {
			return x > 0;
		});
		t.isTrue(allPositive, "foreach all positive");

		var arr2 = [2, 4, -1, 8];
		var allPositive2 = Lambda.foreach(arr2, function(x:Int):Bool {
			return x > 0;
		});
		t.isFalse(allPositive2, "foreach not all positive");

		// Empty — foreach returns true
		var empty:Array<Int> = [];
		var emptyResult = Lambda.foreach(empty, function(x:Int):Bool {
			return false;
		});
		t.isTrue(emptyResult, "foreach empty is true");
	}

	function checkIter() {
		// iter calls function on each element
		var arr = [1, 2, 3];
		Lambda.iter(arr, function(x:Int):Void {
			var ignored = x;
		});
		t.isTrue(true, "iter runs on array");

		var empty:Array<Int> = [];
		Lambda.iter(empty, function(x:Int):Void {
			var ignored = x;
		});
		t.isTrue(true, "iter runs on empty");
	}

	function checkEmpty() {
		var arr = [1, 2, 3];
		var e1 = Lambda.empty(arr);
		t.isFalse(e1, "empty non-empty");

		var empty:Array<Int> = [];
		var e2 = Lambda.empty(empty);
		t.isTrue(e2, "empty empty");
	}

	function checkIndexOf() {
		var arr = [10, 20, 30, 40];
		var i0 = Lambda.indexOf(arr, 10);
		t.intEquals(0, i0, "indexOf first");
		var i2 = Lambda.indexOf(arr, 30);
		t.intEquals(2, i2, "indexOf middle");
		var i3 = Lambda.indexOf(arr, 40);
		t.intEquals(3, i3, "indexOf last");
		var im = Lambda.indexOf(arr, 99);
		t.intEquals(-1, im, "indexOf missing");

		// Empty
		var empty:Array<Int> = [];
		var ie = Lambda.indexOf(empty, 1);
		t.intEquals(-1, ie, "indexOf empty");
	}

	function checkConcat() {
		var a = [1, 2, 3];
		var b = [4, 5];
		var result = Lambda.concat(a, b);
		t.intEquals(5, result.length, "concat length");
		t.intEquals(1, result[0], "concat[0]");
		t.intEquals(3, result[2], "concat[2]");
		t.intEquals(4, result[3], "concat[3]");
		t.intEquals(5, result[4], "concat[4]");

		// Concat with empty
		var empty:Array<Int> = [];
		var r2 = Lambda.concat(a, empty);
		t.intEquals(3, r2.length, "concat with empty");

		var r3 = Lambda.concat(empty, b);
		t.intEquals(2, r3.length, "concat empty with");
	}

	function checkFlatten() {
		var nested:Array<Array<Int>> = [[1, 2], [3], [4, 5, 6]];
		var flat = Lambda.flatten(nested);
		t.intEquals(6, flat.length, "flatten length");
		t.intEquals(1, flat[0], "flatten[0]");
		t.intEquals(3, flat[2], "flatten[2]");
		t.intEquals(6, flat[5], "flatten[5]");

		// Flatten with empty inner
		var nested2:Array<Array<Int>> = [[1], [], [2]];
		var flat2 = Lambda.flatten(nested2);
		t.intEquals(2, flat2.length, "flatten with empty inner");

		// Flatten empty outer
		var emptyOuter:Array<Array<Int>> = [];
		var flat3 = Lambda.flatten(emptyOuter);
		t.intEquals(0, flat3.length, "flatten empty");
	}

	function checkFlatMap() {
		var arr = [1, 2, 3];
		var result = Lambda.flatMap(arr, function(x:Int):Array<Int> {
			return [x, x * 10];
		});
		t.intEquals(6, result.length, "flatMap length");
		t.intEquals(1, result[0], "flatMap[0]");
		t.intEquals(10, result[1], "flatMap[1]");
		t.intEquals(2, result[2], "flatMap[2]");
		t.intEquals(20, result[3], "flatMap[3]");
		t.intEquals(3, result[4], "flatMap[4]");
		t.intEquals(30, result[5], "flatMap[5]");

		// Empty
		var empty:Array<Int> = [];
		var r2 = Lambda.flatMap(empty, function(x:Int):Array<Int> {
			return [x];
		});
		t.intEquals(0, r2.length, "flatMap empty");
	}

	function checkHas() {
		var arr = [10, 20, 30];
		var h1 = Lambda.has(arr, 10);
		t.isTrue(h1, "has first");
		var h2 = Lambda.has(arr, 30);
		t.isTrue(h2, "has last");
		var h3 = Lambda.has(arr, 99);
		t.isFalse(h3, "has missing");

		// Empty
		var empty:Array<Int> = [];
		var h4 = Lambda.has(empty, 1);
		t.isFalse(h4, "has empty");
	}
}
