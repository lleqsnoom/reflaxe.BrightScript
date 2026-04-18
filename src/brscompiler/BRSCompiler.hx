package brscompiler;

// Make sure this code only exists at compile-time.
#if (macro || brs_runtime)
// Import relevant Haxe macro types.
import brscompiler.subcompiler.ClassCompiler;
import brscompiler.subcompiler.ExpressionCompiler;
import brscompiler.subcompiler.FieldAccessCompiler;
import brscompiler.subcompiler.FieldCompiler;
import brscompiler.subcompiler.TypeCompiler;
import haxe.macro.Expr;
import haxe.macro.Type;
import reflaxe.DirectToStringCompiler;
import reflaxe.data.ClassFuncArg;
import reflaxe.data.ClassFuncData;
import reflaxe.data.ClassVarData;
import reflaxe.data.EnumOptionData;
import reflaxe.helpers.Context;
import sys.FileSystem;
import sys.io.File;
import brscompiler.config.Define;

using StringTools;
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

class BRSCompiler extends DirectToStringCompiler {
	public final selfStack:Array<{selfName:String, publicOnly:Bool}> = [];
	public final compilingInConstructor:Bool = false;

	public final TComp:TypeCompiler;
	final EComp:ExpressionCompiler;
	final CComp:ClassCompiler;
	final FAComp:FieldAccessCompiler;
	public final FComp:FieldCompiler;

	public function new() {
		super();
		TComp = new TypeCompiler(this);
		EComp = new ExpressionCompiler(this);
		CComp = new ClassCompiler(this);
		FAComp = new FieldAccessCompiler(this);
		FComp = new FieldCompiler(this);
	}

	public static function saveFileWithDirs(filePath:String, content:String):Void {
		// Find the last slash (Unix or Windows style)
		final slashIndex = Math.max(filePath.lastIndexOf("/"), filePath.lastIndexOf("\\"));

		// Extract the directory portion from the filePath (if any)
		final directory = if (slashIndex == -1) "" else filePath.substr(0, Std.int(slashIndex));

		// Create the directory structure if not empty (and doesn't already exist)
		if (directory != "" && !FileSystem.exists(directory)) {
			FileSystem.createDirectory(directory);
		}

		// Now write the file content
		File.saveContent(filePath, content);
	}

	public function compileClassImpl(classType:ClassType, varFields:Array<ClassVarData>, funcFields:Array<ClassFuncData>):Null<String> {
		return CComp.compileClassImpl(classType, varFields, funcFields);
	}

	public function compileFunctionArgument(arg:ClassFuncArg, pos:Position, forceObject:Bool = false) {
		final result = new StringBuf();
		result.add(compileVarName(arg.getName()));

		if (forceObject) {
			// TODO: Implement proper type-based coercion
			// result.addMulti(' as ', 'Object');
		} else {
			final type = TComp.compileType(arg.type, pos);

			if (type != null) {
				// TODO: Implement proper type-based coercion
				// result.addMulti(' as ', type);
			}
		}

		return result.toString();
	}

	public function compileEnumImpl(enumType:EnumType, constructs:Array<EnumOptionData>):Null<String> {
		return null;
	}

	public function fieldAccessToBrightScript(e:TypedExpr, fa:FieldAccess):String {
		return FAComp.fieldAccessToBrightScript(e, fa);
	}

	public function fieldAccessToBrightScriptResolved(resolvedExpr:String, e:TypedExpr, fa:FieldAccess):String {
		return FAComp.fieldAccessToBrightScriptResolved(resolvedExpr, e, fa);
	}

	public function fullCallPath(cls:ClassType) {
		final className = cls.name;
		final pkg = cls.pack;
		final fullPath:Array<String> = pkg.copy();
		fullPath.push(className);
		return fullPath;
	}

	public function compileExpressionImpl(expr:TypedExpr, topLevel:Bool):Null<String> {
		return EComp.compileExpressionImpl(expr, topLevel);
	}

	override public function compileVarName(name: String, expr: Null<TypedExpr> = null, field: Null<ClassField> = null): String {
		if(name == "isSync"){
			trace('================>' + name, expr);
		}
		// return super.compileVarName(name, expr, field);
		if(reservedVarNameMap != null) {
			while(reservedVarNameMap.exists(name)) {
				name = "_" + name;
			}
		}
		return '$name';
	}

	override function onOutputComplete() {
		final outputFile = Context.getDefines().get("brightscript-output");
		var content = sys.io.File.getContent(outputFile);
		// Generate __callFnN__ helpers for bound closure dispatch.
		// These check if a function value is a bound method wrapper (AA with .call)
		// and call through .call() to preserve the `m` context binding.
		var helpers = new StringBuf();
		for (arity in 0...6) {
			helpers.add('function ${Define.FnCall(arity)}(${Define.Ctx} as Object, fn as Object');
			for (i in 0...arity) {
				helpers.add(', a$i as Object');
			}
			helpers.add(') as Object\n');

			helpers.add('if Type(fn) = "roAssociativeArray" AND fn.__self <> invalid then return fn.call(');
			for (i in 0...arity) {
				if (i > 0) helpers.add(', ');
				helpers.add('a$i');
			}
			helpers.add('${arity > 0 ? ", " : ""}fn.__self)');

			helpers.add('\nif Type(fn) = "roAssociativeArray" AND fn.${Define.Ctx} <> invalid then return fn.call(fn.${Define.Ctx}');
			for (i in 0...arity) {
				if (i > 0) helpers.add(', ');
				helpers.add('a$i');
			}
			helpers.add(')');

			helpers.add('\nreturn fn(${Define.Ctx}');
			for (i in 0...arity) {
				helpers.add(', ');
				helpers.add('a$i');
			}
			helpers.add(')\nend function\n\n');
		}

		sys.io.File.saveContent(outputFile, helpers.toString() + content + "\n\n\nMain().main()");
	}
}
#end
