package brscompiler;

// Make sure this code only exists at compile-time.
#if (macro || brs_runtime)
// Import relevant Haxe macro types.
import brscompiler.config.Meta;
import brscompiler.subcompiler.TypeCompiler;
import haxe.display.Display.MetadataTarget;
import haxe.macro.Expr;
import haxe.macro.Type;
import reflaxe.DirectToStringCompiler;
import reflaxe.data.ClassFuncArg;
import reflaxe.data.ClassFuncData;
import reflaxe.data.ClassVarData;
import reflaxe.data.EnumOptionData;
import reflaxe.helpers.Context;
import reflaxe.helpers.OperatorHelper;
import reflaxe.preprocessors.implementations.everything_is_expr.EverythingIsExprSanitizer;
import sys.FileSystem;
import sys.io.File;

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
	var selfStack:Array<{selfName:String, publicOnly:Bool}> = [];
	var compilingInConstructor:Bool = false;
	var depth = 0;
	var debug = false;

	var TComp:TypeCompiler;

	public function new() {
		super();
		TComp = new TypeCompiler(this);
	}

	public static function saveFileWithDirs(filePath:String, content:String):Void {
		// Find the last slash (Unix or Windows style)
		var slashIndex = Math.max(filePath.lastIndexOf("/"), filePath.lastIndexOf("\\"));

		// Extract the directory portion from the filePath (if any)
		var directory = if (slashIndex == -1) "" else filePath.substr(0, Std.int(slashIndex));

		// Create the directory structure if not empty (and doesn't already exist)
		if (directory != "" && !FileSystem.exists(directory)) {
			FileSystem.createDirectory(directory);
		}

		// Now write the file content
		File.saveContent(filePath, content);
	}

	public function compileClassImpl(classType:ClassType, varFields:Array<ClassVarData>, funcFields:Array<ClassFuncData>):Null<String> {
		final variables = [];
		final functions = [];
		final isWrapper = classType.hasMeta(Meta.Wrapper);
		final isWrapPublicOnly = classType.hasMeta(Meta.WrapPublicOnly);

		final className = classType.name;
		final pkg = classType.pack;
		final fullPath = fullCallPath(classType);
		final classPath = fullPath.join('_');

		selfStack.push({selfName: classPath, publicOnly: false});

		final body = new StringBuf();
		final global = new StringBuf();
		final clsMeta = compileMetadata(classType.meta, MetadataTarget.Class);
		final ConstructorName = 'CreateInstance';

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

		body.add('function ${classPath}() as Object\n');
		body.add('return {\n'.tab());

		if (staticVariables.length > 0) {
			final statics = staticVariables.map(v -> {
				final field = v.field;
				final name = field.name;
				final e = field.expr() ?? v.findDefaultExpr();
				final value = e == null ? '' : compileClassVarExpr(e);
				'$name: $value';
			});
			body.add('${statics.join(',\n')},\n'.tab().tab());
		}

		if (staticFunctions.length > 0) {
			final statics = staticFunctions.map(f -> '${f.field.name}: ${createFunctionDefinition(f)}'.tab());
			body.add('${statics.join(',\n')},\n'.tab());
		}

		if (classFunctions.length > 0) {
			final instanceBody = classFunctions.map(f -> '${f.field.name}: ${createFunctionDefinition(f)}'.tab());
			final instanceVars = objectVariables.map(v -> {
				final field = v.field;
				final name = field.name;
				final e = field.expr() ?? v.findDefaultExpr();
				final value = e == null ? '' : compileClassVarExpr(e);
				'$name: $value'.tab();
			});
			final instanceVarsStr = instanceVars.length > 0 ? (instanceVars.join(',\n') + ',\n') : '';

			instanceBody.push('constructor: ${createFunctionDefinition(constructor)}'.tab());
			final instanceBodyStr = 'instance = {\n$instanceVarsStr${instanceBody.join(',\n\n')}\n}\n'.tab();
			final newFunction = switch constructor {
				case null:
					'1- $ConstructorName: function() as Object\n$instanceBodyStr\n\treturn instance\nend function\n';
				case _:
					final callParams = constructor.args.map(a -> a.getName()).join(', ');
					final callNew = 'instance.__static__ = m\ninstance.constructor($callParams)'.tab();
					final ret = 'return instance'.tab();
					'$ConstructorName: ${createFunctionHeader(constructor)}\n$instanceBodyStr\n$callNew\n$ret\nend function\n';
			}
			body.add(newFunction.tab().tab());
		} else if (constructor != null) {
			body.add('$ConstructorName: ${createFunctionDefinition(constructor)}\n');
		}

		body.addMulti('}\n'.tab(), 'end function\n');
		// final classStr = filterConsecutiveEmptyLines(body.toString());
		// final globalStr = filterConsecutiveEmptyLines(global.toString());
		final classStr = (body.toString());
		final globalStr = (global.toString());
		// trace('File ====> ${fullPath.join('/')}.brs');
		saveFileWithDirs('.brs/${fullPath.join('/')}.brs', '$globalStr\n\n$classStr');
		setExtraFile('${fullPath.join('/')}.brs', '$globalStr\n\n$classStr');

		return '$globalStr\n\n$classStr';
	}

	function createFunctionHeader(f:ClassFuncData):String {
		final returnType = TComp.compileType(f.ret, f.field.pos);
		final compiledReturnType = returnType != null ? ' as $returnType' : '';
		return 'function(${compileArgs(f.args, f.field)})$compiledReturnType';
	}

	function createFunctionDefinition(f:ClassFuncData, inject:String = '', returnInstance = false) {
		// f.tfunc.expr:
		// ${f.tfunc.expr}
		if (f == null) {
			// trace('===========> Function definition is null');
			return null;
		}
		if (f.tfunc == null) {
			// trace('===========> Function definition is null');
			return null;
			Sys.println('classType: ${f.classType}\nargs: ${f.args}\nproperty: ${f.property}\nexpr: ${f.expr}');
		}
		final returnType = TComp.compileType(f.ret, f.field.pos);
		var compiledReturnType = returnType != null ? ' as $returnType' : '';
		if (returnInstance) {
			compiledReturnType = ' as Object';
		}
		final functionHeader = 'function(${compileArgs(f.args, f.field)})$compiledReturnType';
		final functionBody = '$inject\n${compileClassFuncExpr(f.tfunc.expr)}'.tab();
		final returnInject = returnInstance ? '\treturn instance\n' : '';
		return '$functionHeader\n$functionBody\n${returnInject}end function';
	}

	function createGlobalFunctionDefinition(f:ClassFuncData) {
		final returnType = TComp.compileType(f.ret, f.field.pos);
		var compiledReturnType = returnType != null ? ' as $returnType' : '';
		final functionHeader = 'function ${f.field.name}(${compileArgs(f.args, f.field)})$compiledReturnType';
		final functionBody = '${compileClassFuncExpr(f.tfunc.expr)}'.tab();
		return '$functionHeader\n$functionBody\nend function';
	}

	public static function _filterConsecutiveEmptyLines(code:String):String {
		var lines = code.split('\n');
		var out = new Array<String>();
		for (line in lines) {
			if (line.trim() == '') {
				continue;
			} else {
				out.push(line);
			}
		}
		return out.join('\n');
	}

	function compileArgs(args, field):String {
		final compiledArgs = args.map(a -> compileFunctionArgument(a, field.pos));
		return compiledArgs.join(', ');
	}

	function compileFunctionArgument(arg:ClassFuncArg, pos:Position) {
		final result = new StringBuf();
		result.add(arg.getName());

		final type = TComp.compileType(arg.type, pos);

		if (type != null) {
			result.addMulti(' as ', type);
		}

		if (arg.expr != null) {
			// final valueCode = compileExpression(arg.expr);
			// if (valueCode != null) {
			// 	result.addMulti(" = ", valueCode);
			// }
		}

		return result.toString();
	}

	public function compileEnumImpl(enumType:EnumType, constructs:Array<EnumOptionData>):Null<String> {
		return null;
	}

	function constantToBrightScript(constant:TConstant):String {
		return switch (constant) {
			case TInt(i): Std.string(i);
			case TFloat(s): s;
			case TString(s):
				final escapeMap = [
					"\n" => "\\n", // Newline
					"\t" => "\\t", // Tab
					"\r" => "\\r", // Carriage return
					"\u0008" => "\\b", // Backspace
					"\u000C" => "\\f", // Form feed
					"\u000B" => "\\v", // Vertical tab
					"\u0000" => "\\0", // Null character
					"\"" => "\\\"", // Double quote
					"\'" => "\\'", // Single quote
					"\\" => "\\\\" // Backslash
				];
				var str = s;
				for (key => value in escapeMap) {
					str = str.replace(key, value);
				}

				'"$str"';
			case TBool(b): b ? 'true' : 'false';
			case TNull: 'invalid';
			case TThis: selfStack.length > 0 ? selfStack[selfStack.length - 1].selfName : 'm';
			case TSuper: 'TODO SUPER';
			case _: 'TODO CONSTANT';
		}
	}

	function getExprType(te:Type) {
		return switch (te) {
			case TType(t, _): '$t';
			case TAbstract(type, []):
				switch type.get().type {
					case TAbstract(type, _):
						switch type.get().name {
							case 'String': 'String';
							case 'Int': 'Int';
							case 'Float': 'Float';
							case 'Bool': 'Bool';
							case 'Void': 'Void';
							case _: getExprType(type.get().type);
						}
					case _: 'Unknown getExprType';
				};
			case TInst(cls, []): '$cls';
			case _: 'Unknown getExprType';
		}
	}

	inline function checkForPrimitiveStringAddition(strExpr:TypedExpr, primExpr:TypedExpr, expr1, expr2) {
		final strIsString = getExprType(strExpr.t) == 'String';
		final primIsPrimitive = ['Int', 'Float', 'Bool'].contains(getExprType(primExpr.t));
		return strIsString && primIsPrimitive;
	}

	function binopToBrightScript(op:Binop, e1:TypedExpr, e2:TypedExpr):String {
		var expr1 = compileExpression(e1);
		var expr2 = compileExpression(e2);
		final operatorStr = OperatorHelper.binopToString(op);

		if (op.isAddition()) {
			if (checkForPrimitiveStringAddition(e1, e2, expr1, expr2))
				expr2 = 'Str($expr2)';
			if (checkForPrimitiveStringAddition(e2, e1, expr1, expr2))
				expr1 = 'Str($expr1)';
		}

		return '$expr1 $operatorStr $expr2';
	}

	function fieldAccessToBrightScript(e:TypedExpr, fa:FieldAccess):String {
		final cl = switch (e.t) {
			case TType(clsRef, _): clsRef.get();
			case _: null;
		}

		final nameMeta:NameAndMeta = switch (fa) {
			case FInstance(_, _, classFieldRef): classFieldRef.get();
			case FStatic(_, classFieldRef): classFieldRef.get();
			case FAnon(classFieldRef): classFieldRef.get();
			case FClosure(_, classFieldRef): classFieldRef.get();
			case FEnum(_, enumField): enumField;
			case FDynamic(s): {name: s, meta: null};
		}

		// trace('===========> Compiling field access: ${nameMeta.name}');

		final name = compileVarName(nameMeta.getNameOrNativeName());
		var bypassSelf = false;

		if (nameMeta.hasMeta(':native')) {
			return nameMeta.getNameOrNative();
		}
		if (nameMeta.hasMeta(':nativeName')) {
			return compileVarName(nameMeta.getNameOrNativeName());
		}

		// trace('===========> Compiling field access: ${name}');

		switch (fa) {
			// Check if this is a self.field with BypassWrapper
			case FInstance(clsRef, _, clsFieldRef) if (selfStack.length > 0):
				{
					final isSelfAccess = switch (e.expr) {
						case TConst(TThis): true;
						case _: false;
					}
					if (isSelfAccess) {
						final isSameClass = switch (e.t) {
							case TInst(clsRef2, _) if (clsRef.get().name == clsRef2.get().name): true;
							case _: false;
						}
						if (isSameClass) {
							final selfData = selfStack[selfStack.length - 1];
							final field = clsFieldRef.get();
							bypassSelf = field.hasMeta(Meta.BypassWrapper) || (selfData.publicOnly && !field.isPublic);
						}
					}
				}

			// Check if this is a static variable, and if so use singleton.
			case FStatic(clsRef, cfRef):
				{
					final cls = clsRef.get();
					final cf = cfRef.get();
					final className = TComp.compileClassName(cls);

					switch (cf.kind) {
						case FMethod(kind): {
								if (kind == MethDynamic) {
									final functionPath = fullCallPath(clsRef.get()).join('_') + '().' + name;
									// trace('=======================> Compiling field access: ${functionPath}');
									// return null;
									return functionPath;
								}
							}
						case _: {
								// If accessing a private static var from itself, don't include the class.
								final currentModule = getCurrentModule();
								switch (currentModule) {
									case TClassDecl(clsRef) if (clsRef.get().equals(cls)): {
											return 'm.__static__.$name';
										}
									case _:
								}
							}
					}
				}

			// Check if this is an enum
			// TODO... is this correct??? I wrote this in 2022 but idk how this works??
			case FEnum(enumRef, enumField):
				{
					final enumType = enumRef.get();
					if (enumType.isReflaxeExtern()) {
						trace("Reflaxe extern enum: " + enumType.getNameOrNative());
						return enumType.getNameOrNative() + "." + enumField.name;
					}

					return "{ \"_index\": " + enumField.index + " }";
				}
			case _:
		}

		// Do not use `self.` on `@:const` variables.
		switch (fa) {
			case FInstance(clsRef, _, clsFieldRef):
				{
					final isSelfAccess = switch (e.expr) {
						case TConst(TThis): true;
						case _: false;
					}
					if (isSelfAccess && clsFieldRef.get().hasMeta(Meta.Const)) {
						return name;
					}
				}
			case _:
		}

		// Compile "accessed" expression
		final expr = bypassSelf ? "self" : compileExpression(e);
		// trace('===========> Compiling field access: ${expr} ${name}');

		// Check if we're accessing an anonymous type.
		// If so, it's a Dictionary in GDScript and .get should be used.
		switch (fa) {
			case FAnon(classFieldRef):
				{
					return expr + '["${classFieldRef.get().name}"]';
				}
			case _:
		}

		return 'm.$name';
	}

	function fullCallPath(cls:ClassType) {
		final className = cls.name;
		final pkg = cls.pack;
		final fullPath:Array<String> = pkg.copy();
		fullPath.push(className);
		return fullPath;
	}

	function getPkg(cls:ClassType) {
		final className = cls.name;
		final pkg = cls.pack;
		final fullPath:Array<String> = pkg.copy();
		return fullPath;
	}

	function callToBrightScript(calledExpr:TypedExpr, arguments:Array<TypedExpr>, originalExpr:TypedExpr):StringBuf {
		var nfcTypes = null;
		final originalExprType = originalExpr.t;
		final nfc = this.compileNativeFunctionCodeMeta(calledExpr, arguments, index -> {
			if (nfcTypes == null)
				nfcTypes = calledExpr.getFunctionTypeParams(originalExprType);
			if (nfcTypes != null && index >= 0 && index < nfcTypes.length) {
				return TComp.compileType(nfcTypes[index], calledExpr.pos);
			}
			return null;
		});

		if (nfc != null) {
			final result = new StringBuf();
			result.add(nfc);
			return result;
		}

		// Check FieldAccess
		final code = switch (calledExpr.expr) {
			case TField(_, fa): {
					switch (fa) {
						case FEnum(_, _):
							final enumCall = compileEnumFieldCall(calledExpr, arguments);
							enumCall != null ? enumCall : null;

						case FStatic(classTypeRef, _.get() => cf):
							cf.meta.maybeHas(':constructor') ? newToBrightScript(classTypeRef, originalExpr, arguments) : null;

						case FInstance(clsRef, _, cfRef):
							// Sys.print('clsRef = ${clsRef.get()}\n\ncalledExpr:$calledExpr\n\n\n\n');
							// if (isCallableVar(calledExpr)) {
							// Sys.print('!!!!!!!! isCallableVar\n');
							// Sys.print('---> cfRef:${cfRef.get()}\n');
							// Sys.print('---> expr:${cfRef.get().expr}\n');
							// Sys.print('---> type:${cfRef.get().type}\n');
							// Sys.print('---> kind:${cfRef.get().kind}\n');
							// Sys.print('---> cfRef.type:${cfRef.get().type}\n');
							// Sys.print('---> calledExpr:$calledExpr\n');
							// Sys.print('---> fa:$fa\n');
							// Sys.print('---> expr:${calledExpr.expr}\n\n\n\n');
							// Sys.print('---> expr:${calledExpr.expr}\n\n\n\n');
							// switch cfRef.get().type {
							// 	case TFun(args, ret):
							// }

							// final kind = switch(field.kind) {
							// 	case FMethod(kind): kind;
							// 	case _: throw "Not a method.";
							// }

							// final funcData = cfRef.get().findFuncData(clsRef.get());
							// if (funcData != null) {
							// 	arguments = funcData.replacePadNullsWithDefaults(arguments, ":noNullPad", generateInjectionExpression);
							// }
							// }
							try {
								final funcData = cfRef.get().findFuncData(clsRef.get());
								if (funcData != null) {
									arguments = funcData.replacePadNullsWithDefaults(arguments, ':noNullPad', generateInjectionExpression);
								}
							} catch (e:Dynamic) {
								Sys.print('---> name:${cfRef.get().name}\n');
								Sys.print('---> expr:${cfRef.get().expr}\n');
								Sys.print('---> type:${cfRef.get().type}\n');
								Sys.print('---> kind:${cfRef.get().kind}\n');
								Sys.print('---> cfRef:${cfRef.get()}\n');
								Sys.print('--->${e}\n\n\n\n');
								arguments = [];
							}

							null;

						case FStatic(clsRef, cfRef):
							final funcData = cfRef.get().findFuncData(clsRef.get());
							if (funcData != null) {
								arguments = funcData.replacePadNullsWithDefaults(arguments, ':noNullPad', generateInjectionExpression);
							}
							null;

						case _: null;
					}
				}
			case _:
				null;
		}

		final result = new StringBuf();
		if (code != null) {
			result.add(code);
		} else {
			if (isCallableVar(calledExpr)) {
				// Sys.print('!!!!!!!! isCallableVar\n');
			}
			result.add(compileExpression(calledExpr));
			// trace('arguments ---> ', arguments);
			result.add('(');
			if (arguments.length > 0) {
				final args = arguments.map(e -> compileExpressionOrError(e));
				// trace('args ---> ', args);
				result.add(args.join(', '));
			}
			// result.add(arguments.map(e -> compileExpressionOrError(e)).join(', '));
			result.add(')');
			// trace('===========> Call to BrightScript: ${result}');
		}
		return result;
	}

	function isCallableVar(e:TypedExpr) {
		return switch (e.expr) {
			case TField(_, fa): {
					switch (fa) {
						case FInstance(_, _, clsFieldRef) | FStatic(_, clsFieldRef) | FClosure(_, clsFieldRef): {
								final clsField = clsFieldRef.get();
								switch (clsField.kind) {
									case FMethod(methKind): {
											methKind == MethDynamic;
										}
									case _: true;
								}
							}
						case _: true;
					}
				}
			case TConst(c): c != TSuper;
			case TParenthesis(e2) | TMeta(_, e2): isCallableVar(e2);
			case _: true;
		}
	}

	function newToBrightScript(classTypeRef:Ref<ClassType>, originalExpr:TypedExpr, el:Array<TypedExpr>):String {
		final nfc = this.compileNativeFunctionCodeMeta(originalExpr, el);
		if (nfc != null) {
			return nfc;
		}

		final meta = originalExpr.getDeclarationMeta()?.meta;
		final native = meta == null ? '' : ({name: '', meta: meta}.getNameOrNative());
		final args = el.map(e -> compileExpression(e)).join(', ');

		if (native.length > 0) {
			return native + '($args)';
		} else {
			final cls = classTypeRef.get();
			final className = TComp.compileClassName(cls);
			final meta = cls.meta.maybeExtract(':bindings_api_type');

			// Check for @:bindings_api_type("builtin_classes") metadata
			final builtin_class = meta.filter(m -> switch (m.params) {
				case [macro 'builtin_classes']: true;
				case _: false;
			}).length > 0;

			final className = cls.name;
			final pkg = cls.pack;
			final fullPath:Array<String> = pkg.copy();
			fullPath.push(className);
			final classPath = fullPath.join('_');

			return builtin_class ? '${classPath}_$className($args)' : 'm.CreateInstance($args)';
		}
	}

	function unopToBrightScrip(op:Unop, e:TypedExpr, isPostfix:Bool):String {
		final expr = compileExpressionOrError(e);
		return switch op {
			case OpIncrement: '$expr = $expr + 1';
			case OpDecrement: '$expr = $expr - 1';
			case OpNeg: '- $expr';
			case OpNegBits: '$expr ~ 0xFFFFFFFF';
			case OpNot: 'NOT $expr';
			// case OpSpread:
			case _:
				final operatorStr = OperatorHelper.unopToString(op);
				isPostfix ? (expr + operatorStr) : (operatorStr + expr);
		}
	}

	function condToBrightScript(e:TypedExpr, eif:TypedExpr, eelse:TypedExpr):String {
		return switch e.expr {
			case TParenthesis(e1): condToBrightScript(e1, eif, eelse);
			case TBinop(op, e1, e2):
				final left = compileExpressionOrError(e1);
				final right = compileExpressionOrError(e2);
				final opStr = switch op {
					case OpOr: 'OR';
					case OpAnd: 'AND';
					case OpNotEq: '<>';
					case OpEq: '=';
					case OpGt: '>';
					case OpGte: '>=';
					case OpLt: '<';
					case OpLte: '<=';
					case _: 'TODO BINOP';
				}
				'($left $opStr $right)';
			case TArray(e1, e2): 'NOT_IMPLEMENTED_TArray($e1, $e2)';
			case TArrayDecl(el): 'NOT_IMPLEMENTED_TArrayDecl($el)';
			case TBlock(el): 'NOT_IMPLEMENTED_TBlock($el)';
			case TBreak: 'NOT_IMPLEMENTED_TBreak';
			case TCall(e, el): 'NOT_IMPLEMENTED_TCall($e, $el)';
			case TCast(e, m): 'NOT_IMPLEMENTED_TCast($e, $m)';
			case TConst(c): 'NOT_IMPLEMENTED_TConst($c)';
			case TContinue: 'NOT_IMPLEMENTED_TContinue';
			case TEnumIndex(e1): 'NOT_IMPLEMENTED_TEnumIndex($e1)';
			case TEnumParameter(e1, ef, index): 'NOT_IMPLEMENTED_TEnumParameter($e1, $ef, $index)';
			case TField(e, fa): 'NOT_IMPLEMENTED_TField($e, $fa)';
			case TFor(v, e1, e2): 'NOT_IMPLEMENTED_TFor($v, $e1, $e2)';
			case TFunction(tfunc): 'NOT_IMPLEMENTED_TFunction($tfunc)';
			case TIdent(s): 'NOT_IMPLEMENTED_TIdent($s)';
			case TIf(econd, eif, eelse): 'NOT_IMPLEMENTED_TIf($econd, $eif, $eelse)';
			case TLocal(v): 'NOT_IMPLEMENTED_TLocal($v)';
			case TMeta(m, e1): 'NOT_IMPLEMENTED_TMeta($m, $e1)';
			case TNew(c, params, el): 'NOT_IMPLEMENTED_TNew($c, $params, $el)';
			case TObjectDecl(fields): 'NOT_IMPLEMENTED_TObjectDecl($fields)';
			case TReturn(e): 'NOT_IMPLEMENTED_TReturn($e)';
			case TSwitch(e, cases, edef): 'NOT_IMPLEMENTED_TSwitch($e, $cases, $edef)';
			case TThrow(e): 'NOT_IMPLEMENTED_TThrow($e)';
			case TTry(e, catches): 'NOT_IMPLEMENTED_TTry($e, $catches)';
			case TTypeExpr(m): 'NOT_IMPLEMENTED_TTypeExpr($m)';
			case TUnop(op, postFix, e): 'NOT_IMPLEMENTED_TUnop($op, $postFix, $e)';
			case TVar(v, expr): 'NOT_IMPLEMENTED_TVar($v, $expr)';
			case TWhile(econd, e, normalWhile): 'NOT_IMPLEMENTED_TWhile($econd, $e, $normalWhile)';
		}
	}

	function toIndentedScope(e:TypedExpr):StringBuf {
		final result = new StringBuf();
		switch (e.expr) {
			case TBlock(el):
				{
					if (el.length > 0) {
						for (i in 0...el.length) {
							final code = compileExpression(el[i]);
							if (code != null) {
								result.add(code.tab());
								if (i < el.length - 1) {
									result.add('\n');
								}
							}
						}
					} else {
						result.add('\tpass');
					}
				}
			case _:
				{
					final gdscript = compileExpression(e) ?? 'pass';
					result.add(gdscript.tab());
				}
		}
		return result;
	}

	public function compileExpressionImplDebug(expr:TypedExpr, result:String):Null<String> {
		final type = switch (expr.expr) {
			case TConst(constant): 'TConst';
			case TLocal(v): 'TLocal';
			case TIdent(s): 'TIdent';
			case TArray(e1, e2): 'TArray';
			case TBinop(OpAssign, {expr: TField(e1, FAnon(classFieldRef))}, e2): 'OpAssign';
			case TBinop(op, e1, e2): 'TBinop';
			case TField(e, fa): 'TField';
			case TTypeExpr(m): 'TTypeExpr';
			case TParenthesis(e): 'TParenthesis';
			case TObjectDecl(fields): 'TObjectDecl';
			case TArrayDecl(el): 'TArrayDecl';
			case TCall(e, el): 'TCall';
			case TNew(classTypeRef, _, el): 'TNew';
			case TUnop(op, postFix, e): 'TUnop';
			case TFunction(tfunc): 'TFunction';
			case TVar(tvar, maybeExpr): 'TVar';
			case TBlock(el): 'TBlock';
			case TFor(tvar, iterExpr, blockExpr): 'TFor';
			case TIf(econd, ifExpr, elseExpr): 'TIf';
			case TWhile(econd, blockExpr, normalWhile): 'TWhile';
			case TSwitch(e, cases, edef): 'TSwitch';
			case TTry(e, catches): 'TTry';
			case TReturn(maybeExpr): 'TReturn';
			case TBreak: 'TBreak';
			case TContinue: 'TContinue';
			case TThrow(expr): 'TThrow';
			case TCast(expr, maybeModuleType): 'TCast';
			case TMeta(_, expr): 'TMeta';
			case TEnumParameter(expr, enumField, index): 'TEnumParameter';
			case TEnumIndex(expr): 'TEnumIndex';
		}
		return '<$type:$depth-->$result<--$type:$depth>\n';
	}

	/**
		This is the final required function.
		It compiles the expressions generated from Haxe.

		PLEASE NOTE: to recusively compile sub-expressions:
			BaseCompiler.compileExpression(expr: TypedExpr): Null<String>
			BaseCompiler.compileExpressionOrError(expr: TypedExpr): String

		https://api.haxe.org/haxe/macro/TypedExpr.html
	**/
	public function compileExpressionImpl(expr:TypedExpr, topLevel:Bool):Null<String> {
		depth++;
		var result = new StringBuf();
		if (debug) {
			result.add('\n(DEPTH:$depth)-----> compileExpressionImpl: ${expr.expr}\n');
		}
		switch (expr.expr) {
			case TConst(constant):
				// trace('----> TConst $constant');
				result.add(constantToBrightScript(constant));

			case TLocal(v):
				result.add(compileVarName(v.name, expr));
				if (v.meta.maybeHas(':arrayWrap')) {
					result.add('[0]');
				}

			case TIdent(s):
				result.add(compileVarName(s, expr));

			case TArray(e1, e2):
				result.addMulti(compileExpressionOrError(e1), '[', compileExpressionOrError(e2), ']');

			case TBinop(OpAssign, {expr: TField(e1, FAnon(classFieldRef))}, e2):
				var gdExpr1 = compileExpressionOrError(e1);
				var gdExpr2 = compileExpressionOrError(e2);
				result.add('$gdExpr1["${classFieldRef.get().name}"] = $gdExpr2');

			case TBinop(op, e1, e2):
				result.add(binopToBrightScript(op, e1, e2));

			case TField(e, fa):
				// trace('----> TField $fa');
				final nfc = this.compileNativeFunctionCodeMeta(expr, [e]);
				if (nfc != null) {
					result.add(nfc);
				} else {
					result.add(fieldAccessToBrightScript(e, fa));
				}

			case TTypeExpr(m):
				// trace('----> TTypeExpr $m');
				result.add(TComp.compileType(TypeHelper.fromModuleType(m), expr.pos) ?? 'Invalid');

			case TParenthesis(e):
				final bscript = compileExpressionOrError(e);
				// final expr = EverythingIsExprSanitizer.isBlocklikeExpr(e) ? bscript : '--($bscript)--';
				final expr = EverythingIsExprSanitizer.isBlocklikeExpr(e) ? bscript : '$bscript';
				result.add(expr);

			case TObjectDecl(fields):
				result.add('{\n');
				for (i in 0...fields.length) {
					final field = fields[i];
					result.addMulti('\t\"', field.name, '\": ');
					result.add(compileExpression(field.expr));
					if (i < fields.length - 1) {
						result.add(',');
					}
					result.add('\n');
				}
				result.add('}');

			case TArrayDecl(el):
				result.add('[');
				result.add(el.map(e -> compileExpression(e)).join(', '));
				result.add(']');

			case TCall(e, el):
				final isEmptyConstructorSuperCall = switch (e.unwrapParenthesis().expr) {
					case TConst(TSuper) if (compilingInConstructor && el.length == 0): true;
					case _: false;
				}
				if (!isEmptyConstructorSuperCall) {
					final call = callToBrightScript(e, el, expr);
					result.add(call);
				}

			case TNew(classTypeRef, _, el):
				result.add(newToBrightScript(classTypeRef, expr, el));

			case TUnop(op, postFix, e):
				result.add(unopToBrightScrip(op, e, postFix));

			case TFunction(tfunc):
				result.add('function(');
				var doComma = false;
				for (i in 0...tfunc.args.length) {
					if (doComma)
						result.add(', ');
					else
						doComma = true;

					final arg = tfunc.args[i];
					final reflaxeArg = new ClassFuncArg(i, arg.v.t, false, arg.v.name, arg.v.meta, arg.value, arg.v);
					result.add(compileFunctionArgument(reflaxeArg, expr.pos));
				}
				result.add(')');
				final type = TComp.compileType(tfunc.t, expr.pos);
				if (type != null) {
					result.addMulti(' as ', type);
				}
				result.add('\n');
				result.add(toIndentedScope(tfunc.expr));
				result.add('\nend function');

			case TVar(tvar, maybeExpr):
				final vName = compileVarName(tvar.name, expr);
				if (maybeExpr != null) {
					final vExpr = compileExpressionOrError(maybeExpr);
					if (tvar.meta.maybeHas(':arrayWrap')) {
						result.addMulti(compileVarName(tvar.name, expr));
						result.addMulti(vName, ' = [', vExpr, ']\n');
					} else {
						// result.addMulti(vName, '\n');
						// result.addMulti(vName, ' = ', vExpr, '\n');
						switch maybeExpr.expr {
							case TBlock(el):
								if (el.length > 0) {
									final elements = el.map(e -> compileExpression(e).trustMe());
									final last = elements.pop();
									result.addMulti(elements.join('\n'), '\n');
									result.addMulti(vName, ' = ', last, '\n');
								} else {
									result.add('=============> TBlock 2\n');
								}
							case TUnop(op, postFix, e):
								result.addMulti(vExpr, '\n');
							case _:
								result.addMulti(vName, ' = ', vExpr, '\n');
						}

						// final aExpr = vExpr.split(' = ').map(e -> e.trim());
						// trace('
						// === TVar 2 ===

						// vExpr:
						// $vExpr

						// vName:
						// $vName

						// maybeExpr:
						// $maybeExpr

						// tvar:
						// $tvar

						// expr:
						// $expr

						// aExpr:
						// $aExpr

						// ');

						// result.addMulti(vName, ' = ', vExpr);
						// aExpr.length == 1 ? result.addMulti(vName, ' = ', vExpr) : result.addMulti(aExpr[0], ' = ', aExpr[1], ' : ', vName, ' = ', aExpr[0]);
					}
				} else {
					// trace('TVar 3', compileVarName(tvar.name, expr));
					// result.add(compileVarName(tvar.name, expr));
				}
			case TBlock(el):
				if (el.length > 0) {
					// final elements = el.map(e -> compileExpression(e).trustMe());
					final elements = el.map(e -> compileExpressionOrError(e)).filter(e -> e != null).map(e -> e.trustMe().tab());
					result.addMulti(elements.join('\n'));
				} else {
					result.add('=============> TBlock 2\n');
				}

			case TFor(tvar, iterExpr, blockExpr):
				result.addMulti("for ", tvar.name, " in ", compileExpressionOrError(iterExpr), ':\n');
				result.add(toIndentedScope(blockExpr));

			case TIf(econd, ifExpr, elseExpr):
				result.addMulti('if ', condToBrightScript(econd, ifExpr, elseExpr), ' then:\n');
				// result.addMulti("if ", compileExpressionOrError(econd), ":\n");
				result.add(toIndentedScope(ifExpr));
				if (elseExpr != null) {
					result.add('\n');
					result.add('else:\n');
					result.add(toIndentedScope(elseExpr));
				}
				result.add('\nend if');

			case TWhile(econd, blockExpr, normalWhile):
				final gdCond = compileExpressionOrError(econd);
				if (normalWhile) {
					result.addMulti('WHILE ', gdCond, '\n');
					result.add(toIndentedScope(blockExpr));
				} else {
					result.add('WHILE true\n');
					result.add(toIndentedScope(blockExpr));
					result.addMulti('\tif ', gdCond, '\n');
					result.add("\t\tbreak");
				}
				result.add("\nEND WHILE");

			case TSwitch(e, cases, edef):
				final swRes = switchToBrightScript(e, cases, edef, false);
				result.addMulti(swRes);

			case TTry(e, catches):
				result.add('TRY\n');
				result.add(compileExpressionOrError(e).tab());
				result.add('\nCATCH e\n');
				result.add('PRINT e.number,e.message'.tab());
				result.add('\nEND TRY');
			// final msg = "GDScript does not support try-catch. The expressions contained in the try block will be compiled, and the catches will be ignored.";
			// Context.warning(msg, expr.pos);

			case TReturn(maybeExpr):
				// trace('===========> Compiling \n\nexpr: \n$expr \n\nreturn: \n${maybeExpr}');
				if (maybeExpr == null) {
					result.add('return');
				} else {
					switch maybeExpr.expr {
						case TMeta(_, expr):
							switch (expr.expr) {
								case TSwitch(e, cases, edef):
									final swRes = switchToBrightScript(e, cases, edef, true);
									result.addMulti(swRes);
								case _:
									result.addMulti('return ', compileExpressionOrError(maybeExpr));
							}
						case _:
							result.addMulti('return ', compileExpressionOrError(maybeExpr));
					}
				}

			case TBreak:
				result.add("break");

			case TContinue:
				result.add("continue");

			case TThrow(expr):
				result.addMulti('THROW ', compileExpressionOrError(expr));

			case TCast(expr, maybeModuleType):
				final hasModuleType = maybeModuleType != null;
				if (hasModuleType) {
					result.add("(");
				}
				result.add(compileExpressionOrError(expr));
				if (hasModuleType) {
					final typeCode = TComp.compileType(TypeHelper.fromModuleType(maybeModuleType.trustMe()), expr.pos);
					result.addMulti(typeCode == null ? '' : ' as ', typeCode ?? 'Variant', ')');
				}

			case TMeta(_, expr):
				result.addMulti(compileExpressionOrError(expr));

			case TEnumParameter(expr, enumField, index):
				result.add(compileExpressionOrError(expr));
				switch (enumField.type) {
					case TFun(args, _): {
							if (index < args.length) {
								// trace('TODO ENUM PARAMETER');
								result.addMulti(".", args[index].name);
							}
						}
					case _:
				}

			case TEnumIndex(expr):
				final isExtern = switch (expr.t) {
					case TEnum(_.get() => e, _): e.isReflaxeExtern();
					case _: false;
				}

				if (isExtern) {
					result.add("((");
				}
				result.add(compileExpressionOrError(expr));
				if (isExtern) {
					result.add(" as Variant) as int)");
				} else {
					result.add("._index");
				}
		}
		// final debug = true;
		final debug = false;
		final resp = debug ? compileExpressionImplDebug(expr, result.toString()) : result.toString();
		depth--;
		return resp;
	}

	function filterNonDisplayableChars(s:String):String {
		var result = "";
		for (i in 0...s.length) {
			var char = s.charAt(i);
			if (char >= '\x20' && char <= '\x7E') { // ASCII printable characters
				result += char;
			}
		}
		return result;
	}

	function switchToBrightScript(e:TypedExpr, cases:Array<{values:Array<TypedExpr>, expr:TypedExpr}>, edef:TypedExpr, returnSwitch = false):String {
		final result = new StringBuf();

		final externEnumType = switch (e.unwrapParenthesis().expr) {
			case TEnumIndex(e1): {
					switch (e1.t) {
						case TEnum(_.get() => e, _) if (e.isReflaxeExtern()): e;
						case _: null;
					}
				}
			case _: null;
		}

		final ret = returnSwitch ? 'return ' : '';
		var index = 0;
		for (c in cases) {
			result.add("\n");
			result.add(c.values.map(v -> {
				if (externEnumType != null) {
					switch (v.expr) {
						case TConst(TInt(index)):
							{
								return externEnumType.names[index];
							}
						case _:
					}
				}
				final eCond = compileExpressionOrError(e);
				final vCond = compileExpressionOrError(v);
				final sCond = index == 0 ? 'If' : 'Else If';
				index++;
				return '$sCond $eCond = $vCond Then';
			}).join(", "));
			final condExpr = compileExpressionOrError(c.expr).split('\n');
			final lastLine = condExpr.pop();
			condExpr.push('$ret$lastLine');
			result.add('\n${condExpr.join('\n')}'.tab());
		}

		if (edef != null) {
			result.add("\nElse\n");
			final condExpr = compileExpressionOrError(edef).split('\n');
			final lastLine = condExpr.pop();
			condExpr.push('$ret$lastLine');
			result.add('\n${condExpr.join('\n')}'.tab());
		}

		result.add("\nEnd If\n");
		return result.toString();
	}

	function compileEnumFieldCall(e:TypedExpr, el:Array<TypedExpr>):Null<String> {
		return 'TODO ENUM FIELD CALL';
	}

	override function onOutputComplete() {
		var outputFile = Context.getDefines().get("brightscript-output");
		sys.io.File.saveContent(outputFile, sys.io.File.getContent(outputFile) + "\n\n\nMain().main()");
	}
}
#end
