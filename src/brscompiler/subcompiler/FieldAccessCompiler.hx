package brscompiler.subcompiler;

import brscompiler.config.Meta;
import haxe.macro.Expr;
import haxe.macro.Type;

using reflaxe.helpers.BaseTypeHelper;
using reflaxe.helpers.ClassFieldHelper;
using reflaxe.helpers.ClassTypeHelper;
using reflaxe.helpers.ModuleTypeHelper;
using reflaxe.helpers.NameMetaHelper;
using reflaxe.helpers.NullableMetaAccessHelper;
using reflaxe.helpers.StringBufHelper;
using reflaxe.helpers.TypeHelper;

class FieldAccessCompiler {
	var main:brscompiler.BRSCompiler;

	public function new(main:brscompiler.BRSCompiler) {
		this.main = main;
	}

	public function fieldAccessToBrightScript(e:TypedExpr, fa:FieldAccess):String {
		return fieldAccessToBrightScriptResolved(main.compileExpression(e), e, fa);
	}

	public function fieldAccessToBrightScriptResolved(resolvedExpr:String, e:TypedExpr, fa:FieldAccess):String {
		final nameMeta:NameAndMeta = switch (fa) {
			case FInstance(_, _, classFieldRef): classFieldRef.get();
			case FStatic(_, classFieldRef): classFieldRef.get();
			case FAnon(classFieldRef): classFieldRef.get();
			case FClosure(_, classFieldRef): classFieldRef.get();
			case FEnum(_, enumField): enumField;
			case FDynamic(s): {name: s, meta: null};
		}

		final name = main.compileVarName(nameMeta.getNameOrNativeName());
		var bypassSelf = false;

		if (nameMeta.hasMeta(':native')) {
			return nameMeta.getNameOrNative();
		}
		if (nameMeta.hasMeta(':nativeName')) {
			return main.compileVarName(nameMeta.getNameOrNativeName());
		}

		switch (fa) {
			// Check if this is a self.field with BypassWrapper
			case FInstance(clsRef, _, clsFieldRef) if (main.selfStack.length > 0):
				{
					if (isSelfAccess(e)) {
						final isSameClass = switch (e.t) {
							case TInst(clsRef2, _) if (clsRef.get().name == clsRef2.get().name): true;
							case _: false;
						}
						if (isSameClass) {
							final selfData = main.selfStack[main.selfStack.length - 1];
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
					final className = main.TComp.compileClassName(cls);

					switch (cf.kind) {
						case FMethod(_): {
								final functionPath = main.fullCallPath(clsRef.get()).join('_') + '().' + name;
								return functionPath;
							}
						case _: {
								// If accessing a private static var from itself, don't include the class.
								final currentModule = main.getCurrentModule();
								switch (currentModule) {
									case TClassDecl(clsRef) if (clsRef.get().equals(cls)): {
											return 'm.__static__.$name';
										}
									case _:
								}
								// Static var accessed from different class — use singleton
								final functionPath = main.fullCallPath(clsRef.get()).join('_') + '().' + name;
								return functionPath;
							}
					}
				}

				case FEnum(enumRef, enumField):
				{
					final enumType = enumRef.get();
					if (enumType.isReflaxeExtern()) {
						trace("Reflaxe extern enum: " + enumType.getNameOrNative());
						return enumType.getNameOrNative() + "." + enumField.name;
					}

					return '{"_index":${enumField.index}}';
				}
			case _: //do nothing
		}

		// Do not use `self.` on `@:const` variables.
		switch (fa) {
			case FInstance(clsRef, _, clsFieldRef):
				{
					if (isSelfAccess(e) && clsFieldRef.get().hasMeta(Meta.Const)) {
						return name;
					}
				}
			case _:
		}

		final expr = bypassSelf ? 'self' : resolvedExpr;
		switch (fa) {
			case FAnon(classFieldRef):
				{
					return expr + '.${classFieldRef.get().name}';
				}
			case _:
		}

		if (bypassSelf) {
			return 'self.$name';
		} else if (isSelfAccess(e)) {
			return 'm.$name';
		}
		final resolvedExpr = expr != null ? expr : "m";
		return '${resolvedExpr}.$name';
	}

	inline function isSelfAccess(e:TypedExpr):Bool {
		return switch (e.expr) {
			case TConst(TThis): true;
			case _: false;
		}
	}
}
