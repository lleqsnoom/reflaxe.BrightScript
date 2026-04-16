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

	final primitives = ['String', 'Int', 'Float', 'Boolean'];

	public function new(main:brscompiler.BRSCompiler) {
		this.main = main;
	}

	public function compileClassName(classType:ClassType):String {
		return classType.getNameOrNativeName();
	}

	function compileModuleType(m:ModuleType):String {
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

	public function compileAbstractType(type:Type, errorPos:Position, absRef:haxe.macro.Ref<haxe.macro.AbstractType>, params:Array<haxe.macro.Type>):String {
		final abs = absRef.get();
		// Null<T> must compile to Object so BRS accepts invalid values
		if (abs.name == "Null") {
			return "Object";
		}
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
			TypeTools.applyTypeParameters(absType, abs.params, params);
		} #else absType #end;
		if (internalType.isNull()) {
			return null;
		}

		// Prevent recursion...
		if (!internalType.equals(type)) {
			return compileType(internalType, errorPos);
		}
		return null;
	}

	function isTypePrimitive(type:String):Bool {
		return primitives.filter(t -> t == type).length > 0;
	}

	public function compileType(type:Type, errorPos:Position):Null<String> {
		final returnType:String = switch type {
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
		if(returnType == "Void") {
			//TODO: Void is not propper return type. We need to replace function with sub that has no return value.
			return returnType;
		}
		return isTypePrimitive(returnType) ? returnType : 'Object';
	}
}
