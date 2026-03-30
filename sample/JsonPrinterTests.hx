package;

class JsonPrinterTests {
	var t:Main;

	public function new(main:Main) {
		t = main;
	}

	public function run() {
		t.section("JsonPrinterNull");
		checkNull();
		t.section("JsonPrinterInt");
		checkInt();
		t.section("JsonPrinterBool");
		checkBool();
		t.section("JsonPrinterFloat");
		checkFloat();
		t.section("JsonPrinterString");
		checkString();
		t.section("JsonPrinterEscape");
		checkEscape();
		t.section("JsonPrinterArray");
		checkArray();
		t.section("JsonPrinterEmptyArray");
		checkEmptyArray();
		t.section("JsonPrinterObject");
		checkObject();
		t.section("JsonPrinterEmptyObject");
		checkEmptyObject();
		t.section("JsonPrinterNested");
		checkNested();
		t.section("JsonPrinterPretty");
		checkPretty();
		t.section("JsonPrinterPrettyArray");
		checkPrettyArray();
	}

	function checkNull() {
		var r = haxe.format.JsonPrinter.print(null);
		t.stringEquals("null", r, "print null");
	}

	function checkInt() {
		var r1 = haxe.format.JsonPrinter.print(42);
		t.stringEquals("42", r1, "print int 42");
		var r2 = haxe.format.JsonPrinter.print(0);
		t.stringEquals("0", r2, "print int 0");
		var r3 = haxe.format.JsonPrinter.print(-1);
		t.stringEquals("-1", r3, "print int -1");
	}

	function checkBool() {
		var r1 = haxe.format.JsonPrinter.print(true);
		t.stringEquals("true", r1, "print true");
		var r2 = haxe.format.JsonPrinter.print(false);
		t.stringEquals("false", r2, "print false");
	}

	function checkFloat() {
		var result:String = haxe.format.JsonPrinter.print(3.14);
		// Round-trip: parse the result and check value
		var reparsed:Dynamic = haxe.Json.parse(result);
		t.floatNear(3.14, reparsed, "print float 3.14 round-trip");
	}

	function checkString() {
		var result:String = haxe.format.JsonPrinter.print("hello");
		// "hello" with JSON quotes = 7 chars
		t.intEquals(7, result.length, "print string hello length");
		var parsed:Dynamic = haxe.Json.parse(result);
		t.stringEquals("hello", parsed, "print string hello round-trip");

		var empty:String = haxe.format.JsonPrinter.print("");
		// "" with JSON quotes = 2 chars
		t.intEquals(2, empty.length, "print empty string length");
	}

	function checkEscape() {
		// Build test strings safely using fromCharCode to avoid BRS string literal issues
		var code:Int = 34;
		var strWithQuote = "a" + String.fromCharCode(code) + "b";
		var result = haxe.format.JsonPrinter.print(strWithQuote);
		var parsed:Dynamic = haxe.Json.parse(result);
		t.stringEquals(strWithQuote, parsed, "round-trip string with quote");

		var bsCode:Int = 92;
		var strWithSlash = "a" + String.fromCharCode(bsCode) + "b";
		var result2 = haxe.format.JsonPrinter.print(strWithSlash);
		var parsed2:Dynamic = haxe.Json.parse(result2);
		t.stringEquals(strWithSlash, parsed2, "round-trip string with backslash");
	}

	function checkArray() {
		var arr:Array<Dynamic> = [1, 2, 3];
		var json:String = haxe.format.JsonPrinter.print(arr);
		var reparsed:Dynamic = haxe.Json.parse(json);
		t.intEquals(1, reparsed[0], "print array element 0");
		t.intEquals(2, reparsed[1], "print array element 1");
		t.intEquals(3, reparsed[2], "print array element 2");
	}

	function checkEmptyArray() {
		var arr:Array<Dynamic> = [];
		var r = haxe.format.JsonPrinter.print(arr);
		t.stringEquals("[]", r, "print empty array");
	}

	function checkObject() {
		var obj:Dynamic = {};
		Reflect.setField(obj, "name", "world");
		Reflect.setField(obj, "num", 7);
		var json:String = haxe.format.JsonPrinter.print(obj);
		var reparsed:Dynamic = haxe.Json.parse(json);
		t.stringEquals("world", reparsed.name, "print object string field");
		t.intEquals(7, reparsed.num, "print object int field");
	}

	function checkEmptyObject() {
		var obj:Dynamic = {};
		var r = haxe.format.JsonPrinter.print(obj);
		t.stringEquals("{}", r, "print empty object");
	}

	function checkNested() {
		var inner:Dynamic = {};
		Reflect.setField(inner, "b", "deep");
		var obj:Dynamic = {};
		Reflect.setField(obj, "a", inner);
		Reflect.setField(obj, "arr", [10, 20]);
		var json:String = haxe.format.JsonPrinter.print(obj);
		var reparsed:Dynamic = haxe.Json.parse(json);
		t.stringEquals("deep", reparsed.a.b, "print nested object field");
		t.intEquals(10, reparsed.arr[0], "print nested array 0");
		t.intEquals(20, reparsed.arr[1], "print nested array 1");
	}

	function checkPretty() {
		var obj:Dynamic = {};
		Reflect.setField(obj, "x", 1);
		var compact:String = haxe.format.JsonPrinter.print(obj);
		var pretty:String = haxe.format.JsonPrinter.print(obj, null, "  ");
		// Pretty output should be longer than compact
		t.isTrue(pretty.length > compact.length, "pretty output is longer");
		// Should still be valid JSON
		var reparsed:Dynamic = haxe.Json.parse(pretty);
		t.intEquals(1, reparsed.x, "pretty output round-trip");
	}

	function checkPrettyArray() {
		var arr:Array<Dynamic> = [1, 2];
		var compact:String = haxe.format.JsonPrinter.print(arr);
		var pretty:String = haxe.format.JsonPrinter.print(arr, null, "  ");
		// Pretty output should be longer than compact
		t.isTrue(pretty.length > compact.length, "pretty array is longer");
		// Should still be valid JSON
		var reparsed:Dynamic = haxe.Json.parse(pretty);
		t.intEquals(1, reparsed[0], "pretty array round-trip 0");
		t.intEquals(2, reparsed[1], "pretty array round-trip 1");
	}
}
