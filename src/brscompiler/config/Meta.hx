package brscompiler.config;

enum abstract Meta(String) from String to String {
	var OnReady = ":onready";
	var Const = ":const";
	var Signal = ":signal";
	var Icon = ":icon";
	var OutputFile = ":outputFile";
	var DontAddToPlugin = ":dontAddToPlugin";
	var Wrapper = ":wrapper";
	var WrapPublicOnly = ":wrapPublicOnly";
	var BypassWrapper = ":bypass_wrapper";
}
