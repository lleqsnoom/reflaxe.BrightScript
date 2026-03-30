package;

using Std;

class Main {
	// Assert fields
	var _passed:Int = 0;
	var _failed:Int = 0;
	var _section:String = "";

	public static function main() {
		new Main();
	}

	public function new() {
		new LanguageTests(this).run();
		new ArrayTests(this).run();
		new StringTests(this).run();
		new MathTests(this).run();
		new StringBufTests(this).run();
		new StringToolsTests(this).run();
		new MapTests(this).run();
		new DateTests(this).run();
		new DateToolsTests(this).run();
		new ERegTests(this).run();
		new ReflectTests(this).run();
		new TypeTests(this).run();
		new LambdaTests(this).run();
		new ListTests(this).run();
		new XmlTests(this).run();
		new ExceptionTests(this).run();
		new JsonTests(this).run();
		new JsonPrinterTests(this).run();
		new BytesTests(this).run();
		new TimerTests(this).run();
		new SerializerTests(this).run();
		new HttpTests(this).run();
		new CryptoTests(this).run();
		new CallStackTests(this).run();
		new MetaTests(this).run();
		new SysTests(this).run();
		report();
	}

	// --- Assert helpers ---

	public function section(name:String):Void {
		_section = name;
		trace("---- " + name + " ----");
	}

	public function isTrue(actual:Dynamic, msg:String):Void {
		if (actual == true)
			_passed++;
		else {
			_failed++;
			trace("[FAIL] " + _section + " > " + msg);
		}
	}

	public function isFalse(actual:Dynamic, msg:String):Void {
		if (actual == false)
			_passed++;
		else {
			_failed++;
			trace("[FAIL] " + _section + " > " + msg + " (expected false)");
		}
	}

	public function stringEquals(expected:String, actual:String, msg:String):Void {
		if (expected == actual)
			_passed++;
		else {
			_failed++;
			trace("[FAIL] " + _section + " > " + msg + " | expected: '" + expected + "' | got: '" + actual + "'");
		}
	}

	public function intEquals(expected:Int, actual:Int, msg:String):Void {
		if (expected == actual)
			_passed++;
		else {
			_failed++;
			trace("[FAIL] " + _section + " > " + msg + " | expected " + expected + ", got " + actual);
		}
	}

	public function floatNear(expected:Float, actual:Float, msg:String):Void {
		var diff = expected - actual;
		if (diff < 0)
			diff = -diff;
		if (diff < 0.001)
			_passed++;
		else {
			_failed++;
			trace("[FAIL] " + _section + " > " + msg + " | expected " + expected + ", got " + actual);
		}
	}

	public function report():Void {
		var total = _passed + _failed;
		trace("==========================================");
		trace("TEST RESULTS: " + _passed + "/" + total + " passed");
		if (_failed > 0)
			trace("FAILURES: " + _failed);
		else
			trace("ALL TESTS PASSED");
		trace("==========================================");
	}
}

class MapKey {
	public var id:Int;

	public function new(val:Int) {
		this.id = val;
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
