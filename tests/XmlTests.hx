package;

import utest.Assert;

class XmlTests extends utest.Test {
	function testCreateElement() {
		var el = Xml.createElement("root");
		Assert.isTrue(el.nodeType == Xml.Element);
		Assert.equals("root", el.nodeName);
	}

	function testCreateNodes() {
		var pc = Xml.createPCData("hello");
		Assert.isTrue(pc.nodeType == Xml.PCData);
		Assert.equals("hello", pc.nodeValue);

		var cd = Xml.createCData("raw data");
		Assert.isTrue(cd.nodeType == Xml.CData);
		Assert.equals("raw data", cd.nodeValue);

		var cm = Xml.createComment("a comment");
		Assert.isTrue(cm.nodeType == Xml.Comment);
		Assert.equals("a comment", cm.nodeValue);

		var dt = Xml.createDocType("html");
		Assert.isTrue(dt.nodeType == Xml.DocType);
		Assert.equals("html", dt.nodeValue);

		var pi = Xml.createProcessingInstruction("xml v1");
		Assert.isTrue(pi.nodeType == Xml.ProcessingInstruction);
		Assert.equals("xml v1", pi.nodeValue);

		var doc = Xml.createDocument();
		Assert.isTrue(doc.nodeType == Xml.Document);
	}

	function testAttributes() {
		var el = Xml.createElement("div");
		el.set("id", "main");
		el.set("class", "container");

		Assert.equals("main", el.get("id"));
		Assert.equals("container", el.get("class"));
		Assert.isTrue(el.exists("id"));
		Assert.isFalse(el.exists("style"));

		var count = 0;
		var iter = el.attributes();
		while (iter.hasNext()) {
			iter.next();
			count++;
		}
		Assert.equals(2, count);

		el.remove("class");
		Assert.isFalse(el.exists("class"));
		Assert.isTrue(el.exists("id"));
	}

	function testAddChild() {
		var root = Xml.createElement("root");
		var child1 = Xml.createElement("a");
		var child2 = Xml.createElement("b");
		var text = Xml.createPCData("hello");

		root.addChild(child1);
		root.addChild(text);
		root.addChild(child2);

		Assert.equals("a", root.firstChild().nodeName);

		var count = 0;
		var it = root.iterator();
		while (it.hasNext()) {
			it.next();
			count++;
		}
		Assert.equals(3, count);
	}

	function testRemoveChild() {
		var root = Xml.createElement("root");
		var a = Xml.createElement("a");
		var b = Xml.createElement("b");
		root.addChild(a);
		root.addChild(b);

		Assert.isTrue(root.removeChild(a));

		var count = 0;
		var it = root.iterator();
		while (it.hasNext()) {
			it.next();
			count++;
		}
		Assert.equals(1, count);
		Assert.equals("b", root.firstChild().nodeName);
		Assert.isFalse(root.removeChild(a));
	}

	function testInsertChild() {
		var root = Xml.createElement("root");
		var a = Xml.createElement("a");
		var b = Xml.createElement("b");
		var c = Xml.createElement("c");
		root.addChild(a);
		root.addChild(c);
		root.insertChild(b, 1);

		var names = "";
		var it = root.iterator();
		while (it.hasNext()) {
			var n = it.next();
			if (n.nodeType == Xml.Element)
				names = names + n.nodeName;
		}
		Assert.equals("abc", names);
	}

	function testFirstChildElement() {
		var root = Xml.createElement("root");
		var t1 = Xml.createPCData("text");
		var el = Xml.createElement("child");
		root.addChild(t1);
		root.addChild(el);

		Assert.isTrue(root.firstChild().nodeType == Xml.PCData);
		Assert.equals("child", root.firstElement().nodeName);
	}

	function testIterator() {
		var root = Xml.createElement("root");
		root.addChild(Xml.createPCData("text1"));
		root.addChild(Xml.createElement("a"));
		root.addChild(Xml.createPCData("text2"));
		root.addChild(Xml.createElement("b"));

		var count = 0;
		var it = root.iterator();
		while (it.hasNext()) {
			it.next();
			count++;
		}
		Assert.equals(4, count);
	}

	function testElements() {
		var root = Xml.createElement("root");
		root.addChild(Xml.createPCData("text"));
		root.addChild(Xml.createElement("x"));
		root.addChild(Xml.createElement("y"));

		var count = 0;
		var it = root.elements();
		while (it.hasNext()) {
			it.next();
			count++;
		}
		Assert.equals(2, count);
	}

	function testElementsNamed() {
		var root = Xml.createElement("root");
		root.addChild(Xml.createElement("item"));
		root.addChild(Xml.createElement("other"));
		root.addChild(Xml.createElement("item"));

		var count = 0;
		var it = root.elementsNamed("item");
		while (it.hasNext()) {
			it.next();
			count++;
		}
		Assert.equals(2, count);

		var count2 = 0;
		var it2 = root.elementsNamed("none");
		while (it2.hasNext()) {
			it2.next();
			count2++;
		}
		Assert.equals(0, count2);
	}

	function testToString() {
		var el = Xml.createElement("br");
		Assert.equals("<br/>", el.toString());

		var p = Xml.createElement("p");
		p.addChild(Xml.createPCData("hello"));
		Assert.equals("<p>hello</p>", p.toString());

		var div = Xml.createElement("div");
		div.set("id", "main");
		div.addChild(Xml.createPCData("content"));
		var ds = div.toString();
		Assert.isTrue(StringTools.contains(ds, "id="));
		Assert.isTrue(StringTools.contains(ds, "main"));
		Assert.isTrue(StringTools.contains(ds, ">content</div>"));

		var root = Xml.createElement("root");
		var child = Xml.createElement("child");
		child.addChild(Xml.createPCData("text"));
		root.addChild(child);
		Assert.equals("<root><child>text</child></root>", root.toString());

		var cd = Xml.createCData("raw < data");
		Assert.equals("<![CDATA[raw < data]]>", cd.toString());

		var cm = Xml.createComment(" note ");
		Assert.equals("<!-- note -->", cm.toString());

		var pi = Xml.createProcessingInstruction("xml v1");
		Assert.equals("<?xml v1?>", pi.toString());

		var esc = Xml.createElement("t");
		esc.addChild(Xml.createPCData("a < b & c > d"));
		Assert.equals("<t>a &lt; b &amp; c &gt; d</t>", esc.toString());
	}

	function testParse() {
		var doc = Xml.parse("<root/>");
		Assert.equals("root", doc.firstElement().nodeName);

		var doc2 = Xml.parse("<p>hello</p>");
		var p = doc2.firstElement();
		Assert.equals("p", p.nodeName);
		var fc = p.firstChild();
		Assert.isTrue(fc.nodeType == Xml.PCData);
		Assert.equals("hello", fc.nodeValue);

		var doc3 = Xml.parse("<br/>");
		Assert.equals("br", doc3.firstElement().nodeName);
	}

	function testParseAttributes() {
		var sq = brs.Native.chr(39);
		var doc = Xml.parse("<div id=" + sq + "main" + sq + " class=" + sq + "big" + sq + ">text</div>");
		var div = doc.firstElement();
		Assert.equals("div", div.nodeName);
		Assert.equals("main", div.get("id"));
		Assert.equals("big", div.get("class"));
		Assert.equals("text", div.firstChild().nodeValue);
	}

	function testParseNested() {
		var doc = Xml.parse("<root><a>1</a><b>2</b></root>");
		var root = doc.firstElement();
		Assert.equals("root", root.nodeName);

		var names = "";
		var it = root.elements();
		while (it.hasNext()) {
			names = names + it.next().nodeName;
		}
		Assert.equals("ab", names);

		Assert.equals("1", root.firstElement().firstChild().nodeValue);
	}

	function testNodeTypes() {
		Assert.isTrue(Xml.Element == Xml.Element);
		Assert.isTrue(Xml.PCData == Xml.PCData);
		Assert.isTrue(Xml.CData == Xml.CData);
		Assert.isTrue(Xml.Comment == Xml.Comment);
		Assert.isTrue(Xml.DocType == Xml.DocType);
		Assert.isTrue(Xml.ProcessingInstruction == Xml.ProcessingInstruction);
		Assert.isTrue(Xml.Document == Xml.Document);

		Assert.isFalse(Xml.Element == Xml.PCData);
		Assert.isFalse(Xml.Element == Xml.Document);

		var doc = Xml.parse("<r/>");
		Assert.isTrue(doc.nodeType == Xml.Document);
	}

	function testParent() {
		var root = Xml.createElement("root");
		var child = Xml.createElement("child");
		root.addChild(child);

		Assert.equals("root", child.parent.nodeName);

		root.removeChild(child);
		Assert.isTrue(child.parent == null);
	}

	function testParseMixed() {
		var doc = Xml.parse("<root><!--comment--><![CDATA[data]]>text</root>");
		var root = doc.firstElement();
		Assert.equals("root", root.nodeName);

		var it = root.iterator();
		var first = it.next();
		Assert.isTrue(first.nodeType == Xml.Comment);
		Assert.equals("comment", first.nodeValue);

		var second = it.next();
		Assert.isTrue(second.nodeType == Xml.CData);
		Assert.equals("data", second.nodeValue);

		var third = it.next();
		Assert.isTrue(third.nodeType == Xml.PCData);
		Assert.equals("text", third.nodeValue);
	}
}
