package;

import Main.Colors;
import Main.MapKey;

class TypeTests {
	var t:Main;

	public function new(main:Main) {
		t = main;
	}

	public function run() {
		t.section("Type.typeof");
		checkTypeof();
		t.section("Type.enumIndex");
		checkEnumIndex();
		t.section("Type.enumEq");
		checkEnumEq();
		t.section("Type.enumParameters");
		checkEnumParameters();
		t.section("Type.getClass");
		checkGetClass();
		t.section("Type.getClassFields");
		checkGetClassFields();
		t.section("Type.createInstance");
		checkCreateInstance();
		t.section("Type.createEnumIndex");
		checkCreateEnumIndex();
		t.section("Type.stubs");
		checkStubs();
	}

	function checkTypeof() {
		// TNull = 0
		t.intEquals(0, Type.enumIndex(Type.typeof(null)), "typeof null → TNull");

		// TInt = 1
		t.intEquals(1, Type.enumIndex(Type.typeof(42)), "typeof int → TInt");

		// TFloat = 2
		t.intEquals(2, Type.enumIndex(Type.typeof(3.14)), "typeof float → TFloat");

		// TBool = 3
		t.intEquals(3, Type.enumIndex(Type.typeof(true)), "typeof bool → TBool");

		// TFunction = 5
		var fn = function() return 1;
		t.intEquals(5, Type.enumIndex(Type.typeof(fn)), "typeof function → TFunction");

		// TClass = 6 for strings
		t.intEquals(6, Type.enumIndex(Type.typeof("hello")), "typeof string → TClass");

		// TClass = 6 for arrays
		t.intEquals(6, Type.enumIndex(Type.typeof([1, 2, 3])), "typeof array → TClass");

		// TEnum = 7 for enum values
		var red:Dynamic = Colors.Red;
		t.intEquals(7, Type.enumIndex(Type.typeof(red)), "typeof enum → TEnum");

		// TObject = 4 for plain AA
		var obj:Dynamic = {};
		t.intEquals(4, Type.enumIndex(Type.typeof(obj)), "typeof object → TObject");

		// TClass = 6 for class instances
		var inst = new MapKey(5);
		var instDyn:Dynamic = inst;
		t.intEquals(6, Type.enumIndex(Type.typeof(instDyn)), "typeof class instance → TClass");

		// Verify typeof with enumIndex comparison
		var boolIdx = Type.enumIndex(Type.typeof(false));
		t.intEquals(3, boolIdx, "typeof false → TBool index");
	}

	function checkEnumIndex() {
		t.intEquals(0, Type.enumIndex(Colors.Red), "enumIndex Red = 0");
		t.intEquals(1, Type.enumIndex(Colors.Green), "enumIndex Green = 1");
		t.intEquals(2, Type.enumIndex(Colors.Blue), "enumIndex Blue = 2");
	}

	function checkEnumEq() {
		// Same enum values
		t.isTrue(Type.enumEq(Colors.Red, Colors.Red), "enumEq Red Red");
		t.isTrue(Type.enumEq(Colors.Blue, Colors.Blue), "enumEq Blue Blue");

		// Different enum values
		t.isFalse(Type.enumEq(Colors.Red, Colors.Blue), "enumEq Red Blue");
		t.isFalse(Type.enumEq(Colors.Green, Colors.Red), "enumEq Green Red");

		// Null comparisons
		t.isTrue(Type.enumEq(null, null), "enumEq null null");
		t.isFalse(Type.enumEq(Colors.Red, null), "enumEq Red null");
		t.isFalse(Type.enumEq(null, Colors.Blue), "enumEq null Blue");
	}

	function checkEnumParameters() {
		// Simple enums (no parameters) return empty array
		var params = Type.enumParameters(Colors.Red);
		t.intEquals(0, params.length, "enumParameters Red empty");

		var params2 = Type.enumParameters(Colors.Blue);
		t.intEquals(0, params2.length, "enumParameters Blue empty");
	}

	function checkGetClass() {
		// Class instance returns non-null
		var inst = new MapKey(10);
		var cls = Type.getClass(inst);
		var hasClass = cls != null;
		t.isTrue(hasClass, "getClass MapKey not null");

		// Non-class returns null
		var noClass = Type.getClass(42);
		t.isTrue(noClass == null, "getClass int is null");

		var noClass2 = Type.getClass("hello");
		t.isTrue(noClass2 == null, "getClass string is null");
	}

	function checkGetClassFields() {
		// LanguageTests has static fields: STATIC_ARR, STATIC_COUNTER
		var inst = new LanguageTests(t);
		var cls = Type.getClass(inst);
		var hasClass = cls != null;
		t.isTrue(hasClass, "getClassFields: got class");

		if (cls != null) {
			var fields = Type.getClassFields(cls);
			var hasFields = fields.length > 0;
			t.isTrue(hasFields, "getClassFields: has fields");
		}
	}

	function checkCreateInstance() {
		// Create a MapKey instance dynamically
		var inst = new MapKey(1);
		var cls = Type.getClass(inst);
		var hasClass = cls != null;
		t.isTrue(hasClass, "createInstance: got class");

		if (cls != null) {
			var newInst:Dynamic = Type.createInstance(cls, [99]);
			var hasNewInst = newInst != null;
			t.isTrue(hasNewInst, "createInstance: created");
			if (hasNewInst == true) {
				t.intEquals(99, Reflect.field(newInst, "id"), "createInstance: field value");
			}
		}
	}

	function checkCreateEnumIndex() {
		// Create enum by index (simple, no params)
		var e:Dynamic = Type.createEnumIndex(null, 0);
		t.intEquals(0, Type.enumIndex(e), "createEnumIndex 0");

		var e2:Dynamic = Type.createEnumIndex(null, 2);
		t.intEquals(2, Type.enumIndex(e2), "createEnumIndex 2");

		// Created enum should enumEq with original
		t.isTrue(Type.enumEq(e, Colors.Red), "createEnumIndex 0 eq Red");
		t.isTrue(Type.enumEq(e2, Colors.Blue), "createEnumIndex 2 eq Blue");
		t.isFalse(Type.enumEq(e, Colors.Blue), "createEnumIndex 0 neq Blue");
	}

	function checkStubs() {
		// Methods that return null/empty due to BRS limitations
		var sc = Type.getSuperClass(null);
		t.isTrue(sc == null, "getSuperClass null");

		var rc = Type.resolveClass("Main");
		t.isTrue(rc == null, "resolveClass null");

		var re = Type.resolveEnum("Colors");
		t.isTrue(re == null, "resolveEnum null");

		var ae = Type.allEnums(null);
		t.intEquals(0, ae.length, "allEnums empty");

		var ec = Type.getEnumConstructs(null);
		t.intEquals(0, ec.length, "getEnumConstructs empty");

		var ge = Type.getEnum(Colors.Red);
		t.isTrue(ge == null, "getEnum null");

		var gen = Type.getEnumName(null);
		t.isTrue(gen == null, "getEnumName null");
	}
}
