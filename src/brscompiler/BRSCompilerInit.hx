package brscompiler;

#if (macro || brs_runtime)
import haxe.macro.Context;
import reflaxe.BaseCompiler;
import reflaxe.ReflectCompiler;
import reflaxe.data.ClassFuncData;
import reflaxe.preprocessors.BasePreprocessor;
import reflaxe.preprocessors.ExpressionPreprocessor;

class BRSCompilerInit {
	public static function Start() {
		#if !eval
		Sys.println("BRSCompilerInit.Start can only be called from a macro context.");
		return;
		#end

		#if (haxe_ver < "4.3.0")
		Sys.println("Reflaxe/brightscript requires Haxe version 4.3.0 or greater.");
		return;
		#end

		ReflectCompiler.AddCompiler(new BRSCompiler(), {
			expressionPreprocessors: [
				SanitizeEverythingIsExpression({
					convertIncrementAndDecrementOperators: true
				}),
				RemoveTemporaryVariables(OnlyAvoidTemporaryFieldAccess),
				PreventRepeatVariables({}),
				WrapLambdaCaptureVariablesInArray({}),
				RemoveSingleExpressionBlocks,
				RemoveConstantBoolIfs,
				RemoveUnnecessaryBlocks,
				RemoveReassignedVariableDeclarations,
				RemoveLocalVariableAliases,
				MarkUnusedVariables,
			],
			fileOutputExtension: ".brs",
			outputDirDefineName: "brightscript-output",
			fileOutputType: SingleFile,
			// fileOutputType: FilePerClass,
			reservedVarNames: reservedNames(),
			targetCodeInjectionName: "__brs__",
			trackUsedTypes: true,

			ignoreTypes: ["haxe.iterators.ArrayIterator"],
		});
	}

	static function reservedNames() {
		return ["pos", "end", "stop", "tab", "line", "next", "step", "run"];
	}
}
#end
