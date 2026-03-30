package;

import utest.Assert;

class HttpTests extends utest.Test {
	function testConstructor() {
		var http = new haxe.Http("http://example.com");
		Assert.equals("http://example.com", http.url);
		var rd:Dynamic = http.responseData;
		Assert.isTrue(rd == null);
	}

	function testUrl() {
		var http = new haxe.Http("http://first.com");
		Assert.equals("http://first.com", http.url);
		http.url = "http://second.com";
		Assert.equals("http://second.com", http.url);
	}

	function testSetHeader() {
		var http = new haxe.Http("http://example.com");
		http.setHeader("Content-Type", "application/json");
		http.setHeader("Accept", "text/html");
		var headers:Dynamic = Reflect.field(http, "headers");
		Assert.equals(2, headers.Count());
		http.setHeader("Content-Type", "text/plain");
		headers = Reflect.field(http, "headers");
		Assert.equals(2, headers.Count());
		Assert.equals("text/plain", headers[0].value);
	}

	function testAddHeader() {
		var http = new haxe.Http("http://example.com");
		http.addHeader("X-Custom", "val1");
		http.addHeader("X-Custom", "val2");
		var headers:Dynamic = Reflect.field(http, "headers");
		Assert.equals(2, headers.Count());
	}

	function testSetParameter() {
		var http = new haxe.Http("http://example.com");
		http.setParameter("key1", "val1");
		http.setParameter("key2", "val2");
		var params:Dynamic = Reflect.field(http, "params");
		Assert.equals(2, params.Count());
		http.setParameter("key1", "updated");
		params = Reflect.field(http, "params");
		Assert.equals(2, params.Count());
		Assert.equals("updated", params[0].value);
	}

	function testAddParameter() {
		var http = new haxe.Http("http://example.com");
		http.addParameter("key", "val1");
		http.addParameter("key", "val2");
		var params:Dynamic = Reflect.field(http, "params");
		Assert.equals(2, params.Count());
	}

	function testSetPostData() {
		var http = new haxe.Http("http://example.com");
		var pd:Dynamic = Reflect.field(http, "postData");
		Assert.isTrue(pd == null);
		http.setPostData("body content");
		pd = Reflect.field(http, "postData");
		Assert.equals("body content", pd);
		http.setPostData(null);
		pd = Reflect.field(http, "postData");
		Assert.isTrue(pd == null);
	}

	function testCallbacks() {
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
		Assert.isTrue(http.onData != null);
		Assert.isTrue(http.onError != null);
		Assert.isTrue(http.onStatus != null);
	}

	function testRequestNoTransfer() {
		var http = new haxe.Http("http://example.com");
		Reflect.setField(http, "_errorMsg", "");
		http.onError = function(msg:String) {
			untyped __brs__('m._errorMsg = {0}', msg);
		};
		http.request();
		var errorMsg:String = Reflect.field(http, "_errorMsg");
		Assert.isTrue(errorMsg != "");
		Assert.equals("roUrlTransfer not available", errorMsg);
	}

	function testRequestUrl() {
		var result = haxe.Http.requestUrl("http://example.com");
		Assert.equals("", result);
	}
}
