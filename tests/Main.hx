package;

import utest.Runner;
import utest.ui.Report;

class Main {
	var efg = 1;

	function abc2(xyz){
		xyz();
	}

	function abc(){
		var ijk;

		function xyz(){
			final x = 1;
			// abc2();
			efg++;
			if (ijk == true){
				var p = 0;
			}
			ijk = true;
			trace('Done');
		}

		ijk = false;
		abc2(xyz);
	}

	function new(){
		efg++;
		abc();
	} 

	public static function main() {
		new Main();

		// var runner = new Runner();
		// trace("Adding test cases...");
		// runner.addCase(new LanguageTests());
		// runner.addCase(new ArrayTests());
		// runner.addCase(new StringTests());
		// runner.addCase(new MathTests());
		// runner.addCase(new StringBufTests());
		// runner.addCase(new StringToolsTests());
		// runner.addCase(new MapTests());
		// runner.addCase(new DateTests());
		// runner.addCase(new DateToolsTests());
		// runner.addCase(new ERegTests());
		// runner.addCase(new ReflectTests());
		// runner.addCase(new TypeTests());
		// runner.addCase(new LambdaTests());
		// runner.addCase(new ListTests());
		// runner.addCase(new XmlTests());
		// runner.addCase(new ExceptionTests());
		// runner.addCase(new JsonTests());
		// runner.addCase(new JsonPrinterTests());
		// runner.addCase(new BytesTests());
		// runner.addCase(new TimerTests());
		// runner.addCase(new SerializerTests());
		// runner.addCase(new HttpTests());
		// runner.addCase(new CryptoTests());
		// runner.addCase(new CallStackTests());
		// runner.addCase(new MetaTests());
		// Report.create(runner);
		// trace("Running tests...");
		// runner.run();
		// trace("All tests complete.");
	}
}
