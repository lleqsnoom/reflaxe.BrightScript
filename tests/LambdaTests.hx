package;

import utest.Assert;

class LambdaTests extends utest.Test {
	function testArray() {
		var arr = [10, 20, 30];
		var result = Lambda.array(arr);
		Assert.equals(3, result.length);
		Assert.equals(10, result[0]);
		Assert.equals(20, result[1]);
		Assert.equals(30, result[2]);

		result[0] = 99;
		Assert.equals(10, arr[0]);

		var empty:Array<Int> = [];
		Assert.equals(0, Lambda.array(empty).length);
	}

	function testMap() {
		var arr = [1, 2, 3];
		var result = Lambda.map(arr, function(x:Int):Int {
			return x * 10;
		});
		Assert.equals(3, result.length);
		Assert.equals(10, result[0]);
		Assert.equals(20, result[1]);
		Assert.equals(30, result[2]);

		var doubled = Lambda.map(arr, function(x:Int):Int {
			return x + x;
		});
		Assert.equals(2, doubled[0]);
		Assert.equals(6, doubled[2]);

		var empty:Array<Int> = [];
		Assert.equals(0, Lambda.map(empty, function(x:Int):Int {
			return x * 2;
		}).length);
	}

	function testMapi() {
		var arr = [10, 20, 30];
		var result = Lambda.mapi(arr, function(i:Int, x:Int):Int {
			return i * 100 + x;
		});
		Assert.equals(3, result.length);
		Assert.equals(10, result[0]);
		Assert.equals(120, result[1]);
		Assert.equals(230, result[2]);
	}

	function testFilter() {
		var arr = [1, 2, 3, 4, 5, 6];
		var big = Lambda.filter(arr, function(x:Int):Bool {
			return x > 3;
		});
		Assert.equals(3, big.length);
		Assert.equals(4, big[0]);
		Assert.equals(5, big[1]);
		Assert.equals(6, big[2]);

		Assert.equals(0, Lambda.filter(arr, function(x:Int):Bool {
			return x > 100;
		}).length);

		Assert.equals(6, Lambda.filter(arr, function(x:Int):Bool {
			return x > 0;
		}).length);
	}

	function testFold() {
		var arr = [1, 2, 3, 4];
		var sum = Lambda.fold(arr, function(x:Int, acc:Int):Int {
			return acc + x;
		}, 0);
		Assert.equals(10, sum);

		Assert.equals(110, Lambda.fold(arr, function(x:Int, acc:Int):Int {
			return acc + x;
		}, 100));

		Assert.equals(24, Lambda.fold(arr, function(x:Int, acc:Int):Int {
			return acc * x;
		}, 1));

		var empty:Array<Int> = [];
		Assert.equals(42, Lambda.fold(empty, function(x:Int, acc:Int):Int {
			return acc + x;
		}, 42));
	}

	function testFoldi() {
		var arr = [10, 20, 30];
		var result = Lambda.foldi(arr, function(x:Int, acc:Int, i:Int):Int {
			return acc + i * 100 + x;
		}, 0);
		Assert.equals(360, result);
	}

	function testCount() {
		var arr = [1, 2, 3, 4, 5];
		Assert.equals(5, Lambda.count(arr));

		Assert.equals(2, Lambda.count(arr, function(x:Int):Bool {
			return x > 3;
		}));

		var empty:Array<Int> = [];
		Assert.equals(0, Lambda.count(empty));

		Assert.equals(0, Lambda.count(arr, function(x:Int):Bool {
			return x > 100;
		}));
	}

	function testFind() {
		var arr = [1, 2, 3, 4, 5];
		Assert.equals(4, Lambda.find(arr, function(x:Int):Bool {
			return x > 3;
		}));

		Assert.isTrue(Lambda.find(arr, function(x:Int):Bool {
			return x > 100;
		}) == null);

		Assert.equals(1, Lambda.find(arr, function(x:Int):Bool {
			return x == 1;
		}));
	}

	function testFindIndex() {
		var arr = [10, 20, 30, 40];
		Assert.equals(2, Lambda.findIndex(arr, function(x:Int):Bool {
			return x == 30;
		}));

		Assert.equals(-1, Lambda.findIndex(arr, function(x:Int):Bool {
			return x == 99;
		}));

		Assert.equals(0, Lambda.findIndex(arr, function(x:Int):Bool {
			return x == 10;
		}));
	}

	function testExists() {
		var arr = [1, 2, 3, 4, 5];
		Assert.isTrue(Lambda.exists(arr, function(x:Int):Bool {
			return x == 3;
		}));

		Assert.isFalse(Lambda.exists(arr, function(x:Int):Bool {
			return x == 99;
		}));

		var empty:Array<Int> = [];
		Assert.isFalse(Lambda.exists(empty, function(x:Int):Bool {
			return true;
		}));
	}

	function testForeach() {
		var arr = [2, 4, 6, 8];
		Assert.isTrue(Lambda.foreach(arr, function(x:Int):Bool {
			return x > 0;
		}));

		var arr2 = [2, 4, -1, 8];
		Assert.isFalse(Lambda.foreach(arr2, function(x:Int):Bool {
			return x > 0;
		}));

		var empty:Array<Int> = [];
		Assert.isTrue(Lambda.foreach(empty, function(x:Int):Bool {
			return false;
		}));
	}

	function testIter() {
		var arr = [1, 2, 3];
		Lambda.iter(arr, function(x:Int):Void {
			var ignored = x;
		});
		Assert.isTrue(true);

		var empty:Array<Int> = [];
		Lambda.iter(empty, function(x:Int):Void {
			var ignored = x;
		});
		Assert.isTrue(true);
	}

	function testEmpty() {
		Assert.isFalse(Lambda.empty([1, 2, 3]));

		var empty:Array<Int> = [];
		Assert.isTrue(Lambda.empty(empty));
	}

	function testIndexOf() {
		var arr = [10, 20, 30, 40];
		Assert.equals(0, Lambda.indexOf(arr, 10));
		Assert.equals(2, Lambda.indexOf(arr, 30));
		Assert.equals(3, Lambda.indexOf(arr, 40));
		Assert.equals(-1, Lambda.indexOf(arr, 99));

		var empty:Array<Int> = [];
		Assert.equals(-1, Lambda.indexOf(empty, 1));
	}

	function testConcat() {
		var a = [1, 2, 3];
		var b = [4, 5];
		var result = Lambda.concat(a, b);
		Assert.equals(5, result.length);
		Assert.equals(1, result[0]);
		Assert.equals(3, result[2]);
		Assert.equals(4, result[3]);
		Assert.equals(5, result[4]);

		var empty:Array<Int> = [];
		Assert.equals(3, Lambda.concat(a, empty).length);
		Assert.equals(2, Lambda.concat(empty, b).length);
	}

	function testFlatten() {
		var nested:Array<Array<Int>> = [[1, 2], [3], [4, 5, 6]];
		var flat = Lambda.flatten(nested);
		Assert.equals(6, flat.length);
		Assert.equals(1, flat[0]);
		Assert.equals(3, flat[2]);
		Assert.equals(6, flat[5]);

		var nested2:Array<Array<Int>> = [[1], [], [2]];
		Assert.equals(2, Lambda.flatten(nested2).length);

		var emptyOuter:Array<Array<Int>> = [];
		Assert.equals(0, Lambda.flatten(emptyOuter).length);
	}

	function testFlatMap() {
		var arr = [1, 2, 3];
		var result = Lambda.flatMap(arr, function(x:Int):Array<Int> {
			return [x, x * 10];
		});
		Assert.equals(6, result.length);
		Assert.equals(1, result[0]);
		Assert.equals(10, result[1]);
		Assert.equals(2, result[2]);
		Assert.equals(20, result[3]);
		Assert.equals(3, result[4]);
		Assert.equals(30, result[5]);

		var empty:Array<Int> = [];
		Assert.equals(0, Lambda.flatMap(empty, function(x:Int):Array<Int> {
			return [x];
		}).length);
	}

	function testHas() {
		var arr = [10, 20, 30];
		Assert.isTrue(Lambda.has(arr, 10));
		Assert.isTrue(Lambda.has(arr, 30));
		Assert.isFalse(Lambda.has(arr, 99));

		var empty:Array<Int> = [];
		Assert.isFalse(Lambda.has(empty, 1));
	}
}
