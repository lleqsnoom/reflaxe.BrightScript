package;

class HttpTests {
	var t:Main;

	public function new(main:Main) {
		t = main;
	}

	public function run() {
		t.section("HttpConstructor");
		checkConstructor();
		t.section("HttpUrl");
		checkUrl();
		t.section("HttpSetHeader");
		checkSetHeader();
		t.section("HttpAddHeader");
		checkAddHeader();
		t.section("HttpSetParameter");
		checkSetParameter();
		t.section("HttpAddParameter");
		checkAddParameter();
		t.section("HttpSetPostData");
		checkSetPostData();
		t.section("HttpCallbacks");
		checkCallbacks();
		t.section("HttpRequestNoTransfer");
		checkRequestNoTransfer();
		t.section("HttpRequestUrl");
		checkRequestUrl();
	}

	function checkConstructor() {
		var http = new haxe.Http("http://example.com");
		t.stringEquals("http://example.com", http.url, "url set by constructor");
		var rd:Dynamic = http.responseData;
		t.isTrue(rd == null, "responseData initially null");
	}

	function checkUrl() {
		var http = new haxe.Http("http://first.com");
		t.stringEquals("http://first.com", http.url, "url is first value");
		http.url = "http://second.com";
		t.stringEquals("http://second.com", http.url, "url updated");
	}

	function checkSetHeader() {
		var http = new haxe.Http("http://example.com");
		http.setHeader("Content-Type", "application/json");
		http.setHeader("Accept", "text/html");
		var headers:Dynamic = Reflect.field(http, "headers");
		t.intEquals(2, headers.Count(), "two distinct headers");
		// Replace existing header
		http.setHeader("Content-Type", "text/plain");
		headers = Reflect.field(http, "headers");
		t.intEquals(2, headers.Count(), "setHeader replaces, still 2");
		t.stringEquals("text/plain", headers[0].value, "header value replaced");
	}

	function checkAddHeader() {
		var http = new haxe.Http("http://example.com");
		http.addHeader("X-Custom", "val1");
		http.addHeader("X-Custom", "val2");
		var headers:Dynamic = Reflect.field(http, "headers");
		t.intEquals(2, headers.Count(), "addHeader allows duplicates");
	}

	function checkSetParameter() {
		var http = new haxe.Http("http://example.com");
		http.setParameter("key1", "val1");
		http.setParameter("key2", "val2");
		var params:Dynamic = Reflect.field(http, "params");
		t.intEquals(2, params.Count(), "two distinct params");
		// Replace existing param
		http.setParameter("key1", "updated");
		params = Reflect.field(http, "params");
		t.intEquals(2, params.Count(), "setParameter replaces, still 2");
		t.stringEquals("updated", params[0].value, "param value replaced");
	}

	function checkAddParameter() {
		var http = new haxe.Http("http://example.com");
		http.addParameter("key", "val1");
		http.addParameter("key", "val2");
		var params:Dynamic = Reflect.field(http, "params");
		t.intEquals(2, params.Count(), "addParameter allows duplicates");
	}

	function checkSetPostData() {
		var http = new haxe.Http("http://example.com");
		var pd:Dynamic = Reflect.field(http, "postData");
		t.isTrue(pd == null, "postData initially null");
		http.setPostData("body content");
		pd = Reflect.field(http, "postData");
		t.stringEquals("body content", pd, "postData set");
		http.setPostData(null);
		pd = Reflect.field(http, "postData");
		t.isTrue(pd == null, "postData cleared to null");
	}

	function checkCallbacks() {
		var http = new haxe.Http("http://example.com");
		var dataCalled = false;
		var errorCalled = false;
		var statusCode = 0;
		http.onData = function(data:String) {
			dataCalled = true;
		};
		http.onError = function(msg:String) {
			errorCalled = true;
		};
		http.onStatus = function(status:Int) {
			statusCode = status;
		};
		var hasOnData:Bool = http.onData != null;
		var hasOnError:Bool = http.onError != null;
		var hasOnStatus:Bool = http.onStatus != null;
		t.isTrue(hasOnData, "onData callback assigned");
		t.isTrue(hasOnError, "onError callback assigned");
		t.isTrue(hasOnStatus, "onStatus callback assigned");
	}

	function checkRequestNoTransfer() {
		// In the brs emulator, roUrlTransfer is not available
		// request() should call onError. Since BRS closures can't capture outer
		// local variables, we verify via m (the caller AA) inside the callback.
		var http = new haxe.Http("http://example.com");
		Reflect.setField(http, "_errorMsg", "");
		http.onError = function(msg:String) {
			// When called as self.onError(msg), m refers to self (the http AA)
			untyped __brs__('m._errorMsg = {0}', msg);
		};
		http.request();
		var errorMsg:String = Reflect.field(http, "_errorMsg");
		var hasError = errorMsg != "";
		t.isTrue(hasError, "request calls onError when roUrlTransfer unavailable");
		t.stringEquals("roUrlTransfer not available", errorMsg, "error message correct");
	}

	function checkRequestUrl() {
		// In the brs emulator, roUrlTransfer is not available
		// requestUrl returns empty string
		var result = haxe.Http.requestUrl("http://example.com");
		t.stringEquals("", result, "requestUrl returns empty when no roUrlTransfer");
	}
}
