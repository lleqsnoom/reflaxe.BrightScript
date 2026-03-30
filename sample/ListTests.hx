package;

class ListTests {
	var t:Main;

	public function new(main:Main) {
		t = main;
	}

	public function run() {
		t.section("ListAddPush");
		checkAddPush();
		t.section("ListFirstLast");
		checkFirstLast();
		t.section("ListPop");
		checkPop();
		t.section("ListIsEmpty");
		checkIsEmpty();
		t.section("ListClear");
		checkClear();
		t.section("ListRemove");
		checkRemove();
		t.section("ListIterator");
		checkIterator();
		t.section("ListMap");
		checkMap();
		t.section("ListFilter");
		checkFilter();
		t.section("ListJoin");
		checkJoin();
		t.section("ListToString");
		checkToString();
	}

	function checkAddPush() {
		var list = new List<Int>();
		t.intEquals(0, list.length, "empty length");

		list.add(10);
		list.add(20);
		list.add(30);
		t.intEquals(3, list.length, "add length");
		t.intEquals(10, list.first(), "add first");
		t.intEquals(30, list.last(), "add last");

		// push adds to beginning
		list.push(5);
		t.intEquals(4, list.length, "push length");
		t.intEquals(5, list.first(), "push first");
		t.intEquals(30, list.last(), "push last unchanged");
	}

	function checkFirstLast() {
		var list = new List<String>();
		var f = list.first();
		t.isTrue(f == null, "first empty is null");
		var l = list.last();
		t.isTrue(l == null, "last empty is null");

		list.add("hello");
		t.stringEquals("hello", list.first(), "first single");
		t.stringEquals("hello", list.last(), "last single");

		list.add("world");
		t.stringEquals("hello", list.first(), "first two");
		t.stringEquals("world", list.last(), "last two");
	}

	function checkPop() {
		var list = new List<Int>();
		var p = list.pop();
		t.isTrue(p == null, "pop empty is null");

		list.add(1);
		list.add(2);
		list.add(3);

		var v1 = list.pop();
		t.intEquals(1, v1, "pop first value");
		t.intEquals(2, list.length, "pop length after");

		var v2 = list.pop();
		t.intEquals(2, v2, "pop second value");

		var v3 = list.pop();
		t.intEquals(3, v3, "pop third value");
		t.intEquals(0, list.length, "pop all empty");
	}

	function checkIsEmpty() {
		var list = new List<Int>();
		t.isTrue(list.isEmpty(), "isEmpty new list");

		list.add(1);
		t.isFalse(list.isEmpty(), "isEmpty after add");

		list.pop();
		t.isTrue(list.isEmpty(), "isEmpty after pop all");
	}

	function checkClear() {
		var list = new List<Int>();
		list.add(1);
		list.add(2);
		list.add(3);
		t.intEquals(3, list.length, "before clear");

		list.clear();
		t.intEquals(0, list.length, "after clear length");
		t.isTrue(list.isEmpty(), "after clear isEmpty");

		// Clear empty list
		list.clear();
		t.intEquals(0, list.length, "clear empty");
	}

	function checkRemove() {
		var list = new List<Int>();
		t.isFalse(list.remove(1), "remove from empty");

		list.add(10);
		list.add(20);
		list.add(30);
		list.add(20);

		t.isTrue(list.remove(20), "remove existing");
		t.intEquals(3, list.length, "remove length");
		t.intEquals(10, list.first(), "remove first intact");

		t.isFalse(list.remove(99), "remove nonexistent");
		t.intEquals(3, list.length, "remove no change");
	}

	function checkIterator() {
		var list = new List<Int>();
		list.add(10);
		list.add(20);
		list.add(30);

		var sum = 0;
		var count = 0;
		var it = list.iterator();
		while (it.hasNext()) {
			sum = sum + it.next();
			count = count + 1;
		}
		t.intEquals(60, sum, "iterator sum");
		t.intEquals(3, count, "iterator count");

		// Empty list iterator
		var empty = new List<Int>();
		var emptyIt = empty.iterator();
		t.isFalse(emptyIt.hasNext(), "empty iterator hasNext");
	}

	function checkMap() {
		var list = new List<Int>();
		list.add(1);
		list.add(2);
		list.add(3);

		var doubled = list.map(function(x:Int):Int {
			return x * 2;
		});
		t.intEquals(3, doubled.length, "map length");
		t.intEquals(2, doubled.first(), "map first");
		t.intEquals(6, doubled.last(), "map last");

		// Empty map
		var empty = new List<Int>();
		var mapped = empty.map(function(x:Int):Int {
			return x * 10;
		});
		t.intEquals(0, mapped.length, "map empty");
	}

	function checkFilter() {
		var list = new List<Int>();
		list.add(1);
		list.add(2);
		list.add(3);
		list.add(4);
		list.add(5);

		var big = list.filter(function(x:Int):Bool {
			return x > 3;
		});
		t.intEquals(2, big.length, "filter length");
		t.intEquals(4, big.first(), "filter first");
		t.intEquals(5, big.last(), "filter last");

		// Filter none
		var none = list.filter(function(x:Int):Bool {
			return x > 100;
		});
		t.intEquals(0, none.length, "filter none");
	}

	function checkJoin() {
		var list = new List<Int>();
		list.add(1);
		list.add(2);
		list.add(3);

		t.stringEquals("1, 2, 3", list.join(", "), "join comma");
		t.stringEquals("1-2-3", list.join("-"), "join dash");

		// Empty join
		var empty = new List<Int>();
		t.stringEquals("", empty.join(", "), "join empty");

		// Single element
		var single = new List<String>();
		single.add("only");
		t.stringEquals("only", single.join(", "), "join single");
	}

	function checkToString() {
		var list = new List<Int>();
		list.add(1);
		list.add(2);
		list.add(3);

		t.stringEquals("{1, 2, 3}", list.toString(), "toString ints");

		var empty = new List<Int>();
		t.stringEquals("{}", empty.toString(), "toString empty");

		var single = new List<String>();
		single.add("hello");
		t.stringEquals("{hello}", single.toString(), "toString single");
	}
}
