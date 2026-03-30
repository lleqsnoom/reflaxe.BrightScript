package brscompiler.subcompiler;

import haxe.macro.Type;
import reflaxe.data.ClassVarData;

using reflaxe.helpers.ClassFieldHelper;
using reflaxe.helpers.TypeHelper;

class FieldCompiler {
	var main:brscompiler.BRSCompiler;

	public function new(main:brscompiler.BRSCompiler) {
		this.main = main;
	}

	public function compileInstanceVarValue(v:ClassVarData):String {
		final field = v.field;
		final e = field.expr() ?? v.findDefaultExpr();

		if (e != null) {
			return main.compileClassVarExpr(e);
		}

		return defaultValueForType(field.type);
	}

	function defaultValueForType(type:Type):String {
		return switch type {
			case TAbstract(absRef, params):
				final abs = absRef.get();
				if (abs.name == "Null") {
					"invalid";
				} else {
					switch (abs.name) {
						case "Bool": "false";
						case "Int": "0";
						case "Float": "0.0";
						case "Map": "{}";
						case _: "invalid";
					}
				}
			case TInst(clsRef, _):
				final cls = clsRef.get();
				switch (cls.name) {
					case "String": '""';
					case "Array", "List": "[]";
					case "StringMap", "IntMap", "ObjectMap", "EnumValueMap": "{}";
					case _: "invalid";
				}
			case TType(defRef, _):
				defaultValueForType(defRef.get().type);
			case TMono(typeRef):
				final tref = typeRef.get();
				tref != null ? defaultValueForType(tref) : "invalid";
			case _:
				"invalid";
		}
	}
}
