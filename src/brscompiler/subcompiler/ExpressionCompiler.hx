package brscompiler.subcompiler;

import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Type.ClassField;
import reflaxe.data.ClassFuncArg;
import reflaxe.data.ClassFuncData;
import reflaxe.helpers.OperatorHelper;
import reflaxe.preprocessors.implementations.everything_is_expr.EverythingIsExprSanitizer;
import brscompiler.config.Define.FnCall;
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

class ExpressionCompiler {
	var main:brscompiler.BRSCompiler;
	var tempVarCounter:Int = 0;
	var pendingPrefix:StringBuf = new StringBuf();
	var loopKindStack:Array<String> = [];
	var isCallTarget:Bool = false;

	public function new(main:brscompiler.BRSCompiler) {
		this.main = main;
	}

	function unwrapStatementExpr(expr:TypedExpr):TypedExpr {
		return switch (expr.expr) {
			case TParenthesis(e): unwrapStatementExpr(e);
			case TMeta(_, e): unwrapStatementExpr(e);
			case TCast(e, _): unwrapStatementExpr(e);
			case _: expr;
		};
	}

	function shouldSkipBareStatementExpr(expr:TypedExpr):Bool {
		return switch (unwrapStatementExpr(expr).expr) {
			case TLocal(_): true;
			case TConst(_): true;
			case TField(_, _): true;
			case _: false;
		};
	}

	function adl(v:Dynamic){
		return '';
		return '%$v%-';
	}

	public function compileExpressionImpl(expr:TypedExpr, topLevel:Bool):Null<String> {
		var result = new StringBuf();
		switch (expr.expr) {
			case TConst(TSuper): result.add(adl('TConst+TSuper') + compileSuperExpr(expr));
			case TConst(constant): result.add(adl('TConst') + constantToBrightScript(constant));
			case TLocal(v): result.add(adl('TLocal') + compileLocal(v, expr));
			case TIdent(s): result.add(adl('TIdent') + main.compileVarName(s, expr));
			case TArray(e1, e2):
				if (containsStatementExpr(e1)) {
					final tmpName = '__tmp_${tempVarCounter++}';
					final hoisted = compileIfAsAssignment(e1.unwrapParenthesis(), tmpName);
					pendingPrefix.add(adl('TArray.1') + hoisted);
					result.addMulti(adl('TArray.2') + tmpName, '[', main.compileExpressionOrError(e2), ']');
				} else {
					result.addMulti(adl('TArray.3') + main.compileExpressionOrError(e1), '[', main.compileExpressionOrError(e2), ']');
				}
			case TBinop(OpAssign, {expr: TField(e1, FAnon(classFieldRef))}, e2): result.add(adl('TBinop+OpAssign') + compileAnonFieldAssign(e1, classFieldRef, e2));
			case TBinop(op, e1, e2): result.add(adl('TBinop') + binopToBrightScript(op, e1, e2));
			case TField(e, fa): result.add(adl('TField') + compileFieldExpr(e, fa, expr));
			case TFunction(tfunc): result.add(adl('TFunction') + compileFunctionExpr(tfunc, expr));
			case TTypeExpr(m): result.add(adl('TTypeExpr') + main.TComp.compileType(TypeHelper.fromModuleType(m), expr.pos) ?? 'Invalid !4!');
			case TParenthesis(e): result.add(adl('TParenthesis') + compileParenthesis(e));
			case TObjectDecl(fields): result.add(adl('TObjectDecl') + compileObjectDecl(fields));
			case TArrayDecl(el): result.addMulti(adl('TArrayDecl') + '[', el.map(e -> main.compileExpression(e)).join(', '), ']');
			case TCall(e, el): result.add(adl('TCall') + compileCallExpr(e, el, expr));
			case TNew(classTypeRef, _, el): result.add(adl('TNew') + newToBrightScript(classTypeRef, expr, el));
			case TUnop(op, postFix, e): result.add(adl('TUnop') + unopToBrightScript(op, e, postFix));
			case TVar(tvar, maybeExpr): result.add(adl('TVar') + compileVarDecl(tvar, maybeExpr, expr));
			case TBlock(el): result.add(adl('TBlock') + compileBlock(el, topLevel));
			case TFor(tvar, iterExpr, blockExpr): result.add(adl('TFor') + compileFor(tvar, iterExpr, blockExpr));
			case TIf(econd, ifExpr, elseExpr): result.add(adl('TIf') + compileIf(econd, ifExpr, elseExpr));
			case TWhile(econd, blockExpr, normalWhile): result.add(adl('TWhile') + compileWhile(econd, blockExpr, normalWhile));
			case TSwitch(e, cases, edef): result.add(adl('TSwitch') + switchToBrightScript(e, cases, edef, false));
			case TTry(e, catches): result.add(adl('TTry') + compileTry(e, catches));
			case TReturn(maybeExpr): result.add(adl('TReturn') + compileReturn(maybeExpr));
			case TBreak:
				final loopKind = loopKindStack.length > 0 ? loopKindStack[loopKindStack.length - 1] : "while";
				result.add(adl('TBreak') + 'exit $loopKind');
			case TContinue:
				final loopKind = loopKindStack.length > 0 ? loopKindStack[loopKindStack.length - 1] : "while";
				result.add(adl('TContinue') + 'continue $loopKind');
			case TThrow(e): result.addMulti(adl('TThrow') + 'THROW ', main.compileExpressionOrError(e));
			case TCast(e, maybeModuleType): result.add(adl('TCast') + compileCast(e, maybeModuleType));
			case TMeta(_, e): result.add(adl('TMeta') + main.compileExpressionOrError(e));
			case TEnumParameter(e, enumField, index): result.add(adl('TEnumParameter') + compileEnumParameter(e, enumField, index));
			case TEnumIndex(e): result.add(adl('TEnumIndex') + compileEnumIndex(e));
		}
		// For top-level statements, drain any pending prefix into the output
		if (topLevel) {
			final prefix = pendingPrefix.toString();
			pendingPrefix = new StringBuf();
			if (prefix.length > 0) {
				return prefix + result.toString();
			}
		}
		return result.toString();
	}

	function compileLocal(v:TVar, expr:TypedExpr):String {
		/**
			TODO: solve closure like variables scope
		**/
		final name = Define.Ctx + '.' + main.compileVarName(v.name, expr);
		return v.meta.maybeHas(':arrayWrap') ? '${name}[0]' : '${name}';
	}

	function compileAnonFieldAssign(e1:TypedExpr, classFieldRef:Ref<ClassField>, e2:TypedExpr):String {
		final brsExpr1 = main.compileExpressionOrError(e1);
		final lhs = '$brsExpr1["${classFieldRef.get().name}"]';
		// For if/switch/block, compile as if-assignment directly
		final needsHoist = switch (e2.unwrapParenthesis().expr) {
			case TIf(_, _, _): true;
			case TSwitch(_, _, _): true;
			case TBlock(_): true;
			// case TArray | TArrayDecl | TBinop | TBreak | TCall | TCast | TConst | TContinue | TEnumIndex | TEnumParameter | TField | TFor | TFunction | TIdent | TLocal | TMeta | TNew | TObjectDecl | TParenthesis | TReturn | TThrow | TTry | TTypeExpr | TUnop | TVar | TWhile: false;
			// case TField(_): true;
			// case TFunction(_): true;
			// case TConst(_): true;
			// case TLocal(_): true;
			// case TObjectDecl(_): true;
			// case TVar(_): true;
			// case TArrayDecl(_): true;
			// case TArray(_): true;
			// case TCall(_): true;
			// case TParenthesis(_): true;
			// case TTypeExpr(_): true;
			case _: false;
		};
		if (needsHoist) {
			return compileIfAsAssignment(e2.unwrapParenthesis(), lhs);
		}
		final brsExpr2 = main.compileExpressionOrError(e2);
		final prefix = pendingPrefix.toString();
		pendingPrefix = new StringBuf();
		if (brsExpr2.indexOf('\n') >= 0) {
			final lines = brsExpr2.split('\n');
			final lastLine = lines.pop();
			return prefix + lines.join('\n') + '\n$lhs = $lastLine';
		}
		return '$prefix$lhs = $brsExpr2';
	}

	function compileFieldExpr(e:TypedExpr, fa:FieldAccess, expr:TypedExpr):String {
		// Handle method closures (method references used as values, not called)
		// In BRS, extracting a function from an AA loses the `m` context.
		// Generate a wrapper AA that rebinds `m` when called.
		switch (fa) {
			case FClosure(_, classFieldRef) if (!isCallTarget):
				return compileClosureBind(e, classFieldRef, expr);
			case _:
		}

		if (containsStatementExpr(e)) {
			final tmpName = '__tmp_${tempVarCounter++}';
			pendingPrefix.add(compileIfAsAssignment(unwrapStatementExpr(e), tmpName));
			final tempExpr:TypedExpr = {
				expr: TIdent(tmpName),
				t: e.t,
				pos: e.pos
			};
			final hoistedNfc = main.compileNativeFunctionCodeMeta(expr, [tempExpr]);
			if (hoistedNfc != null) {
				return hoistedNfc;
			}
			return main.fieldAccessToBrightScriptResolved(tmpName, e, fa);
		}

		final compiledReceiver = main.compileExpressionOrError(e);
		final receiverPrefix = pendingPrefix.toString();
		pendingPrefix = new StringBuf();
		final hoistedReceiver = extractMultilineValue(receiverPrefix + compiledReceiver);
		if (hoistedReceiver != null) {
			pendingPrefix.add(hoistedReceiver.prefix);
			final tempExpr:TypedExpr = {
				expr: TIdent(hoistedReceiver.value),
				t: e.t,
				pos: e.pos
			};
			final hoistedNfc = main.compileNativeFunctionCodeMeta(expr, [tempExpr]);
			if (hoistedNfc != null) {
				return hoistedNfc;
			}
			return main.fieldAccessToBrightScriptResolved(hoistedReceiver.value, e, fa);
		}
		if (receiverPrefix.length > 0) {
			pendingPrefix.add(receiverPrefix);
		}
		final nfc = main.compileNativeFunctionCodeMeta(expr, [e]);
		if (nfc != null) {
			return nfc;
		}
		return main.fieldAccessToBrightScriptResolved(compiledReceiver, e, fa);
	}

	function compileParenthesis(e:TypedExpr):String {
		final bscript = main.compileExpressionOrError(e);
		return EverythingIsExprSanitizer.isBlocklikeExpr(e) ? bscript : '$bscript';
	}

	function compileClosureBind(receiver:TypedExpr, classFieldRef:Ref<ClassField>, expr:TypedExpr):String {
		final cf = classFieldRef.get();
		final methodName = main.compileVarName(cf.getNameOrNativeName());

		// Compile receiver expression
		final compiledReceiver = main.compileExpressionOrError(receiver);
		final prefix = pendingPrefix.toString();
		pendingPrefix = new StringBuf();

		// Capture self reference in a temp variable
		final selfVar = '__selfBound${tempVarCounter++}';
		pendingPrefix.add('${prefix}${selfVar} = ${compiledReceiver}\n');

		// Get method parameters from the function type
		final params:Array<{name:String, opt:Bool, t:Type}> = switch (cf.type) {
			case TFun(args, _): args;
			case _: [];
		};
		params.push({name: '__ref', opt: false, t: null}); // Add extra parameter for the bound `m` context

		// Generate the wrapper call function body
		final fnVar = FnCall(tempVarCounter++);
		var fnBuf = new StringBuf();
		fnBuf.add('$fnVar = function(');
		for (i in 0...params.length) {
			if (i > 0) fnBuf.add(', ');
			final p = params[i];
			fnBuf.add('${p.name} as Object');
			// fnBuf.add('__a$i as Object');
		}
		fnBuf.add(') as Object\n');
		// fnBuf.add('return m.__self.$methodName(');
		fnBuf.add('return __ref.$methodName(');
		params.pop(); // Remove the extra `m` context parameter for the actual method call
		for (i in 0...params.length) {
			if (i > 0) fnBuf.add(', ');
			final p = params[i];
			fnBuf.add('${p.name}');
		}
		fnBuf.add(')\nend function\n');
		pendingPrefix.add(fnBuf.toString());

		// Return the wrapper AA expression (single line)
		return '{"__self": $selfVar, "call": $fnVar}';
	}

	function compileFunctionExpr(tfunc:TFunc, expr:TypedExpr):String {
		/**
			TODO: Similar to closure
		**/
		final result = new StringBuf();
		result.addMulti(Define.Function, '(');
		tfunc.args.insert(0, {
					v: {
						isStatic: false,
						id: null,
						extra: null,
						capture: null,
						t: TDynamic(null), 
						name: Define.Ctx,
						meta: null,
					},
					value: null
				}
			);
		var doComma = false;
		for (i in 0...tfunc.args.length) {
			if (doComma)
				result.add(', ');
			else
				doComma = true;

			final arg = tfunc.args[i];
			final reflaxeArg = new ClassFuncArg(i, arg.v.t, false, arg.v.name, arg.v.meta, arg.value, arg.v);
			result.add(main.compileFunctionArgument(reflaxeArg, expr.pos));
		}
		result.add(')');
		final type = main.TComp.compileType(tfunc.t, expr.pos);
		if (type != null) {
			result.addMulti(' as ', type);
		}
		result.add('\n');
		result.add(toIndentedScope(tfunc.expr, true));
		result.addMulti('\n', Define.EndFunction);
		return result.toString();
	}
	
	function compileObjectDecl(fields:Array<{name:String, expr:TypedExpr}>):String {
		var objBuf = new StringBuf();
		objBuf.add('{');
		for (i in 0...fields.length) {
			final field = fields[i];
			if (i > 0) objBuf.add(', ');
			objBuf.addMulti('"', field.name, '": ');
			final needsHoist = containsStatementExpr(field.expr);
			if (needsHoist) {
				final tmpName = '__tmp_${tempVarCounter++}';
				pendingPrefix.add(compileIfAsAssignment(unwrapStatementExpr(field.expr), tmpName));
				objBuf.add(tmpName);
			} else {
				final compiled = main.compileExpressionOrError(field.expr);
				final fieldPrefix = pendingPrefix.toString();
				pendingPrefix = new StringBuf();
				final hoisted = extractMultilineValue(fieldPrefix + compiled);
				if (hoisted != null) {
					pendingPrefix.add(hoisted.prefix);
					objBuf.add(hoisted.value);
				} else {
					if (fieldPrefix.length > 0) {
						pendingPrefix.add(fieldPrefix);
					}
					objBuf.add(compiled);
				}
			}
		}
		objBuf.add('}');
		return objBuf.toString();
	}

	function compileIfAsAssignment(expr:TypedExpr, varName:String):String {
		final unwrapped = unwrapStatementExpr(expr);
		return switch (unwrapped.expr) {
			case TIf(econd, ifExpr, elseExpr):
				var result = new StringBuf();
				result.addMulti('if ', condToBrightScript(econd, ifExpr, elseExpr), ' then\n');
				compileIfBranch(result, ifExpr, varName);
				if (elseExpr != null) {
					result.add('else\n');
					compileIfBranch(result, elseExpr, varName);
				}
				result.add('end if\n');
				result.toString();
			case TSwitch(e, cases, edef):
				switchToBrightScriptAssignment(e, cases, edef, varName);
			case TBlock(el) if (el.length > 0):
				var result = new StringBuf();
				// Compile all but last as statements
				for (i in 0...el.length - 1) {
					if (!shouldSkipBareStatementExpr(el[i])) {
						final elem = main.compileExpression(el[i]).trustMe();
						final prefix = pendingPrefix.toString();
						pendingPrefix = new StringBuf();
						result.add(prefix);
						result.add(elem);
						result.add('\n');
					}
				}
				// Last element is the value — assign to varName
				result.add(compileIfAsAssignment(el[el.length - 1], varName));
				result.toString();
			case _:
				final compiled = main.compileExpressionOrError(expr);
				final prefix = pendingPrefix.toString();
				pendingPrefix = new StringBuf();
				if (compiled.indexOf('\n') >= 0) {
					final lines = compiled.split('\n');
					final lastLine = lines.pop();
					prefix + lines.join('\n') + '\n$varName = $lastLine\n';
				} else {
					'$prefix$varName = $compiled\n';
				}
		}
	}

	function compileIfBranch(result:StringBuf, branchExpr:TypedExpr, varName:String):Void {
		final unwrapped = unwrapStatementExpr(branchExpr);
		switch (unwrapped.expr) {
			case TIf(_, _, _) | TSwitch(_, _, _):
				result.add(compileIfAsAssignment(unwrapped, varName));
			case TBlock(el) if (el.length > 0):
				// Compile block: all but last as statements, last as assignment
				final statementExprs = el.slice(0, el.length - 1).filter(e -> !shouldSkipBareStatementExpr(e));
				final elements = statementExprs.map(e -> main.compileExpression(e).trustMe());
				final prefix = pendingPrefix.toString();
				pendingPrefix = new StringBuf();
				result.add(prefix);
				for (elem in elements) {
					result.add('\t$elem\n');
				}
				result.add(compileIfAsAssignment(el[el.length - 1], varName).tab());
				if (!result.toString().endsWith("\n")) {
					result.add('\n');
				}
			case _:
				final compiled = main.compileExpressionOrError(branchExpr);
				final branchPrefix = pendingPrefix.toString();
				pendingPrefix = new StringBuf();
				result.add(branchPrefix);
				if (compiled.indexOf('\n') >= 0) {
					final lines = compiled.split('\n');
					final lastLine = lines.pop();
					result.add('\t${lines.join("\n\t")}\n');
					result.add('\t$varName = $lastLine\n');
				} else {
					result.add('\t$varName = $compiled\n');
				}
		}
	}

	function compileCallExpr(e:TypedExpr, el:Array<TypedExpr>, expr:TypedExpr):String {
		return switch (unwrapStatementExpr(e).expr) {
			case TConst(TSuper):
				final args = el.map(arg -> main.compileExpressionOrError(arg)).join(', ');
				switch (e.t) {
					case TInst(clsRef, _):
						final cls = clsRef.get();
						final classPath = main.fullCallPath(cls).join('_');
						'${classPath}().CreateInstance($args)';
					case _:
						callToBrightScript(e, el, expr);
				}
			case _:
				callToBrightScript(e, el, expr);
		};
	}

	function compileVarDecl(tvar:TVar, maybeExpr:Null<TypedExpr>, expr:TypedExpr):String {
		if (maybeExpr == null) return '';
		var result = new StringBuf();
		result.add('${Define.Ctx}.');

		final vName = main.compileVarName(tvar.name, expr);
		// For if/switch/block value expressions, use compileIfAsAssignment directly
		final needsHoist = switch (unwrapStatementExpr(maybeExpr).expr) {
			case TIf(_, _, _): true;
			case TSwitch(_, _, _): true;
			case TBlock(_): true;
			case _: false;
		};
		if (needsHoist) {
			result.add(compileIfAsAssignment(maybeExpr, vName));
			return result.toString();
		}
		final vExpr = main.compileExpressionOrError(maybeExpr);
		final prefix = pendingPrefix.toString();
		pendingPrefix = new StringBuf();
		result.add(prefix);
		if (tvar.meta.maybeHas(':arrayWrap')) {
			// result.addMulti(main.compileVarName(tvar.name, expr));
			result.addMulti(vName, ' = [', vExpr, ']');
		} else {
			switch maybeExpr.expr {
				case TUnop(op, postFix, e):
					result.addMulti(vExpr);
				case _:
					result.addMulti(vName, ' = ', vExpr);
			}
		}
		return result.toString();
	}

	function compileBlock(el:Array<TypedExpr>, topLevel:Bool = true):String {
		if (el.length > 0) {
			// Only filter non-side-effectful last expression at top level (statement context).
			if (topLevel) {
				final elements = filterBlockReturnValue(el);
				return compileBlockElements(elements).map(e -> e.tab()).join('\n');
			}

			// In sub-expression context, preserve the last element as the block value.
			if (el.length == 1) {
				return main.compileExpressionOrError(el[0]);
			}

			final prefix = compileBlockElements(el.slice(0, el.length - 1)).map(e -> e.tab());
			final last = main.compileExpressionOrError(el[el.length - 1]).tab();
			final lines = prefix.copy();
			lines.push(last);
			return lines.join('\n');
		}
		return '';
	}

	// Remove the last expression of a block if it's a non-side-effectful "return value"  
	// (BRS doesn't allow bare expressions like variable references)
	function filterBlockReturnValue(el:Array<TypedExpr>):Array<TypedExpr> {
		if (el.length == 0) return el;
		final last = el[el.length - 1];
		final isValueExpr = shouldSkipBareStatementExpr(last);
		return isValueExpr ? el.slice(0, el.length - 1) : el;
	}

	// Compiles block-level expressions, detecting and fixing the for-in
	// desugaring pattern where the Haxe compiler reuses the same variable
	// name for both the iterator and the loop value.
	function compileBlockElements(el:Array<TypedExpr>, ?isAnon:Bool = false):Array<String> {
		var results:Array<String> = [];
		var i = 0;
		while (i < el.length) {
			if (i + 1 < el.length) {
				final forIn = tryCompileForIn(el[i], el[i + 1]);
				if (forIn != null) {
					results.push(forIn);
					i += 2;
					continue;
				}
			}
			// Skip non-side-effectful bare expressions (BRS doesn't allow them as statements)
			final skip = shouldSkipBareStatementExpr(el[i]);
			if(isAnon){
				trace('shouldSkipBareStatementExpr: $skip');
			}
			if (!skip) {
				final compiled = main.compileExpression(el[i]);
				if(isAnon){
					trace('compiled: $compiled');
				}
				if (compiled != null) {
					final statement = stripTrailingBareValueLine(compiled);
					if (statement.trim().length > 0) results.push(statement);
				}
			}else{
				trace('================= shouldSkipBareStatementExpr
				${el[i]}
				');

			}
			i++;
		}
		return results;
	}

	function stripTrailingBareValueLine(compiled:String):String {
		if (compiled.indexOf('\n') < 0) {
			return compiled;
		}
		final lines = compiled.split('\n');
		if (lines.length == 0) {
			return compiled;
		}
		final last = lines[lines.length - 1].trim();
		final bareExpr = ~/^(?:[A-Za-z_][A-Za-z0-9_]*(?:\.[A-Za-z_][A-Za-z0-9_]*)*|true|false|invalid|-?[0-9]+(?:\.[0-9]+)?)$/;
		if (!bareExpr.match(last)) {
			return compiled;
		}
		lines.pop();
		while (lines.length > 0 && lines[lines.length - 1].trim().length == 0) {
			lines.pop();
		}
		return lines.join('\n');
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

	// Detects: TVar(v, iterExpr); TWhile(cond, TBlock[TVar(v_same_name, ...), ...body])
	function tryCompileForIn(varExpr:TypedExpr, whileExpr:TypedExpr):Null<String> {
		switch (varExpr.expr) {
			case TVar(iterVar, iterInit):
				if (iterInit == null) return null;
				switch (whileExpr.expr) {
					case TWhile(econd, bodyExpr, true):
						switch (bodyExpr.expr) {
							case TBlock(bodyEls) if (bodyEls.length > 0):
								switch (bodyEls[0].expr) {
									case TVar(valueVar, _) if (valueVar.name == iterVar.name):
										return compileForInFixed(iterVar, iterInit, bodyEls);
									default:
								}
							default:
						}
					default:
				}
			default:
		}
		return null;
	}

	function compileForInFixed(iterVar:TVar, iterInit:TypedExpr, bodyEls:Array<TypedExpr>):String {
		final iterName = "__iter_" + iterVar.name;
		final iterInitStr = main.compileExpressionOrError(iterInit);
		var result = new StringBuf();
		result.addMulti(iterName, ' = ', iterInitStr);
		result.addMulti('\nWHILE ', iterName, '.hasNext()');
		switch (bodyEls[0].expr) {
			case TVar(valueVar, _):
				final valueName = main.compileVarName(valueVar.name, bodyEls[0]);
				result.addMulti('\n\t', valueName, ' = ', iterName, '.next()');
			default:
		}
		final rest = bodyEls.slice(1);
		final compiledRest = compileBlockElements(rest);
		for (element in compiledRest) {
			result.addMulti('\n', element.tab());
		}
		result.add('\nEND WHILE');
		return result.toString();
	}

	function compileIf(econd:TypedExpr, ifExpr:TypedExpr, elseExpr:Null<TypedExpr>):String {
		var result = new StringBuf();
		final cond = condToBrightScript(econd, ifExpr, elseExpr);
		// Drain any pendingPrefix from condition compilation  
		final condPrefix = pendingPrefix.toString();
		pendingPrefix = new StringBuf();
		result.add(condPrefix);
		// Handle multi-line condition (e.g. TBlock as condition)
		if (cond.indexOf('\n') >= 0) {
			final lines = cond.split('\n');
			final lastLine = lines.pop();
			result.add(lines.join('\n') + '\n');
			result.addMulti('if ', lastLine, ' then:\n');
		} else {
			result.addMulti('if ', cond, ' then:\n');
		}
		result.add(toIndentedScope(ifExpr));
		if (elseExpr != null) {
			result.add('\n');
			result.add('else:\n');
			result.add(toIndentedScope(elseExpr));
		}
		result.add('\nend if');
		return result.toString();
	}

	function compileWhile(econd:TypedExpr, blockExpr:TypedExpr, normalWhile:Bool):String {
		var result = new StringBuf();
		final brsCond = main.compileExpressionOrError(econd);
		loopKindStack.push("while");
		if (normalWhile) {
			result.addMulti('WHILE ', brsCond, '\n');
			result.add(toIndentedScope(blockExpr));
		} else {
			result.add('WHILE true\n');
			result.add(toIndentedScope(blockExpr));
			result.addMulti('\tif ', brsCond, '\n');
			result.add("\t\tbreak");
		}
		loopKindStack.pop();
		result.add("\nEND WHILE");
		return result.toString();
	}

	function compileFor(tvar:TVar, iterExpr:TypedExpr, blockExpr:TypedExpr):String {
		var result = new StringBuf();
		loopKindStack.push("for");
		result.addMulti("for ", tvar.name, " in ", main.compileExpressionOrError(iterExpr), ':\n', toIndentedScope(blockExpr));
		loopKindStack.pop();
		return result.toString();
	}

	function compileTry(e:TypedExpr, catches:Array<{v:TVar, expr:TypedExpr}>):String {
		var result = new StringBuf();
		result.add('TRY\n');
		result.add(main.compileExpressionOrError(e).tab());
		if (catches.length > 0) {
			final c = catches[0];
			result.addMulti('\nCATCH ', main.compileVarName(c.v.name, c.expr), '\n');
			result.add(main.compileExpressionOrError(c.expr).tab());
		} else {
			result.add('\nCATCH e\n');
		}
		result.add('\nEND TRY');
		return result.toString();
	}

	function compileReturn(maybeExpr:Null<TypedExpr>):String {
		if (maybeExpr == null) return 'return';
		final unwrapped = unwrapStatementExpr(maybeExpr);
		// If returning a throw, just emit the throw (THROW is a statement, not an expression)
		switch (unwrapped.expr) {
			case TThrow(_):
				return main.compileExpressionOrError(maybeExpr);
			case TFunction(_):
				// For function expressions, put return before the function definition
				return 'return ' + main.compileExpressionOrError(maybeExpr);
			case TIf(_, _, _) | TSwitch(_, _, _) | TBlock(_):
				// For if/switch/block, hoist to temp var and return it
				final tmpName = '__tmp_${tempVarCounter++}';
				final hoisted = compileIfAsAssignment(unwrapped, tmpName);
				return hoisted + 'return $tmpName';
			case _:
		}
		var result = new StringBuf();
		switch maybeExpr.expr {
			case TMeta(_, expr):
				switch (expr.expr) {
					case TSwitch(e, cases, edef):
						result.add(switchToBrightScript(e, cases, edef, true));
					case _:
						final compiled = main.compileExpressionOrError(maybeExpr);
						final prefix = pendingPrefix.toString();
						pendingPrefix = new StringBuf();
						result.add(prefix);
						if (compiled.indexOf('\n') >= 0) {
							final tmpName = '__tmp_${tempVarCounter++}';
							final lines = compiled.split('\n');
							final lastLine = lines.pop();
							result.add(lines.join('\n') + '\n');
							result.addMulti(tmpName, ' = ', lastLine, '\n');
							result.addMulti('return ', tmpName);
						} else {
							result.addMulti('return ', compiled);
						}
				}
			case _:
				final compiled = main.compileExpressionOrError(maybeExpr);
				final prefix = pendingPrefix.toString();
				pendingPrefix = new StringBuf();
				result.add(prefix);
				if (compiled.indexOf('\n') >= 0) {
					final tmpName = '__tmp_${tempVarCounter++}';
					final lines = compiled.split('\n');
					final lastLine = lines.pop();
					result.add(lines.join('\n') + '\n');
					result.addMulti(tmpName, ' = ', lastLine, '\n');
					result.addMulti('return ', tmpName);
				} else {
					result.addMulti('return ', compiled);
				}
		}
		return result.toString();
	}

	// Check if an expression contains TBlock/TIf/TSwitch/TWhile/TFor at the immediate child level
	// (indicating it will compile to multi-line BRS that can't be used inline)
	function containsStatementExpr(expr:TypedExpr):Bool {
		return switch (expr.unwrapParenthesis().expr) {
			case TBlock(_) | TIf(_, _, _) | TSwitch(_, _, _) | TWhile(_, _, _) | TFor(_, _, _) | TTry(_, _): true;
			case TArray(e1, _): containsStatementExpr(e1);
			case TField(e, _): containsStatementExpr(e);
			case TBinop(_, e1, e2): containsStatementExpr(e1) || containsStatementExpr(e2);
			case TUnop(_, _, e): containsStatementExpr(e);
			case TCast(e, _): containsStatementExpr(e);
			case TMeta(_, e): containsStatementExpr(e);
			case TEnumParameter(e, _, _): containsStatementExpr(e);
			case TEnumIndex(e): containsStatementExpr(e);
			case _: false;
		};
	}

	function compileCast(expr:TypedExpr, maybeModuleType:Null<ModuleType>):String {
		// BRS is dynamically typed — casts are no-ops
		return main.compileExpressionOrError(expr);
	}

	function compileEnumParameter(expr:TypedExpr, enumField:EnumField, index:Int):String {
		var result = new StringBuf();
		result.add(main.compileExpressionOrError(expr));
		switch (enumField.type) {
			case TFun(args, _):
				if (index < args.length) {
					result.addMulti(".", args[index].name);
				}	
			case _:
		}
		return result.toString();
	}

	function compileEnumIndex(expr:TypedExpr):String {
		var result = new StringBuf();
		final isExtern = switch (expr.t) {
			case TEnum(_.get() => e, _): e.isReflaxeExtern();
			case _: false;
		}
		if (isExtern) {
			result.add("((");
		}
		result.add(main.compileExpressionOrError(expr));
		if (isExtern) {
			result.add(" as Variant) as int)");
		} else {
			result.add("._index");
		}
		return result.toString();
	}

	function compileSuperExpr(expr:TypedExpr):String {
		return switch (expr.t) {
			case TInst(clsRef, _):
				final cls = clsRef.get();
				final classPath = main.fullCallPath(cls).join('_');
				'${classPath}().CreateInstance()';
			case _:
				trace('compileSuperExpr ${expr.t}');
				'invalid !5!';
		}
	}

	function constantToBrightScript(constant:TConstant):String {
		return switch (constant) {
			case TInt(i): Std.string(i);
			case TFloat(s):
				final scientific = ~/^([+-]?(?:\d+\.\d+|\d+|\.\d+))[eE]([+-]?\d+)$/;
				if (scientific.match(s)) {
					final mantissa = scientific.matched(1);
					final exponent = scientific.matched(2);
					'($mantissa * (10 ^ $exponent))';
				} else {
					s;
				}
			case TString(s):
				final escapeMap = [
					"\n" => "\\n", // Newline
					"\t" => "\\t", // Tab
					"\r" => "\\r", // Carriage return
					"\u0008" => "\\b", // Backspace
					"\u000C" => "\\f", // Form feed
					"\u000B" => "\\v", // Vertical tab
					"\u0000" => "\\0", // Null character
					"\"" => "\"\"", // Double quote (BRS uses "" not \")
					"\\" => "\\\\" // Backslash
				];
				var str = s;
				for (key => value in escapeMap) {
					str = str.replace(key, value);
				}

				'"$str"';
			case TBool(b): b ? 'true' : 'false';
			case TNull: 'invalid';
			case TThis: 'm';
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
		// For assignments where RHS is if/switch/block, use compileIfAsAssignment
		switch op {
			case OpAssign | OpAssignOp(_):
				final needsHoist = switch (e2.unwrapParenthesis().expr) {
					case TIf(_, _, _): true;
					case TSwitch(_, _, _): true;
					case TBlock(_): true;
					case _: false;
				};
				if (needsHoist) {
					final lhs = main.compileExpressionOrError(e1);
					return compileIfAsAssignment(e2.unwrapParenthesis(), lhs);
				}
			case _:
		}

		// Hoist TIf/TSwitch/TBlock on LHS
		final lhsNeedsHoist = switch (e1.unwrapParenthesis().expr) {
			case TIf(_, _, _): true;
			case TSwitch(_, _, _): true;
			case TBlock(_): true;
			case _: false;
		};
		var expr1:Null<String>;
		if (lhsNeedsHoist) {
			final tmpName = '__tmp_${tempVarCounter++}';
			pendingPrefix.add(compileIfAsAssignment(e1.unwrapParenthesis(), tmpName));
			expr1 = tmpName;
		} else {
			// trace('================ !lhsNeedsHoist
			// $e1
			// ');
			expr1 = main.compileExpression(e1);
		}

		// Hoist TIf/TSwitch/TBlock on RHS
		final rhsNeedsHoist = switch (e2.unwrapParenthesis().expr) {
			case TIf(_, _, _): true;
			case TSwitch(_, _, _): true;
			case TBlock(_): true;
			case _: false;
		};
		var expr2:Null<String>;
		if (rhsNeedsHoist) {
			final tmpName = '__tmp_${tempVarCounter++}';
			pendingPrefix.add(compileIfAsAssignment(e2.unwrapParenthesis(), tmpName));
			expr2 = tmpName;
		} else {
			expr2 = main.compileExpression(e2);
		}

		final operatorStr = switch op {
			case OpEq: '=';
			case OpNotEq: '<>';
			case OpBoolAnd: 'AND';
			case OpBoolOr: 'OR';
			case OpAnd: 'AND';
			case OpOr: 'OR';
			case OpXor: 'XOR';
			case OpMod: 'MOD';
			case _: OperatorHelper.binopToString(op);
		};

		if (op.isAddition()) {
			if (checkForPrimitiveStringAddition(e1, e2, expr1, expr2))
				expr2 = 'Str($expr2)';
			if (checkForPrimitiveStringAddition(e2, e1, expr1, expr2))
				expr1 = 'Str($expr1)';
		}

		return '$expr1 $operatorStr $expr2';
	}

	function padArgumentDefaults(arguments:Array<TypedExpr>, clsRef, cfRef):Array<TypedExpr> {
		final cf:ClassField = cfRef.get();
		final funcData = cf.findFuncData(clsRef.get());
		if (funcData != null) {
			return funcData.replacePadNullsWithDefaults(arguments, ':noNullPad', main.generateInjectionExpression);
		}
		return arguments;
	}

	function callToBrightScript(calledExpr:TypedExpr, arguments:Array<TypedExpr>, originalExpr:TypedExpr):String {
		var nfcTypes = null;
		final originalExprType = originalExpr.t;
		var effectiveCalledExpr = calledExpr;
		switch (calledExpr.expr) {
			case TField(receiver, fa):
				final compiledReceiver = main.compileExpressionOrError(receiver);
				final receiverPrefix = pendingPrefix.toString();
				pendingPrefix = new StringBuf();
				final hoistedReceiver = extractMultilineValue(receiverPrefix + compiledReceiver);
				if (hoistedReceiver != null) {
					pendingPrefix.add(hoistedReceiver.prefix);
					final tempReceiver:TypedExpr = {
						expr: TIdent(hoistedReceiver.value),
						t: receiver.t,
						pos: receiver.pos
					};
					effectiveCalledExpr = {
						expr: TField(tempReceiver, fa),
						t: calledExpr.t,
						pos: calledExpr.pos
					};
				} else if (receiverPrefix.length > 0) {
					pendingPrefix.add(receiverPrefix);
				}
			case _:
		}
		switch (calledExpr.expr) {
			case TField(_, fa):
				switch (fa) {
					case FInstance(clsRef, _, cfRef):
						try {
							arguments = padArgumentDefaults(arguments, clsRef, cfRef);
						} catch (e:Dynamic) {}
					case FStatic(clsRef, cfRef):
						arguments = padArgumentDefaults(arguments, clsRef, cfRef);
					case _:
				}
			case _:
		}

		var nfc = main.compileNativeFunctionCodeMeta(effectiveCalledExpr, arguments, index -> {
			if (nfcTypes == null)
				nfcTypes = effectiveCalledExpr.getFunctionTypeParams(originalExprType);
			if (nfcTypes != null && index >= 0 && index < nfcTypes.length) {
				return main.TComp.compileType(nfcTypes[index], effectiveCalledExpr.pos);
			}
			return null;
		});

		if (nfc != null && nfc.indexOf('\n') >= 0) {
			switch (effectiveCalledExpr.expr) {
				case TField(receiver, fa):
					final compiledReceiver = main.compileExpressionOrError(receiver);
					final receiverPrefix = pendingPrefix.toString();
					pendingPrefix = new StringBuf();
					final hoistedReceiver = extractMultilineValue(receiverPrefix + compiledReceiver);
					if (hoistedReceiver != null) {
						pendingPrefix.add(hoistedReceiver.prefix);
						final tempReceiver:TypedExpr = {
							expr: TIdent(hoistedReceiver.value),
							t: receiver.t,
							pos: receiver.pos
						};
						final hoistedCalledExpr:TypedExpr = {
							expr: TField(tempReceiver, fa),
							t: effectiveCalledExpr.t,
							pos: effectiveCalledExpr.pos
						};
						nfc = main.compileNativeFunctionCodeMeta(hoistedCalledExpr, arguments, index -> {
							if (nfcTypes == null)
								nfcTypes = effectiveCalledExpr.getFunctionTypeParams(originalExprType);
							if (nfcTypes != null && index >= 0 && index < nfcTypes.length) {
								return main.TComp.compileType(nfcTypes[index], effectiveCalledExpr.pos);
							}
							return null;
						});
					} else if (receiverPrefix.length > 0) {
						pendingPrefix.add(receiverPrefix);
					}
				case _:
			}
		}
		if (nfc != null && nfc.indexOf('{arg') >= 0) {
			for (i in 0...arguments.length) {
				nfc = nfc.replace('{arg$i}', main.compileExpressionOrError(arguments[i]));
			}
		}

		if (nfc != null) {
			return nfc;
		}

		// Check FieldAccess
		final code = switch (effectiveCalledExpr.expr) {
			case TField(_, fa): {
					switch (fa) {
						case FEnum(_, _):
							final enumCall = compileEnumFieldCall(calledExpr, arguments);
							enumCall != null ? enumCall : null;

						case FStatic(classTypeRef, _.get() => cf):
							cf.meta.maybeHas(':constructor') ? newToBrightScript(classTypeRef, originalExpr, arguments) : null;

							case FInstance(clsRef, _, cfRef):
							try {
								arguments = padArgumentDefaults(arguments, clsRef, cfRef);
							} catch (e:Dynamic) {
								arguments = [];
							}

							null;

						case FStatic(clsRef, cfRef):
							arguments = padArgumentDefaults(arguments, clsRef, cfRef);
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
			final compiledArgs = new Array<{code:String, prefix:String, expr:TypedExpr}>();
			for (e in arguments) {
				final compiled = main.compileExpressionOrError(e);
				final prefix = pendingPrefix.toString();
				pendingPrefix = new StringBuf();
				compiledArgs.push({code: compiled, prefix: prefix, expr: e});
			}
			// Hoist multi-line arguments to temp variables (but not functions/object decls)
			final hoistedArgs = new Array<String>();
			for (i in 0...compiledArgs.length) { 
				final argInfo = compiledArgs[i];
				final arg = argInfo.code;
				final combinedArg = (argInfo.prefix.length > 0 ? argInfo.prefix : '') + arg;
				final argExpr = argInfo.expr;
				final normalizedArgExpr = unwrapStatementExpr(argExpr);
				if (combinedArg.indexOf('\n') >= 0 && combinedArg.indexOf('${Define.Function}(') >= 0 && combinedArg.indexOf(Define.EndFunction) >= 0) {
					final tmpName = '__tmp_${tempVarCounter++}';
					final lines = combinedArg.split('\n');
					var functionStart = -1;
					for (j in 0...lines.length) {
						if (lines[j].trim().startsWith('${Define.Function}(')) {
							functionStart = j;
							break;
						}
					}
					if (functionStart >= 0) {
						final prefixLines = lines.slice(0, functionStart);
						final functionLines = lines.slice(functionStart);
						if (prefixLines.length > 0) {
							result.add(prefixLines.join('\n') + '\n');
						}
						result.add('$tmpName = ${functionLines[0]}\n');
						for (j in 1...functionLines.length) {
							result.add('${functionLines[j]}\n');
						}
						hoistedArgs.push(tmpName);
						continue;
					}
				}
				final needsAstHoist = switch (normalizedArgExpr.expr) {
					case TIf(_, _, _): true;
					case TSwitch(_, _, _): true;
					case TBlock(_): true;
					case _: false;
				};
				final shouldNotHoist = switch (normalizedArgExpr.expr) {
					case TFunction(_): true;
					case TObjectDecl(_): true;
					case _: false;
				};
				if (needsAstHoist) {
					if (argInfo.prefix.length > 0) {
						result.add(argInfo.prefix);
					}
					final tmpName = '__tmp_${tempVarCounter++}';
					result.add(compileIfAsAssignment(normalizedArgExpr, tmpName));
					hoistedArgs.push(tmpName);
				} else if (combinedArg.indexOf('\n') >= 0 && !shouldNotHoist && combinedArg.indexOf('${Define.Function}(') < 0 && combinedArg.indexOf(Define.EndFunction) < 0) {
					final tmpName = '__tmp_${tempVarCounter++}';
					final lines = combinedArg.split('\n');
					final lastLine = lines.pop();
					result.add(lines.join('\n') + '\n');
					result.add('$tmpName = $lastLine\n');
					hoistedArgs.push(tmpName);
				} else {
					if (argInfo.prefix.length > 0) {
						result.add(argInfo.prefix);
					}
					hoistedArgs.push(arg);
				}
			}
			final prevCallTarget = isCallTarget;
			isCallTarget = true;
			final compiledCalledExpr = main.compileExpression(effectiveCalledExpr);
			isCallTarget = prevCallTarget;
			// Drain any pendingPrefix from calledExpr compilation
			final calledPrefix = pendingPrefix.toString();
			pendingPrefix = new StringBuf();
			if (calledPrefix.length > 0) {
				result.add(calledPrefix);
			}
			// Check if the call target could be a bound closure wrapper (AA)
			// This happens when a method reference (FClosure) was stored as a value.
			// Non-field-access calls (locals, array elements) need __callFnN__ dispatch.
			final needsBoundCheck = switch (effectiveCalledExpr.expr) {
				case TField(_, _): false;
				case _: true;
			};
			// If calledExpr is multi-line (e.g. chained on NFC with function arg),
			// hoist entire expression to temp var — but only when the multi-line content
			// is NOT from function arguments (which BRS handles natively in call parens)
			if (compiledCalledExpr.indexOf('\n') >= 0 && compiledCalledExpr.indexOf('${Define.Function}(') < 0) {
				final tmpName = '__tmp_${tempVarCounter++}';
				final lines = compiledCalledExpr.split('\n');
				final lastLine = lines.pop();
				result.add(lines.join('\n') + '\n');
				result.add('$tmpName = $lastLine\n');
				if (needsBoundCheck) {
					result.add('${FnCall(hoistedArgs.length)}($tmpName');
					if (hoistedArgs.length > 0) {
						result.add(', ');
						result.add(hoistedArgs.join(', '));
					}
					result.add(')');
				} else {
					result.add('$tmpName(');
					result.add(hoistedArgs.join(', '));
					result.add(')');
				}
			} else if (needsBoundCheck) {
				result.add('${FnCall(hoistedArgs.length)}(${Define.Ctx}, ${compiledCalledExpr}');
				if (hoistedArgs.length > 0) {
					result.add(', ');
					result.add(hoistedArgs.join(', '));
				}
				result.add(')');
			} else {
				result.add(compiledCalledExpr);
				result.add('(');
				result.add(hoistedArgs.join(', '));
				result.add(')');
			}
		}
		return result.toString();
	}

	function newToBrightScript(classTypeRef:Ref<ClassType>, originalExpr:TypedExpr, el:Array<TypedExpr>):String {
		final nfc = main.compileNativeFunctionCodeMeta(originalExpr, el);
		if (nfc != null) {
			return nfc;
		}

		final cls = classTypeRef.get();
		// haxe.iterators.ArrayIterator is in ignoreTypes — map to __BrsArrIter__
		if (cls.pack.length == 2 && cls.pack[0] == 'haxe' && cls.pack[1] == 'iterators' && cls.name == 'ArrayIterator') {
			final args = el.map(e -> main.compileExpression(e)).join(', ');
			return '__BrsArrIter__($args)';
		}

		final meta = originalExpr.getDeclarationMeta()?.meta;
		final native = meta == null ? '' : ({name: '', meta: meta}.getNameOrNative());
		final args = el.map(e -> main.compileExpression(e)).join(', ');

		if (native.length > 0) {
			return native + '($args)';
		} else {
			final meta = cls.meta.maybeExtract(':bindings_api_type');

			// Check for @:bindings_api_type("builtin_classes") metadata
			final builtin_class = meta.filter(m -> switch (m.params) {
				case [macro 'builtin_classes']: true;
				case _: false;
			}).length > 0;

			final classPath = main.fullCallPath(cls).join('_');

			return builtin_class ? '${classPath}_${cls.name}($args)' : '${classPath}().CreateInstance($args)';
		}
	}

	function unopToBrightScript(op:Unop, e:TypedExpr, isPostfix:Bool):String {
		final expr = main.compileExpressionOrError(e);
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
		// TODO: anonymous function scope issue
		return switch e.expr {
			case TParenthesis(e1): 
				// trace('======= TParenthesis
				// $e
				// ');	
				condToBrightScript(e1, eif, eelse);		
			default:
				// trace('======= default
				// $e
				// ');	
				main.compileExpressionOrError(e);
		}
	}

	function toIndentedScope(e:TypedExpr, ?isAnon:Bool = false):String {
		final result = new StringBuf();
		if(isAnon){
			trace('======= isAnon
			${e}
			');
		}
		switch (e.expr) {
			case TBlock(el):
				{
					if (el.length > 0) {
						final filtered = filterBlockReturnValue(el);
						final elements = compileBlockElements(filtered, isAnon);
						for (i in 0...elements.length) {
							result.add(elements[i].tab());
							if (i < elements.length - 1) {
								result.add('\n');
							}
						}
					} else {
						result.add('');
					}
				}
			case _:
				{
					final brsCode = main.compileExpression(e) ?? '';
					result.add(brsCode.tab());
				}
		}
		return result.toString();
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
			final conditions = c.values.map(v -> {
				if (externEnumType != null) {
					switch (v.expr) {
						case TConst(TInt(index)):
							{
								return externEnumType.names[index];
							}
						case _:
					}
				}
				final eCond = main.compileExpressionOrError(e);
				final vCond = main.compileExpressionOrError(v);
				return '$eCond = $vCond';
			});
			final sCond = index == 0 ? 'If' : 'Else If';
			index++;
			result.add('$sCond ${conditions.join(" OR ")} Then');
			final condExpr = main.compileExpressionOrError(c.expr).split('\n');
			compileSwitchCaseBody(result, condExpr, ret);
		}

		if (edef != null) {
			result.add("\nElse\n");
			final condExpr = main.compileExpressionOrError(edef).split('\n');
			compileSwitchCaseBody(result, condExpr, ret);
		}

		result.add("\nEnd If\n");
		return result.toString();
	}

	function compileSwitchCaseBody(result:StringBuf, condExpr:Array<String>, ret:String) {
		final lastLine = condExpr.pop();
		condExpr.push('$ret$lastLine');
		result.add('\n${condExpr.join('\n')}'.tab());
	}

	function switchToBrightScriptAssignment(e:TypedExpr, cases:Array<{values:Array<TypedExpr>, expr:TypedExpr}>, edef:TypedExpr, varName:String):String {
		final result = new StringBuf();
		var index = 0;
		for (c in cases) {
			result.add("\n");
			final conditions = c.values.map(v -> {
				final eCond = main.compileExpressionOrError(e);
				final vCond = main.compileExpressionOrError(v);
				return '$eCond = $vCond';
			});
			final sCond = index == 0 ? 'If' : 'Else If';
			index++;
			result.add('$sCond ${conditions.join(" OR ")} Then');
			compileSwitchAssignmentBody(result, c.expr, varName);
		}

		if (edef != null) {
			result.add("\nElse\n");
			compileSwitchAssignmentBody(result, edef, varName);
		}

		result.add("\nEnd If\n");
		return result.toString();
	}

	function compileSwitchAssignmentBody(result:StringBuf, expr:TypedExpr, varName:String):Void {
		result.add('\n');
		result.add(compileIfAsAssignment(expr, varName).tab());
	}

	function compileEnumFieldCall(e:TypedExpr, el:Array<TypedExpr>):Null<String> {
		switch (e.expr) {
			case TField(_, FEnum(enumRef, enumField)):
				final enumType = enumRef.get();
				if (enumType.isReflaxeExtern()) {
					final args = el.map(arg -> main.compileExpressionOrError(arg)).join(', ');
					return '${enumType.getNameOrNative()}.${enumField.name}($args)';
				}
				var prefix = new StringBuf();
				var result = new StringBuf();
				result.add('{"_index": ${enumField.index}');
				switch (enumField.type) {
					case TFun(args, _):
						for (i in 0...args.length) {
							if (i < el.length) {
								final argExpr = el[i];
								final needsHoist = switch (argExpr.unwrapParenthesis().expr) {
									case TIf(_, _, _): true;
									case TSwitch(_, _, _): true;
									case TBlock(_): true;
									case _: false;
								};
								if (needsHoist) {
									final tmpName = '__tmp_${tempVarCounter++}';
									prefix.add(compileIfAsAssignment(argExpr.unwrapParenthesis(), tmpName));
									result.addMulti(', "${args[i].name}": ', tmpName);
								} else {
									final compiled = main.compileExpressionOrError(argExpr);
									if (compiled.indexOf('\n') >= 0) {
										final tmpName = '__tmp_${tempVarCounter++}';
										final lines = compiled.split('\n');
										final lastLine = lines.pop();
										prefix.add(lines.join('\n') + '\n');
										prefix.add('$tmpName = $lastLine\n');
										result.addMulti(', "${args[i].name}": ', tmpName);
									} else {
										result.addMulti(', "${args[i].name}": ', compiled);
									}
								}
							}
						}
					case _:
				}
				result.add('}');
				pendingPrefix.add(prefix.toString());
				return result.toString();
			case _:
				return null;
		}
	}
}
