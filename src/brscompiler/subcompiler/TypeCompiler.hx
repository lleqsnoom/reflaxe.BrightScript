/**
https://developer.roku.com/docs/references/brightscript/language/expressions-variables-types.md


Types
BrightScript uses dynamic typing. This means that every value also has a type determined at run time. However, BrightScript also supports declared types. This means that a variable can be made to always contain a value of a specific type. If a value is assigned to a variable which has a specific type, the type of the value assigned will be converted to the variables type, if possible. If not possible, a runtime error will result.

The following types are supported in BrightScript:

Boolean – Either true or false.
Integer – A 32-bit signed integer number.
LongInteger – A 64-bit signed integer number. This is available in Roku OS 7.0 or above.
Float – A 32-bit IEEE floating point number.
Double – A 64-bit IEEE floating point number. (Although Double is an intrinsically understood type, it is implemented internally with the roIntrinsicDouble component. This is generally hidden from the developer).
String – A sequence of Unicode characters. Internally there are two intrinsic string states. The first is for constant strings. For example, s="astring", will create an intrinsic constant string. But once a string is used in an expression, it becomes an "roString". For example: s=s+"more", results in s becoming an "roString". If this is followed by an s2=s, s2 will be a reference to s, not a copy.
Object – A reference to a BrightScript component. Note that if you use the "type()" function, you will not get "Object", but instead you will get the type of object. E.g. "roArray", "roAssociativeArray", "roList", "roVideoPlayer", etc. Note that intrinsic array and associative array values correspond to roArray and roAssociativeArray components respectively.
Function – Functions (and Subs, which are functions with void return types) are an intrinsic type. They can be stored in variables and passed to functions.
Interface – An interface in a BrightScript component. If a "dot operator" is used on an interface type, the member must be static (since there is no object context).
Invalid – The type invalid has only one value: invalid. It is returned in various cases, for example, when reading an array element that has never been set.
Dynamic typing – Unless otherwise specified, a variable is dynamically typed. This means that the type is determined by the value assigned to it at assignment time. For example "1" is an integer, "2.3" is a float, "hello" is a string, etc. If a dynamically typed variable is assigned a new value, its type may change. For example: a=4 creates "a" as integer, then a = "hello", changes the variable "a" to a string. All variables are dynamically typed, unless: (a) the variable ends in a type designator character, or (b) the "As" keyword is used in a function declaration with the variable.
Tagging unused variables – Variables can explicitly be marked as unused by prepending an underscore to the value (for example, sub myTask(_x)). This enables avoid compilation errors to occur when an unused variable, for example, has a special behavior or another valid purpose. Unused variables generate warnings that are output to the SceneGraph debug port (8085). The maximum number of warnings that may be generated is 100.



**/

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

	final primitives = ['String', 'Integer', 'Float', 'Boolean'];

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
		// trace("Compiling abstract type: " + abs);
		// Null<T> must compile to Object so BRS accepts invalid values
		if (abs.name == "Null") {
			return 'Object';
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
			return compileType(internalType, errorPos)+'-'+abs;
		}
		
		return null+'-'+abs;
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

		return (isTypePrimitive(returnType) ? returnType : 'Object');
	}
}
