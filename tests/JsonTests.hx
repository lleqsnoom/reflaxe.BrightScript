package;

import utest.Assert;

class JsonTests extends utest.Test {
	function testParseArray() {
		var arr:Dynamic = haxe.Json.parse("[1,2,3]");
		Assert.equals(1, arr[0]);
		Assert.equals(2, arr[1]);
		Assert.equals(3, arr[2]);
	}

	function testStringify() {
		var obj:Dynamic = {};
		Reflect.setField(obj, "name", "world");
		Reflect.setField(obj, "num", 7);
		var json:String = haxe.Json.stringify(obj);
		var reparsed:Dynamic = haxe.Json.parse(json);
		Assert.equals("world", reparsed.name);
		Assert.equals(7, reparsed.num);
	}

	function testStringifyArray() {
		var arr:Dynamic = haxe.Json.parse("[10,20,30]");
		var json:String = haxe.Json.stringify(arr);
		var reparsed:Dynamic = haxe.Json.parse(json);
		Assert.equals(10, reparsed[0]);
		Assert.equals(30, reparsed[2]);
	}

	function testRoundtrip() {
		var obj:Dynamic = {};
		Reflect.setField(obj, "key", "value");
		Reflect.setField(obj, "count", 42);
		var json:String = haxe.Json.stringify(obj);
		var obj2:Dynamic = haxe.Json.parse(json);
		Assert.equals("value", obj2.key);
		Assert.equals(42, obj2.count);
	}

	function testRoundtripNested() {
		var inner:Dynamic = {};
		Reflect.setField(inner, "b", "deep");
		var obj:Dynamic = {};
		Reflect.setField(obj, "a", inner);
		Reflect.setField(obj, "arr", haxe.Json.parse("[10,20]"));
		var json:String = haxe.Json.stringify(obj);
		var obj2:Dynamic = haxe.Json.parse(json);
		Assert.equals("deep", obj2.a.b);
		Assert.equals(10, obj2.arr[0]);
		Assert.equals(20, obj2.arr[1]);
	}

	function testRoundtripTypes() {
		var arr:Dynamic = haxe.Json.parse("[true,false,null,42]");
		Assert.isTrue(arr[0] == true);
		Assert.isTrue(arr[1] == false);
		Assert.isTrue(arr[2] == null);
		Assert.equals(42, arr[3]);
	}
}
