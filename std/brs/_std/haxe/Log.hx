package haxe;

class Log {
	public static dynamic function trace(v:Dynamic, ?infos:PosInfos):Void {
		if (infos != null) {
			untyped __brs__('Print {0}; ":";{1}; ": ";{2}', infos.fileName, infos.lineNumber, v);
		} else {
			untyped __brs__('Print {0}', v);
		}
	}
}
