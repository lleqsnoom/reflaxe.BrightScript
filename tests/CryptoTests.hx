package;

import utest.Assert;

class CryptoTests extends utest.Test {
	function testMd5() {
		Assert.equals("d41d8cd98f00b204e9800998ecf8427e", haxe.crypto.Md5.encode(""));
		Assert.equals("900150983cd24fb0d6963f7d28e17f72", haxe.crypto.Md5.encode("abc"));
		Assert.equals("5d41402abc4b2a76b9719d911017c592", haxe.crypto.Md5.encode("hello"));
	}

	function testSha1() {
		Assert.equals("da39a3ee5e6b4b0d3255bfef95601890afd80709", haxe.crypto.Sha1.encode(""));
		Assert.equals("a9993e364706816aba3e25717850c26c9cd0d89d", haxe.crypto.Sha1.encode("abc"));
		Assert.equals("aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d", haxe.crypto.Sha1.encode("hello"));
	}

	function testSha256() {
		Assert.equals("e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855", haxe.crypto.Sha256.encode(""));
		Assert.equals("ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad", haxe.crypto.Sha256.encode("abc"));
		Assert.equals("2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824", haxe.crypto.Sha256.encode("hello"));
	}

	function testSha224() {
		Assert.equals("d14a028c2a3a2bc9476102bb288234c415a2b01f828ea62ac5b3e42f", haxe.crypto.Sha224.encode(""));
		Assert.equals("23097d223405d8228642a477bda255b32aadbce4bda0b3f7e36c9da7", haxe.crypto.Sha224.encode("abc"));
	}

	function testBase64() {
		var bytes = haxe.io.Bytes.ofString("Hello");
		Assert.equals("SGVsbG8=", haxe.crypto.Base64.encode(bytes));
		Assert.equals("SGVsbG8", haxe.crypto.Base64.encode(bytes, false));

		Assert.equals("Hello", haxe.crypto.Base64.decode("SGVsbG8=").toString());
		Assert.equals("Hello", haxe.crypto.Base64.decode("SGVsbG8", false).toString());
	}

	function testCrc32() {
		var data = haxe.io.Bytes.ofString("123456789");
		var crc = haxe.crypto.Crc32.make(data);
		Assert.equals(cast 0xCBF43926, crc);
	}

	function testAdler32() {
		var data = haxe.io.Bytes.ofString("Wikipedia");
		var a = haxe.crypto.Adler32.make(data);
		Assert.equals("11e60398", a.toString());
	}

	function testHmac() {
		var key = haxe.io.Bytes.ofString("key");
		var msg = haxe.io.Bytes.ofString("The quick brown fox jumps over the lazy dog");

		var hmac = new haxe.crypto.Hmac(haxe.crypto.HashMethod.MD5);
		Assert.equals("80070713463e7749b90c2dc24911e275", hmac.make(key, msg).toHex());

		var hmacSha1 = new haxe.crypto.Hmac(haxe.crypto.HashMethod.SHA1);
		Assert.equals("de7c9b85b8b78aa6bc8a7a36f70a90701c9db4d9", hmacSha1.make(key, msg).toHex());

		var hmacSha256 = new haxe.crypto.Hmac(haxe.crypto.HashMethod.SHA256);
		Assert.equals("f7bc83f430538424b13298e6aa6fb143ef4d59a14946175997479dbc2d1a3cd8", hmacSha256.make(key, msg).toHex());
	}
}
