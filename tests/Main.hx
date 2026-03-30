package;

import utest.Runner;
import utest.ui.Report;

class Main {
	public static function main() {
		var runner = new Runner();
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
		Report.create(runner);
		runner.run();
	}
}
