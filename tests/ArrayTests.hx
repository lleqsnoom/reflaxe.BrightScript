package;

import utest.Assert;

class ArrayTests extends utest.Test {
	function testArrayBasic() {
		final intArr = [1, 2, 3, 4];
		Assert.equals(4, intArr.length);

		final strArr = new Array<String>();
		strArr.push("A");
		strArr.push("B");
		strArr.push("C");
		Assert.equals(3, strArr.length);
		Assert.equals("A", strArr[0]);
		Assert.equals("C", strArr[2]);
	}

	function testArrayPushPop() {
		var a:Array<Int> = [];
		a.push(10);
		a.push(20);
		a.push(30);
		Assert.equals(3, a.length);
		var popped = a.pop();
		Assert.isTrue(popped == 30);
		Assert.equals(2, a.length);
	}

	function testArrayShiftUnshift() {
		var a = [1, 2, 3];
		a.unshift(0);
		Assert.equals(4, a.length);
		var shifted = a.shift();
		Assert.isTrue(shifted == 0);
		Assert.equals(3, a.length);
	}

	function testArrayConcat() {
		var a = [1, 2];
		var b = [3, 4];
		var c = a.concat(b);
		Assert.equals(4, c.length);
		Assert.equals(2, a.length);
	}

	function testArrayJoin() {
		var a = [1, 2, 3];
		var joined = a.join(",");
		Assert.isTrue(StringTools.contains(joined, ","));
		var joinedDash = a.join("-");
		Assert.isTrue(StringTools.contains(joinedDash, "-"));
	}

	function testArraySlice() {
		var a = [10, 20, 30, 40, 50];
		var s1 = a.slice(1, 3);
		Assert.equals(2, s1.length);
		var s2 = a.slice(2, 5);
		Assert.equals(3, s2.length);
		Assert.equals(5, a.length);
	}

	function testArraySplice() {
		var a = [10, 20, 30, 40, 50];
		var removed = a.splice(1, 2);
		Assert.equals(2, removed.length);
		Assert.equals(3, a.length);
	}

	function testArrayIndexOf() {
		var a = [10, 20, 30, 20, 40];
		Assert.equals(1, a.indexOf(20));
		Assert.equals(-1, a.indexOf(99));
		Assert.equals(3, a.indexOf(20, 2));
	}

	function testArrayLastIndexOf() {
		var a = [10, 20, 30, 20, 40];
		Assert.equals(3, a.lastIndexOf(20));
		Assert.equals(-1, a.lastIndexOf(99));
	}

	function testArrayContains() {
		var a = [10, 20, 30];
		Assert.isTrue(a.contains(20));
		Assert.isFalse(a.contains(99));
	}

	function testArrayRemove() {
		var a = [10, 20, 30, 20];
		Assert.isTrue(a.remove(20));
		Assert.equals(3, a.length);
		Assert.isFalse(a.remove(99));
	}

	function testArrayInsert() {
		var a = [10, 20, 30];
		a.insert(1, 15);
		Assert.equals(4, a.length);
		a.insert(0, 5);
		Assert.equals(5, a.length);
	}

	function testArrayReverse() {
		var a = [1, 2, 3, 4, 5];
		a.reverse();
		var rev = a.join(",");
		Assert.equals(" 5, 4, 3, 2, 1", rev);
	}

	function testArraySort() {
		var a = [3, 1, 4, 1, 5, 9, 2, 6];
		a.sort(function(x:Int, y:Int):Int {
			return x - y;
		});
		var sorted = a.join(",");
		Assert.equals(" 1, 1, 2, 3, 4, 5, 6, 9", sorted);
	}

	function testArrayMap() {
		var a = [1, 2, 3];
		var doubled = a.map(function(x:Int):Int {
			return x * 2;
		});
		var mappedStr = doubled.join(",");
		Assert.equals(" 2, 4, 6", mappedStr);
		var origStr = a.join(",");
		Assert.equals(" 1, 2, 3", origStr);
	}

	function testArrayFilter() {
		var a = [1, 2, 3, 4, 5, 6];
		var big = a.filter(function(x:Int):Bool {
			return x > 3;
		});
		var filteredStr = big.join(",");
		Assert.equals(" 4, 5, 6", filteredStr);
	}

	function testArrayCopy() {
		var a = [1, 2, 3];
		var b = a.copy();
		b.push(4);
		Assert.equals(4, b.length);
		Assert.equals(3, a.length);
	}

	function testArrayResize() {
		var a = [1, 2, 3, 4, 5];
		a.resize(3);
		Assert.equals(3, a.length);
		a.resize(5);
		Assert.equals(5, a.length);
	}

	function testArrayIterator() {
		var a = [10, 20, 30];
		var sum = 0;
		for (v in a) {
			sum += v;
		}
		Assert.equals(60, sum);
	}

	function testArrayComprehension() {
		final a = [for (i in 0...3) i];
		Assert.equals(3, a.length);
		Assert.equals(0, a[0]);
		Assert.equals(2, a[2]);
	}
}
