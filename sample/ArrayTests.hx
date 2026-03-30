package;

class ArrayTests {
	var t:Main;

	public function new(main:Main) {
		t = main;
	}

	public function run() {
		t.section("ArrayBasic");
		checkArrayBasic();
		t.section("ArrayPushPop");
		checkArrayPushPop();
		t.section("ArrayShiftUnshift");
		checkArrayShiftUnshift();
		t.section("ArrayConcat");
		checkArrayConcat();
		t.section("ArrayJoin");
		checkArrayJoin();
		t.section("ArraySlice");
		checkArraySlice();
		t.section("ArraySplice");
		checkArraySplice();
		t.section("ArrayIndexOf");
		checkArrayIndexOf();
		t.section("ArrayLastIndexOf");
		checkArrayLastIndexOf();
		t.section("ArrayContains");
		checkArrayContains();
		t.section("ArrayRemove");
		checkArrayRemove();
		t.section("ArrayInsert");
		checkArrayInsert();
		t.section("ArrayReverse");
		checkArrayReverse();
		t.section("ArraySort");
		checkArraySort();
		t.section("ArrayMap");
		checkArrayMap();
		t.section("ArrayFilter");
		checkArrayFilter();
		t.section("ArrayCopy");
		checkArrayCopy();
		t.section("ArrayResize");
		checkArrayResize();
		t.section("ArrayIterator");
		checkArrayIterator();
		t.section("ArrayComprehension");
		checkArrayComprehension();
	}

	function checkArrayBasic() {
		final intArr = [1, 2, 3, 4];
		t.intEquals(4, intArr.length, "int array literal length");

		final strArr = new Array<String>();
		strArr.push("A");
		strArr.push("B");
		strArr.push("C");
		t.intEquals(3, strArr.length, "string array push length");
		t.stringEquals("A", strArr[0], "string array element 0");
		t.stringEquals("C", strArr[2], "string array element 2");
	}

	function checkArrayPushPop() {
		var a:Array<Int> = [];
		a.push(10);
		a.push(20);
		a.push(30);
		t.intEquals(3, a.length, "push length");
		var popped = a.pop();
		var popOk = popped == 30;
		t.isTrue(popOk, "pop returns last element");
		t.intEquals(2, a.length, "length after pop");
	}

	function checkArrayShiftUnshift() {
		var a = [1, 2, 3];
		a.unshift(0);
		t.intEquals(4, a.length, "length after unshift");
		var shifted = a.shift();
		var shiftOk = shifted == 0;
		t.isTrue(shiftOk, "shift returns first element");
		t.intEquals(3, a.length, "length after shift");
	}

	function checkArrayConcat() {
		var a = [1, 2];
		var b = [3, 4];
		var c = a.concat(b);
		t.intEquals(4, c.length, "concat result length");
		t.intEquals(2, a.length, "original unchanged after concat");
	}

	function checkArrayJoin() {
		var a = [1, 2, 3];
		var joined = a.join(",");
		var hasSep = StringTools.contains(joined, ",");
		t.isTrue(hasSep, "join with comma separator");
		var joinedDash = a.join("-");
		var hasDash = StringTools.contains(joinedDash, "-");
		t.isTrue(hasDash, "join with dash separator");
	}

	function checkArraySlice() {
		var a = [10, 20, 30, 40, 50];
		var s1 = a.slice(1, 3);
		t.intEquals(2, s1.length, "slice(1,3) length");
		var s2 = a.slice(2, 5);
		t.intEquals(3, s2.length, "slice(2,5) length");
		t.intEquals(5, a.length, "original unchanged after slice");
	}

	function checkArraySplice() {
		var a = [10, 20, 30, 40, 50];
		var removed = a.splice(1, 2);
		t.intEquals(2, removed.length, "splice removed length");
		t.intEquals(3, a.length, "length after splice");
	}

	function checkArrayIndexOf() {
		var a = [10, 20, 30, 20, 40];
		var idx1 = a.indexOf(20);
		t.intEquals(1, idx1, "indexOf first occurrence");
		var idx2 = a.indexOf(99);
		t.intEquals(-1, idx2, "indexOf missing element");
		var idx3 = a.indexOf(20, 2);
		t.intEquals(3, idx3, "indexOf with startIndex");
	}

	function checkArrayLastIndexOf() {
		var a = [10, 20, 30, 20, 40];
		var li1 = a.lastIndexOf(20);
		t.intEquals(3, li1, "lastIndexOf 20");
		var li2 = a.lastIndexOf(99);
		t.intEquals(-1, li2, "lastIndexOf missing");
	}

	function checkArrayContains() {
		var a = [10, 20, 30];
		var c1 = a.contains(20);
		t.isTrue(c1, "contains existing element");
		var c2 = a.contains(99);
		t.isFalse(c2, "contains missing element");
	}

	function checkArrayRemove() {
		var a = [10, 20, 30, 20];
		var r1 = a.remove(20);
		t.isTrue(r1, "remove existing returns true");
		t.intEquals(3, a.length, "length after remove");
		var r2 = a.remove(99);
		t.isFalse(r2, "remove missing returns false");
	}

	function checkArrayInsert() {
		var a = [10, 20, 30];
		a.insert(1, 15);
		t.intEquals(4, a.length, "length after insert at 1");
		a.insert(0, 5);
		t.intEquals(5, a.length, "length after insert at 0");
	}

	function checkArrayReverse() {
		var a = [1, 2, 3, 4, 5];
		a.reverse();
		var rev = a.join(",");
		t.stringEquals(" 5, 4, 3, 2, 1", rev, "reverse full result");
	}

	function checkArraySort() {
		var a = [3, 1, 4, 1, 5, 9, 2, 6];
		a.sort(function(x:Int, y:Int):Int {
			return x - y;
		});
		var sorted = a.join(",");
		t.stringEquals(" 1, 1, 2, 3, 4, 5, 6, 9", sorted, "sort full result");
	}

	function checkArrayMap() {
		var a = [1, 2, 3];
		var doubled = a.map(function(x:Int):Int {
			return x * 2;
		});
		var mappedStr = doubled.join(",");
		t.stringEquals(" 2, 4, 6", mappedStr, "map doubles values");
		var origStr = a.join(",");
		t.stringEquals(" 1, 2, 3", origStr, "map does not modify original");
	}

	function checkArrayFilter() {
		var a = [1, 2, 3, 4, 5, 6];
		var big = a.filter(function(x:Int):Bool {
			return x > 3;
		});
		var filteredStr = big.join(",");
		t.stringEquals(" 4, 5, 6", filteredStr, "filter > 3");
	}

	function checkArrayCopy() {
		var a = [1, 2, 3];
		var b = a.copy();
		b.push(4);
		t.intEquals(4, b.length, "copy length after push");
		t.intEquals(3, a.length, "original unchanged after copy push");
	}

	function checkArrayResize() {
		var a = [1, 2, 3, 4, 5];
		a.resize(3);
		t.intEquals(3, a.length, "shrink to 3");
		a.resize(5);
		t.intEquals(5, a.length, "grow to 5");
	}

	function checkArrayIterator() {
		var a = [10, 20, 30];
		var sum = 0;
		for (v in a) {
			sum += v;
		}
		t.intEquals(60, sum, "iterator sum");
	}

	function checkArrayComprehension() {
		final a = [for (i in 0...3) i];
		t.intEquals(3, a.length, "comprehension length");
		t.intEquals(0, a[0], "comprehension first");
		t.intEquals(2, a[2], "comprehension last");
	}
}
