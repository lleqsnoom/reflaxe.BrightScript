package;

import utest.Runner;
import utest.ui.Report;

class Main {
	// var efg = 1;

	// function abc2(xyz){
	// 	xyz();
	// }

	// function abc(){
	// 	var ijk = true;

	// 	function xyz(){
	// 		trace('ijk: $ijk');
	// 		if (ijk == true){
	// 			trace('True');
	// 		}else{
	// 			trace('False');
	// 		}
	// 		ijk = true;
	// 		trace('Done');
	// 	}

	// 	abc2(xyz);
	// 	ijk = false;
	// }

	// function new(){
	// 	abc();
	// } 

	public static function main() {
		// final newBcd = new Bcd();
		// newBcd.abc();

		// new Main();

		var runner = new Runner();
		trace("Adding test cases...");
		runner.addCase(new LanguageTests());
		runner.addCase(new ArrayTests());
		runner.addCase(new StringTests());
		runner.addCase(new MathTests());
		runner.addCase(new StringBufTests());
		runner.addCase(new StringToolsTests());
		runner.addCase(new MapTests());
		runner.addCase(new DateTests());
		runner.addCase(new DateToolsTests());
		runner.addCase(new ERegTests());
		runner.addCase(new ReflectTests());
		runner.addCase(new TypeTests());
		runner.addCase(new LambdaTests());
		runner.addCase(new ListTests());
		runner.addCase(new XmlTests());
		runner.addCase(new ExceptionTests());
		runner.addCase(new JsonTests());
		runner.addCase(new JsonPrinterTests());
		runner.addCase(new BytesTests());
		runner.addCase(new TimerTests());
		runner.addCase(new SerializerTests());
		runner.addCase(new HttpTests());
		runner.addCase(new CryptoTests());
		runner.addCase(new CallStackTests());
		runner.addCase(new MetaTests());
		final report = Report.create(runner, AlwaysShowSuccessResults, AlwaysShowHeader);
		trace("Running tests...");
		runner.run();
		trace("All tests complete.");
	}
}


class Abc{
	public function new(){
		trace('Abc -> new');
	}
	public function abc(){
		trace('Abc -> abc');
	}
	function xyz(){
		trace('Abc -> ayz');
	}
}

class Bcd extends Abc{
	public function new(){
		trace('Bcd -> new');
		super();
	}
	override public function abc(){
		trace('Bcd -> abc');
		super.abc();
		xyz();
	}
} 