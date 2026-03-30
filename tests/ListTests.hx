package;

import utest.Assert;

class ListTests extends utest.Test {
	function testAddPush() {
		var list = new List<Int>();
		Assert.equals(0, list.length);

		list.add(10);
		list.add(20);
		list.add(30);
		Assert.equals(3, list.length);
		Assert.equals(10, list.first());
		Assert.equals(30, list.last());

		list.push(5);
		Assert.equals(4, list.length);
		Assert.equals(5, list.first());
		Assert.equals(30, list.last());
	}

	function testFirstLast() {
		var list = new List<String>();
		Assert.isTrue(list.first() == null);
		Assert.isTrue(list.last() == null);

		list.add("hello");
		Assert.equals("hello", list.first());
		Assert.equals("hello", list.last());

		list.add("world");
		Assert.equals("hello", list.first());
		Assert.equals("world", list.last());
	}

	function testPop() {
		var list = new List<Int>();
		Assert.isTrue(list.pop() == null);

		list.add(1);
		list.add(2);
		list.add(3);

		Assert.equals(1, list.pop());
		Assert.equals(2, list.length);
		Assert.equals(2, list.pop());
		Assert.equals(3, list.pop());
		Assert.equals(0, list.length);
	}

	function testIsEmpty() {
		var list = new List<Int>();
		Assert.isTrue(list.isEmpty());

		list.add(1);
		Assert.isFalse(list.isEmpty());

		list.pop();
		Assert.isTrue(list.isEmpty());
	}

	function testClear() {
		var list = new List<Int>();
		list.add(1);
		list.add(2);
		list.add(3);
		Assert.equals(3, list.length);

		list.clear();
		Assert.equals(0, list.length);
		Assert.isTrue(list.isEmpty());

		list.clear();
		Assert.equals(0, list.length);
	}

	function testRemove() {
		var list = new List<Int>();
		Assert.isFalse(list.remove(1));

		list.add(10);
		list.add(20);
		list.add(30);
		list.add(20);

		Assert.isTrue(list.remove(20));
		Assert.equals(3, list.length);
		Assert.equals(10, list.first());

		Assert.isFalse(list.remove(99));
		Assert.equals(3, list.length);
	}

	function testIterator() {
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
		Assert.equals(60, sum);
		Assert.equals(3, count);

		var empty = new List<Int>();
		Assert.isFalse(empty.iterator().hasNext());
	}

	function testMap() {
		var list = new List<Int>();
		list.add(1);
		list.add(2);
		list.add(3);

		var doubled = list.map(function(x:Int):Int {
			return x * 2;
		});
		Assert.equals(3, doubled.length);
		Assert.equals(2, doubled.first());
		Assert.equals(6, doubled.last());

		var empty = new List<Int>();
		Assert.equals(0, empty.map(function(x:Int):Int {
			return x * 10;
		}).length);
	}

	function testFilter() {
		var list = new List<Int>();
		list.add(1);
		list.add(2);
		list.add(3);
		list.add(4);
		list.add(5);

		var big = list.filter(function(x:Int):Bool {
			return x > 3;
		});
		Assert.equals(2, big.length);
		Assert.equals(4, big.first());
		Assert.equals(5, big.last());

		Assert.equals(0, list.filter(function(x:Int):Bool {
			return x > 100;
		}).length);
	}

	function testJoin() {
		var list = new List<Int>();
		list.add(1);
		list.add(2);
		list.add(3);

		Assert.equals("1, 2, 3", list.join(", "));
		Assert.equals("1-2-3", list.join("-"));

		var empty = new List<Int>();
		Assert.equals("", empty.join(", "));

		var single = new List<String>();
		single.add("only");
		Assert.equals("only", single.join(", "));
	}

	function testToString() {
		var list = new List<Int>();
		list.add(1);
		list.add(2);
		list.add(3);
		Assert.equals("{1, 2, 3}", list.toString());

		var empty = new List<Int>();
		Assert.equals("{}", empty.toString());

		var single = new List<String>();
		single.add("hello");
		Assert.equals("{hello}", single.toString());
	}
}
