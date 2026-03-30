package;

import utest.Assert;

class MetaTests extends utest.Test {
	function testGetType() {
		var obj:Dynamic = {name: "test"};
		Assert.isTrue(haxe.rtti.Meta.getType(obj) == null);
	}

	function testGetFields() {
		var obj:Dynamic = {name: "test"};
		Assert.isTrue(haxe.rtti.Meta.getFields(obj) == null);
	}

	function testGetStatics() {
		var obj:Dynamic = {name: "test"};
		Assert.isTrue(haxe.rtti.Meta.getStatics(obj) == null);
	}
}
