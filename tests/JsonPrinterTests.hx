package;

import utest.Assert;

class JsonPrinterTests extends utest.Test {
	function testNull() {
		Assert.equals("null", haxe.format.JsonPrinter.print(null));
	}

	function testInt() {
		Assert.equals("42", haxe.format.JsonPrinter.print(42));
		Assert.equals("0", haxe.format.JsonPrinter.print(0));
		Assert.equals("-1", haxe.format.JsonPrinter.print(-1));
	}

	function testBool() {
		Assert.equals("true", haxe.format.JsonPrinter.print(true));
		Assert.equals("false", haxe.format.JsonPrinter.print(false));
	}

	function testFloat() {
		var result:String = haxe.format.JsonPrinter.print(3.14);
		var reparsed:Dynamic = haxe.Json.parse(result);
		Assert.floatEquals(3.14, reparsed);
	}

	function testString() {
		var result:String = haxe.format.JsonPrinter.print("hello");
		Assert.equals(7, result.length);
		var parsed:Dynamic = haxe.Json.parse(result);
		Assert.equals("hello", parsed);

		var empty:String = haxe.format.JsonPrinter.print("");
		Assert.equals(2, empty.length);
	}

	function testEscape() {
		var code:Int = 34;
		var strWithQuote = "a" + String.fromCharCode(code) + "b";
		var result = haxe.format.JsonPrinter.print(strWithQuote);
		var parsed:Dynamic = haxe.Json.parse(result);
		Assert.equals(strWithQuote, parsed);

		var bsCode:Int = 92;
		var strWithSlash = "a" + String.fromCharCode(bsCode) + "b";
		var result2 = haxe.format.JsonPrinter.print(strWithSlash);
		var parsed2:Dynamic = haxe.Json.parse(result2);
		Assert.equals(strWithSlash, parsed2);
	}

	function testArray() {
		var arr:Array<Dynamic> = [1, 2, 3];
		var json:String = haxe.format.JsonPrinter.print(arr);
		var reparsed:Dynamic = haxe.Json.parse(json);
		Assert.equals(1, reparsed[0]);
		Assert.equals(2, reparsed[1]);
		Assert.equals(3, reparsed[2]);
	}

	function testEmptyArray() {
		var arr:Array<Dynamic> = [];
		Assert.equals("[]", haxe.format.JsonPrinter.print(arr));
	}

	function testObject() {
		var obj:Dynamic = {};
		Reflect.setField(obj, "name", "world");
		Reflect.setField(obj, "num", 7);
		var json:String = haxe.format.JsonPrinter.print(obj);
		var reparsed:Dynamic = haxe.Json.parse(json);
		Assert.equals("world", reparsed.name);
		Assert.equals(7, reparsed.num);
	}

	function testEmptyObject() {
		var obj:Dynamic = {};
		Assert.equals("{}", haxe.format.JsonPrinter.print(obj));
	}

	function testNested() {
		var inner:Dynamic = {};
		Reflect.setField(inner, "b", "deep");
		var obj:Dynamic = {};
		Reflect.setField(obj, "a", inner);
		Reflect.setField(obj, "arr", [10, 20]);
		var json:String = haxe.format.JsonPrinter.print(obj);
		var reparsed:Dynamic = haxe.Json.parse(json);
		Assert.equals("deep", reparsed.a.b);
		Assert.equals(10, reparsed.arr[0]);
		Assert.equals(20, reparsed.arr[1]);
	}

	function testPretty() {
		var obj:Dynamic = {};
		Reflect.setField(obj, "x", 1);
		var compact:String = haxe.format.JsonPrinter.print(obj);
		var pretty:String = haxe.format.JsonPrinter.print(obj, null, "  ");
		Assert.isTrue(pretty.length > compact.length);
		var reparsed:Dynamic = haxe.Json.parse(pretty);
		Assert.equals(1, reparsed.x);
	}

	function testPrettyArray() {
		var arr:Array<Dynamic> = [1, 2];
		var compact:String = haxe.format.JsonPrinter.print(arr);
		var pretty:String = haxe.format.JsonPrinter.print(arr, null, "  ");
		Assert.isTrue(pretty.length > compact.length);
		var reparsed:Dynamic = haxe.Json.parse(pretty);
		Assert.equals(1, reparsed[0]);
		Assert.equals(2, reparsed[1]);
	}
}
