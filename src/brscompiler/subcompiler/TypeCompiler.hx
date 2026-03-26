package brscompiler.subcompiler;

import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.TypeTools;
import reflaxe.BaseCompiler;
import reflaxe.compiler.NullTypeEnforcer;
import reflaxe.data.ClassFuncData;
import reflaxe.data.ClassVarData;
import reflaxe.helpers.Context;

using reflaxe.helpers.ArrayHelper;
using reflaxe.helpers.BaseTypeHelper;
using reflaxe.helpers.ClassFieldHelper;
using reflaxe.helpers.ClassTypeHelper;
using reflaxe.helpers.ModuleTypeHelper;
using reflaxe.helpers.NameMetaHelper;
using reflaxe.helpers.NullHelper;
using reflaxe.helpers.NullableMetaAccessHelper;
using reflaxe.helpers.OperatorHelper;
using reflaxe.helpers.StringBufHelper;
using reflaxe.helpers.SyntaxHelper;
using reflaxe.helpers.TypeHelper;
using reflaxe.helpers.TypedExprHelper;

class TypeCompiler {
	var main:brscompiler.BRSCompiler;

	static final types = [
		'String' => 'String',
		'Int' => 'Integer',
		'Float' => 'Float',
		'Bool' => 'Boolean'
	];

	final primitives = ['String', 'Int', 'Float', 'Bool'];

	public function new(main:brscompiler.BRSCompiler) {
		this.main = main;
	}

	public function compileClassName(classType:ClassType):String {
		return classType.getNameOrNativeName();
	}

	function compileModuleType(m:ModuleType):String {
		// trace("compileModuleType: " + m);
		return switch (m) {
			case TClassDecl(clsRef): {
					compileClassName(clsRef.get());
				}
			case TEnumDecl(enmRef): {
					final e = enmRef.get();
					if (e.isReflaxeExtern()) {
						trace("Reflaxe extern enum: " + e.getNameOrNativeName());
						e.pack.joinAppend(".") + e.getNameOrNativeName();
					} else {
						"Dictionary";
					}
				}
			case _: m.getNameOrNative();
		}
	}

	public function compileAbstractType(type:Type, errorPos:Position, absRef:haxe.macro.Ref<haxe.macro.AbstractType>, params:Array<haxe.macro.Type>) {
		final abs = absRef.get();

		final primitiveResult = if (params.length == 0) {
			switch (abs.name) {
				case "String": "String";
				case "Int": "Integer";
				case "Float": "Float";
				case "Bool": "Boolean";
				case "Void": "Void";
				case _: null;
			}
		} else {
			null;
		}

		if (primitiveResult != null) {
			return primitiveResult;
		}
		final absType = abs.type;
		final internalType = #if macro {
			// trace("applyTypeParameters: " + absType + ", " + abs.params + ", " + params);
			TypeTools.applyTypeParameters(absType, abs.params, params);
		} #else absType #end;
		// // If Null<T>, must be Variant since built-in types cannot be assigned `null`.
		if (internalType.isNull()) {
			return null;
		}

		// Prevent recursion...
		if (!internalType.equals(type)) {
			trace(compileType(internalType, errorPos));
			return compileType(internalType, errorPos);
		}
		return null;
	}

	function isTypePrimitive(type:String):Bool {
		return primitives.filter(t -> t == type).length > 0;
	}

	public function compileType(type:Type, errorPos:Position):Null<String> {
		final returnType = switch type {
			case TAbstract(absRef, params): compileAbstractType(type, errorPos, absRef, params);
			case TInst(clsRef, _): compileModuleType(TClassDecl(clsRef));
			case TDynamic(_): 'Object';
			case TAnonymous(_): 'Object';
			case TFun(_, _): null;
			case _ if (type.isTypeParameter()): null;
			case TEnum(enmRef, _): compileModuleType(TEnumDecl(enmRef));
			case TType(defRef, _): compileType(defRef.get().type, errorPos);
			case TMono(typeRef):
				final tref = typeRef.get();
				tref != null ? compileType(tref, errorPos) : null;

			case _: null;
		}

		return isTypePrimitive(returnType) ? returnType : 'Object';
	}
}
