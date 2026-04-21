package brscompiler.subcompiler;

import haxe.macro.Expr;
import haxe.macro.Type;
import reflaxe.data.ClassFuncArg;
import reflaxe.data.ClassFuncData;
import reflaxe.data.ClassVarData;
import reflaxe.data.EnumOptionData;
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
using reflaxe.helpers.StringBufHelper;
using reflaxe.helpers.SyntaxHelper;
using reflaxe.helpers.TypeHelper;
using reflaxe.helpers.TypedExprHelper;

class ClassCompiler {
	var main:brscompiler.BRSCompiler;
	final functionRevervedNames = ["run"];

	public function new(main:brscompiler.BRSCompiler) {
		this.main = main;
	}

	function extractMultilineValue(compiled:String):Null<{prefix:String, value:String}> {
		if (compiled.indexOf('\n') < 0) {
			return null;
		}
		final lines = compiled.split('\n');
		while (lines.length > 0 && lines[lines.length - 1].trim().length == 0) {
			lines.pop();
		}
		if (lines.length == 0) {
			return null;
		}
		final rawLast = lines.pop();
		final last = rawLast.trim();
		final bareExpr = ~/^(?:[A-Za-z_][A-Za-z0-9_]*(?:\.[A-Za-z_][A-Za-z0-9_]*)*|true|false|invalid|-?[0-9]+(?:\.[0-9]+)?)$/;
		if (bareExpr.match(last)) {
			final prefix = lines.join('\n');
			return {
				prefix: prefix.length > 0 ? prefix + '\n' : '',
				value: last
			};
		}
		final assignment = ~/^([A-Za-z_][A-Za-z0-9_]*)\s*=.*$/;
		if (assignment.match(last)) {
			lines.push(rawLast);
			return {
				prefix: lines.join('\n') + '\n',
				value: assignment.matched(1)
			};
		}
		return null;
	}

	public function compileClassImpl(classType:ClassType, varFields:Array<ClassVarData>, funcFields:Array<ClassFuncData>):Null<String> {
		final className = classType.name;
		final pkg = classType.pack;
		final fullPath = main.fullCallPath(classType);
		final classPath = fullPath.join('_');
		final hxName = pkg.length > 0 ? pkg.join('.') + '.' + className : className;

		main.selfStack.push({selfName: classPath, publicOnly: false});

		final body = new StringBuf();
		final global = new StringBuf();

		final staticVariables:Array<ClassVarData> = [];
		final objectVariables:Array<ClassVarData> = [];
		for (v in varFields) {
			final field = v.field;
			if (field.isExtern || field.hasMeta(':extern')) {
				continue;
			} else if (v.isStatic) {
				staticVariables.push(v);
			} else {
				objectVariables.push(v);
			}
		}

		var constructor:ClassFuncData = null;
		final brsGlobalFunctions:Array<ClassFuncData> = [];
		final staticFunctions:Array<ClassFuncData> = [];
		final classFunctions:Array<ClassFuncData> = [];

		for (f in funcFields) {
			final isBrsGlobal = f.field.meta.get().filter(f -> f.name == ':brs_global').length > 0;
			if (isBrsGlobal) {
				brsGlobalFunctions.push(f);
			} else if (f.field.name == 'new') {
				constructor = f;
			} else if (f.isStatic) {
				staticFunctions.push(f);
			} else {
				classFunctions.push(f);
			}
		}

		if (brsGlobalFunctions.length > 0) {
			final globals = brsGlobalFunctions.map(f -> '${createGlobalFunctionDefinition(f)}');
			global.add('${globals.join('\n\n')}\n\n');
		}

		body.add('${Define.Function} ${classPath}() as Object\n');
		final staticPrefixes:Array<String> = [];

		// Collect instance field names for __hx_fields__
		final instanceFieldNames:Array<String> = [];
		for (v in objectVariables) {
			instanceFieldNames.push('"${v.field.name}"');
		}
		for (f in classFunctions) {
			instanceFieldNames.push('"${f.field.name}"');
		}
		final hxFieldsStr = '[${instanceFieldNames.join(", ")}]';
		final hxMetaStr = compileMetaObject(varFields, funcFields);

		if (staticVariables.length > 0) {
			final statics = staticVariables.map(v -> {
				final field = v.field;
				final name = field.name;
				final value = main.FComp.compileInstanceVarValue(v);
				final extracted = extractMultilineValue(value);
				if (extracted != null) {
					if (extracted.prefix.trim().length > 0) {
						staticPrefixes.push(extracted.prefix);
					}
					'$name: ${extracted.value}';
				} else {
					'$name: $value';
				}
			});
			if (staticPrefixes.length > 0) {
				body.add((staticPrefixes.join('\n') + '\n').tab());
			}
			body.add(createClassMeta(hxName, hxFieldsStr, hxMetaStr));
			body.add('${statics.join(',\n')},\n'.tab().tab());
		} else {
			body.add(createClassMeta(hxName, hxFieldsStr, hxMetaStr));
		}

		if (staticFunctions.length > 0) {
			final statics = staticFunctions.map(f -> '${f.field.name}: ${createFunctionDefinition(f)}'.tab());
			body.add('${statics.join(',\n')},\n'.tab());
		}

		if (classFunctions.length > 0) {
			final instanceBody = classFunctions.map(f -> '${createFunctionName(f.field.name)}: ${createFunctionDefinition(f)}'.tab());
			final instanceVars = objectVariables.map(v -> {
				final name = v.field.name;
				final value = main.FComp.compileInstanceVarValue(v);
				'$name: $value'.tab();
			});
			final instanceVarsStr =  instanceVars.length > 0 ? (instanceVars.join(',\n') + ',\n') : '';

			instanceBody.push('${Define.Constructor}: ${createFunctionDefinition(constructor)}'.tab());
			final idGen = 'stri(Rnd(2147483647)) + stri(Rnd(2147483647))';
			final instanceBodyStr = '${Define.Instance} = {\n${Define.InstanceId.tab()}: $idGen,\n$instanceVarsStr${instanceBody.join(',\n\n')}\n}\n'.tab();
			final newFunction = switch constructor {
				case null:
					'${Define.CreateInstance}: ${Define.Function}() as Object\n$instanceBodyStr\n\treturn ${Define.Instance}\n${Define.EndFunction}\n';
				case _:
					final callParams = constructor.args.map(a -> a.getName()).join(', ');
					final callNew = '${Define.Instance}.__static__ = m\n${Define.Instance}.${Define.Constructor}($callParams)'.tab();
					final ret = 'return ${Define.Instance}'.tab();
					'${Define.CreateInstance}: ${createFunctionHeader(constructor, null, null, false, "a")}\n$instanceBodyStr\n$callNew\n$ret\n${Define.EndFunction}\n';
			}
			body.add(newFunction.tab().tab());
		} else if (constructor != null) {
			final instanceVars = objectVariables.map(v -> {
				final field = v.field;
				final name = field.name;
				final value = main.FComp.compileInstanceVarValue(v);
				'$name: $value'.tab();
			});
			final instanceVarsStr = instanceVars.length > 0 ? (instanceVars.join(',\n') + ',\n') : '';
			final callParams = constructor.args.map(a -> a.getName()).join(', ');
			final constructorDef = '${Define.Constructor}: ${createFunctionDefinition(constructor)}'.tab();
			final instanceBodyStr = '${Define.Instance} = {\n$instanceVarsStr$constructorDef\n}\n'.tab();
			final callNew = '${Define.Instance}.__static__ = m\n${Define.Instance}.${Define.Constructor}($callParams)'.tab();
			 
			final ret = 'return ${Define.Instance}'.tab();
			final newFunction = '${Define.CreateInstance}: ${createFunctionHeader(constructor, null, null, false, "b")}\n$instanceBodyStr\n$callNew\n$ret\n${Define.EndFunction}\n';
			body.add(newFunction.tab().tab());
		}

		body.addMulti('}\n'.tab(), '${Define.EndFunction}\n');
		final classStr = (body.toString());
		final globalStr = (global.toString());
		brscompiler.BRSCompiler.saveFileWithDirs('.brs/${fullPath.join('/')}.brs', '$globalStr\n\n$classStr');
		main.setExtraFile('${fullPath.join('/')}.brs', '$globalStr\n\n$classStr');

		return '$globalStr\n\n$classStr';
	}

	function createClassMeta(hxName, hxFieldsStr, hxMetaStr):String{
		final body = new StringBuf();
		body.add('return {\n'.tab());
		body.add('__hx_name__: "${hxName}",\n'.tab().tab());
		body.add('__hx_fields__: ${hxFieldsStr},\n'.tab().tab());
		body.add('__hx_meta__: ${hxMetaStr},\n'.tab().tab());
		return body.toString();
	}

	function compileReturnType(f:ClassFuncData):String {
		final returnType = main.TComp.compileType(f.ret, f.field.pos);
		return returnType != null ? '$returnType' : '';
	}

	function createFunctionHeader(f:ClassFuncData, ?name:String, ?overrideReturnType:String, forceObject:Bool = false, type:String = "x"):String {
		final namePrefix = createFunctionName(name);
		return '${Define.Function} $namePrefix(${compileArgs(f.args, f.field, forceObject)}) as Object';
	}

	function createFunctionHeaderTyped(f:ClassFuncData, ?name:String, ?overrideReturnType:String):String {
		final compiledReturnType = compileReturnType(f);
		final namePrefix = createFunctionName(name);
		return '${Define.Function} $namePrefix(${compileArgs(f.args, f.field)})${compiledReturnType == "Void" ? " as Void" : ""}';
	}

	function createFunctionName(name:String){
		var namePrefix = name != null ? name : '';
		for(name in functionRevervedNames) {
			if (namePrefix == name) {
				return '_$name';
			}
		}
		return namePrefix;
	}

	function createFunctionDefinition(f:ClassFuncData, inject:String = '', returnInstance = false) {

		if (f == null) {
			return null;
		}
		if (f.tfunc == null) {
			return null;
		}
		// final functionHeader = createFunctionHeader(f, null, returnInstance ? ' as Object' : null, true, "c");
		final functionHeader = createFunctionHeaderTyped(f, null, returnInstance ? ' as Object' : null);
		final contextArgs = copyArgsToContext(f);
		final functionBody = '\n$contextArgs\n$inject\n${main.compileClassFuncExpr(f.expr)}'.tab();
		final returnInject = returnInstance ? '\treturn ${Define.Instance}\n' : '';
		return '${debugClassFuncExpr(f.expr)}$functionHeader$functionBody\n${returnInject}${Define.EndFunction}';
	}

	function debugClassFuncExpr(expr: TypedExpr){
		return '';
		return switch expr.expr {
			case TBlock(e): e.map(l -> l).join('\n');
			case _: '__no debug';
		}
	}

	function copyArgsToContext(f:ClassFuncData){
		final ecapsulateCtxArg = (a, p) -> {
			final name = main.compileFunctionArgument(a, p);
			'${Define.Ctx}.$name = $name';
		}
		final args = f.args.map(a -> ecapsulateCtxArg(a, f.field.pos));
		return '${Define.NewCtx}\n${args.join('\n')}';
	}

	function createGlobalFunctionDefinition(f:ClassFuncData) {
		final functionHeader = createFunctionHeaderTyped(f, f.field.name);
		final contextArgs = copyArgsToContext(f);
		final functionBody = '${contextArgs}\n${main.compileClassFuncExpr(f.expr)}'.tab();
		return '$functionHeader\n$functionBody\n${Define.EndFunction}';
	}

	function compileArgs(args, field, forceObject:Bool = false):String {
		final compiledArgs = args.map(a -> main.compileFunctionArgument(a, field.pos, forceObject));
		// for(a in args) {
		// 	trace(a.name + ": " + TypeHelper.toString(a.t));
		// }
		return compiledArgs.join(', ');
	}

	function compileFieldMeta(field:ClassField):Null<String> {
		// final metas = field.meta.get().filter(m -> !StringTools.startsWith(m.name, ':') && m.name != '');

		final metas = field.meta.get();

		if (metas.length == 0)
			return null;

		// trace('Compiling meta for field ${field.name}: ${metas.map(m -> m.name).join(', ')}');
		
		final parts:Array<String> = [];
		for (m in metas) {
			final args = if (m.params != null && m.params.length > 0) {
				final compiledArgs = m.params.map(p -> compileMetaParam(p));
				// trace(m, compiledArgs);
				'[${compiledArgs.join(", ")}]';
			} else {
				'[]';
			}
			parts.push('"${m.name}": $args');
		}
		return '{${parts.join(", ")}}';
	}

	function compileMetaParam(e:{expr:haxe.macro.ExprDef, pos:Dynamic}):String {
		return switch (e.expr) {
			case EConst(CString(s, _)): '"$s"';
			case EConst(CInt(i)): i;
			case EConst(CFloat(f)): f;
			case EConst(CIdent("true")): "true";
			case EConst(CIdent("false")): "false";
			case EConst(CIdent("null")): "invalid";
			case EConst(CIdent(s)): '"$s"';
			default: "invalid";
		}
	}

	function compileMetaObject(varFields:Array<ClassVarData>, funcFields:Array<ClassFuncData>):String {
		final fieldEntries:Array<String> = [];
		final staticEntries:Array<String> = [];

		for (v in varFields) {
			// final meta2 = compileFieldMeta(v.field);
			final meta = "TODO_ADD_META";

			if (meta != null) {
				if (v.isStatic)
					staticEntries.push('"${v.field.name}": "$meta"');
				else
					fieldEntries.push('"${v.field.name}": "$meta"');
			}
		}
		for (f in funcFields) {
			if (f.field.name == 'new')
				continue;
			final meta = compileFieldMeta(f.field);
			// final meta = "TODO_ADD_META";
			if (meta != null) {
				if (f.isStatic)
					staticEntries.push('"${f.field.name}": $meta');
				else
					fieldEntries.push('"${f.field.name}": $meta');
			}
		}

		final fieldsStr = fieldEntries.length > 0 ? '{${fieldEntries.join(", ")}}' : '{}';
		final staticsStr = staticEntries.length > 0 ? '{${staticEntries.join(", ")}}' : '{}';
		return '{"fields": $fieldsStr, "statics": $staticsStr}';
	}
}
