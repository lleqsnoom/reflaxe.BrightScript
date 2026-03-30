package;

class CryptoTests {
	var t:Main;

	public function new(main:Main) {
		t = main;
	}

	public function run() {
		t.section("CryptoMd5");
		checkMd5();
		t.section("CryptoSha1");
		checkSha1();
		t.section("CryptoSha256");
		checkSha256();
		t.section("CryptoSha224");
		checkSha224();
		t.section("CryptoBase64");
		checkBase64();
		t.section("CryptoCrc32");
		checkCrc32();
		t.section("CryptoAdler32");
		checkAdler32();
		t.section("CryptoHmac");
		checkHmac();
	}

	function checkMd5() {
		t.stringEquals("d41d8cd98f00b204e9800998ecf8427e", haxe.crypto.Md5.encode(""), "md5 empty");
		t.stringEquals("900150983cd24fb0d6963f7d28e17f72", haxe.crypto.Md5.encode("abc"), "md5 abc");
		t.stringEquals("5d41402abc4b2a76b9719d911017c592", haxe.crypto.Md5.encode("hello"), "md5 hello");
	}

	function checkSha1() {
		t.stringEquals("da39a3ee5e6b4b0d3255bfef95601890afd80709", haxe.crypto.Sha1.encode(""), "sha1 empty");
		t.stringEquals("a9993e364706816aba3e25717850c26c9cd0d89d", haxe.crypto.Sha1.encode("abc"), "sha1 abc");
		t.stringEquals("aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d", haxe.crypto.Sha1.encode("hello"), "sha1 hello");
	}

	function checkSha256() {
		t.stringEquals("e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855", haxe.crypto.Sha256.encode(""),
			"sha256 empty");
		t.stringEquals("ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad", haxe.crypto.Sha256.encode("abc"),
			"sha256 abc");
		t.stringEquals("2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824", haxe.crypto.Sha256.encode("hello"),
			"sha256 hello");
	}

	function checkSha224() {
		t.stringEquals("d14a028c2a3a2bc9476102bb288234c415a2b01f828ea62ac5b3e42f", haxe.crypto.Sha224.encode(""),
			"sha224 empty");
		t.stringEquals("23097d223405d8228642a477bda255b32aadbce4bda0b3f7e36c9da7", haxe.crypto.Sha224.encode("abc"),
			"sha224 abc");
	}

	function checkBase64() {
		var bytes = haxe.io.Bytes.ofString("Hello");
		var enc1 = haxe.crypto.Base64.encode(bytes);
		t.stringEquals("SGVsbG8=", enc1, "base64 encode Hello");
		var enc2 = haxe.crypto.Base64.encode(bytes, false);
		t.stringEquals("SGVsbG8", enc2, "base64 encode no pad");

		var decoded = haxe.crypto.Base64.decode("SGVsbG8=");
		t.stringEquals("Hello", decoded.toString(), "base64 decode Hello");

		var decoded2 = haxe.crypto.Base64.decode("SGVsbG8", false);
		t.stringEquals("Hello", decoded2.toString(), "base64 decode no pad");
	}

	function checkCrc32() {
		var data = haxe.io.Bytes.ofString("123456789");
		var crc = haxe.crypto.Crc32.make(data);
		t.intEquals(cast 0xCBF43926, crc, "crc32 check value");
	}

	function checkAdler32() {
		var data = haxe.io.Bytes.ofString("Wikipedia");
		var a = haxe.crypto.Adler32.make(data);
		t.stringEquals("11e60398", a.toString(), "adler32 Wikipedia");
	}

	function checkHmac() {
		var key = haxe.io.Bytes.ofString("key");
		var msg = haxe.io.Bytes.ofString("The quick brown fox jumps over the lazy dog");
		var hmac = new haxe.crypto.Hmac(haxe.crypto.HashMethod.MD5);
		var result = hmac.make(key, msg);
		t.stringEquals("80070713463e7749b90c2dc24911e275", result.toHex(), "hmac-md5");

		var hmacSha1 = new haxe.crypto.Hmac(haxe.crypto.HashMethod.SHA1);
		var result1 = hmacSha1.make(key, msg);
		t.stringEquals("de7c9b85b8b78aa6bc8a7a36f70a90701c9db4d9", result1.toHex(), "hmac-sha1");

		var hmacSha256 = new haxe.crypto.Hmac(haxe.crypto.HashMethod.SHA256);
		var result256 = hmacSha256.make(key, msg);
		t.stringEquals("f7bc83f430538424b13298e6aa6fb143ef4d59a14946175997479dbc2d1a3cd8", result256.toHex(), "hmac-sha256");
	}
}
