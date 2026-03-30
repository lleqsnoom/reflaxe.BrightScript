package;

class Sys {
	public static function print(v:Dynamic):Void {
		untyped __brs__('Print {0};', v);
	}

	public static function println(v:Dynamic):Void {
		untyped __brs__('Print {0}', v);
	}

	public static function time():Float {
		return untyped __brs__('CreateObject("roTimespan").TotalMilliseconds() / 1000.0');
	}

	public static function cpuTime():Float {
		return time();
	}

	public static function systemName():String {
		return "BrightScript";
	}

	public static function args():Array<String> {
		return [];
	}

	public static function getEnv(s:String):Dynamic {
		return null;
	}

	public static function putEnv(s:String, v:Dynamic):Void {}

	public static function environment():Map<String, String> {
		return new Map<String, String>();
	}

	public static function sleep(seconds:Float):Void {
		untyped __brs__('Sleep(Int({0} * 1000))', seconds);
	}

	public static function getCwd():String {
		return "";
	}

	public static function setCwd(s:String):Void {}

	public static function exit(code:Int):Void {
		untyped __brs__('End');
	}

	public static function command(cmd:String, ?args:Array<String>):Int {
		return -1;
	}

	public static function programPath():String {
		return "";
	}

	@:deprecated("Use programPath instead")
	public static function executablePath():String {
		return programPath();
	}

	public static function setTimeLocale(loc:String):Bool {
		return false;
	}

	public static function getChar(echo:Bool):Int {
		return -1;
	}
}
