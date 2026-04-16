package haxe;

extern class Http {
	public var url:String;
	public var responseData(get, never):Null<String>;
	public var onData:Dynamic;
	public var onError:Dynamic;
	public var onStatus:Dynamic;

	@:nativeFunctionCode("__Http_new__({arg0})")
	public function new(url:String):Void;

	@:nativeFunctionCode("__Http_setHeader__({this}, {arg0}, {arg1})")
	public function setHeader(name:String, value:String):Void;

	@:nativeFunctionCode("__Http_addHeader__({this}, {arg0}, {arg1})")
	public function addHeader(name:String, value:String):Void;

	@:nativeFunctionCode("__Http_setParameter__({this}, {arg0}, {arg1})")
	public function setParameter(name:String, value:String):Void;

	@:nativeFunctionCode("__Http_addParameter__({this}, {arg0}, {arg1})")
	public function addParameter(name:String, value:String):Void;

	@:nativeFunctionCode("__Http_setPostData__({this}, {arg0})")
	public function setPostData(data:Null<String>):Void;

	@:runtime inline public function request(?post:Bool):Void {
		BrsHttp.doRequest(this, post);
	}

	@:nativeFunctionCode("__Http_requestUrl__({arg0})")
	public static function requestUrl(url:String):String;

	@:nativeFunctionCode("{this}.responseData")
	private function get_responseData():Null<String>;
}

private extern class BrsHttp {
	@:nativeFunctionCode("__Http_request__({arg0}, {arg1})")
	static function doRequest(self:Dynamic, post:Dynamic):Void;
}

// --- @:brs_global helper functions ---

@:keep @:brs_global function __Http_new__(url:Dynamic):Dynamic {
	untyped __brs__('
		__h = {"url": {0}, "headers": [], "params": [], "postData": invalid, "responseData": invalid, "onData": invalid, "onError": invalid, "onStatus": invalid}
	', url);
	return untyped __brs__('__h');
}

@:keep @:brs_global function __Http_setHeader__(self:Dynamic, name:Dynamic, value:Dynamic):Void {
	untyped __brs__('
		__h_found = false
		for __h_i = 0 to {0}.headers.Count() - 1
			if {0}.headers[__h_i].name = {1} then
				{0}.headers[__h_i] = {"name": {1}, "value": {2}}
				__h_found = true
				exit for
			end if
		end for
		if not __h_found then
			{0}.headers.Push({"name": {1}, "value": {2}})
		end if
	', self, name, value);
	// return untyped __brs__('invalid !31!');
}

@:keep @:brs_global function __Http_addHeader__(self:Dynamic, name:Dynamic, value:Dynamic):Void {
	untyped __brs__('{0}.headers.Push({"name": {1}, "value": {2}})', self, name, value);
	// return untyped __brs__('invalid !32!');
}

@:keep @:brs_global function __Http_setParameter__(self:Dynamic, name:Dynamic, value:Dynamic):Void {
	untyped __brs__('
		__h_found = false
		for __h_i = 0 to {0}.params.Count() - 1
			if {0}.params[__h_i].name = {1} then
				{0}.params[__h_i] = {"name": {1}, "value": {2}}
				__h_found = true
				exit for
			end if
		end for
		if not __h_found then
			{0}.params.Push({"name": {1}, "value": {2}})
		end if
	', self, name, value);
	// return untyped __brs__('invalid !33!');
}

@:keep @:brs_global function __Http_addParameter__(self:Dynamic, name:Dynamic, value:Dynamic):Void {
	untyped __brs__('{0}.params.Push({"name": {1}, "value": {2}})', self, name, value);
	// return untyped __brs__('invalid !34!');
}

@:keep @:brs_global function __Http_setPostData__(self:Dynamic, data:Dynamic):Void {
	brs.Native.fieldSet(self, "postData", data);
	// return untyped __brs__('invalid !35!');
}

@:keep @:brs_global function __Http_request__(self:Dynamic, post:Dynamic):Void {
	untyped __brs__('
		__h_url = {0}.url
		if {0}.params.Count() > 0 then
			__h_sep = "?"
			if Instr(1, __h_url, "?") > 0 then __h_sep = "&"
			for each __h_p in {0}.params
				__h_url = __h_url + __h_sep + __h_p.name + "=" + __h_p.value
				__h_sep = "&"
			end for
		end if

		__h_post = {1}
		if __h_post = invalid then __h_post = false
		if {0}.postData <> invalid then __h_post = true

		__h_ut = invalid
		try
			__h_ut = CreateObject("roUrlTransfer")
		catch __h_e
			__h_ut = invalid
		end try
		if __h_ut = invalid then
			if {0}.onError <> invalid then {0}.onError("roUrlTransfer not available")
		else
			__h_ut.SetUrl(__h_url)
			if Left(__h_url, 5) = "https" then
				__h_ut.SetCertificatesFile("common:/certs/ca-bundle.crt")
				__h_ut.InitClientCertificates()
			end if

			for each __h_hdr in {0}.headers
				__h_ut.AddHeader(__h_hdr.name, __h_hdr.value)
			end for

			if __h_post = true then
				__h_body = ""
				if {0}.postData <> invalid then __h_body = {0}.postData
				__h_result = __h_ut.PostFromString(__h_body)
			else
				__h_result = __h_ut.GetToString()
			end if

			__h_code = __h_ut.GetResponseCode()
			if {0}.onStatus <> invalid then {0}.onStatus(__h_code)

			if __h_code >= 200 and __h_code < 300 then
				{0}.responseData = __h_result
				if {0}.onData <> invalid then {0}.onData(__h_result)
			else
				if {0}.onError <> invalid then {0}.onError("Http Error #" + Str(__h_code).Trim())
			end if
		end if
	', self, post);
	// return untyped __brs__('invalid !36!');
}

@:keep @:brs_global function __Http_requestUrl__(url:Dynamic):Dynamic {
	untyped __brs__('
		__h_ut = invalid
		__h_result = ""
		try
			__h_ut = CreateObject("roUrlTransfer")
		catch __h_e
			__h_ut = invalid
		end try
		if __h_ut <> invalid then
			__h_ut.SetUrl({0})
			if Left({0}, 5) = "https" then
				__h_ut.SetCertificatesFile("common:/certs/ca-bundle.crt")
				__h_ut.InitClientCertificates()
			end if
			__h_result = __h_ut.GetToString()
		end if
	', url);
	return untyped __brs__('__h_result');
}
