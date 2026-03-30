package;

class XmlTests {
	var t:Main;

	public function new(main:Main) {
		t = main;
	}

	public function run() {
		t.section("XmlCreateElement");
		checkCreateElement();
		t.section("XmlCreateNodes");
		checkCreateNodes();
		t.section("XmlAttributes");
		checkAttributes();
		t.section("XmlAddChild");
		checkAddChild();
		t.section("XmlRemoveChild");
		checkRemoveChild();
		t.section("XmlInsertChild");
		checkInsertChild();
		t.section("XmlFirstChildElement");
		checkFirstChildElement();
		t.section("XmlIterator");
		checkIterator();
		t.section("XmlElements");
		checkElements();
		t.section("XmlElementsNamed");
		checkElementsNamed();
		t.section("XmlToString");
		checkToString();
		t.section("XmlParse");
		checkParse();
		t.section("XmlParseAttributes");
		checkParseAttributes();
		t.section("XmlParseNested");
		checkParseNested();
		t.section("XmlNodeTypes");
		checkNodeTypes();
		t.section("XmlParent");
		checkParent();
		t.section("XmlParseMixed");
		checkParseMixed();
	}

	function checkCreateElement() {
		var el = Xml.createElement("root");
		t.isTrue(el.nodeType == Xml.Element, "nodeType Element");
		t.stringEquals("root", el.nodeName, "nodeName");
	}

	function checkCreateNodes() {
		var pc = Xml.createPCData("hello");
		t.isTrue(pc.nodeType == Xml.PCData, "PCData nodeType");
		t.stringEquals("hello", pc.nodeValue, "PCData nodeValue");

		var cd = Xml.createCData("raw data");
		t.isTrue(cd.nodeType == Xml.CData, "CData nodeType");
		t.stringEquals("raw data", cd.nodeValue, "CData nodeValue");

		var cm = Xml.createComment("a comment");
		t.isTrue(cm.nodeType == Xml.Comment, "Comment nodeType");
		t.stringEquals("a comment", cm.nodeValue, "Comment nodeValue");

		var dt = Xml.createDocType("html");
		t.isTrue(dt.nodeType == Xml.DocType, "DocType nodeType");
		t.stringEquals("html", dt.nodeValue, "DocType nodeValue");

		var pi = Xml.createProcessingInstruction("xml v1");
		t.isTrue(pi.nodeType == Xml.ProcessingInstruction, "PI nodeType");
		t.stringEquals("xml v1", pi.nodeValue, "PI nodeValue");

		var doc = Xml.createDocument();
		t.isTrue(doc.nodeType == Xml.Document, "Document nodeType");
	}

	function checkAttributes() {
		var el = Xml.createElement("div");
		el.set("id", "main");
		el.set("class", "container");

		t.stringEquals("main", el.get("id"), "get id");
		t.stringEquals("container", el.get("class"), "get class");
		t.isTrue(el.exists("id"), "exists id");
		t.isFalse(el.exists("style"), "not exists style");

		// Iterate attributes
		var count = 0;
		var iter = el.attributes();
		while (iter.hasNext()) {
			iter.next();
			count++;
		}
		t.intEquals(2, count, "attribute count");

		// Remove attribute
		el.remove("class");
		t.isFalse(el.exists("class"), "removed class");
		t.isTrue(el.exists("id"), "id still exists");
	}

	function checkAddChild() {
		var root = Xml.createElement("root");
		var child1 = Xml.createElement("a");
		var child2 = Xml.createElement("b");
		var text = Xml.createPCData("hello");

		root.addChild(child1);
		root.addChild(text);
		root.addChild(child2);

		var fc = root.firstChild();
		t.stringEquals("a", fc.nodeName, "first child is a");

		// Count children
		var count = 0;
		var it = root.iterator();
		while (it.hasNext()) {
			it.next();
			count++;
		}
		t.intEquals(3, count, "3 children");
	}

	function checkRemoveChild() {
		var root = Xml.createElement("root");
		var a = Xml.createElement("a");
		var b = Xml.createElement("b");
		root.addChild(a);
		root.addChild(b);

		var removed = root.removeChild(a);
		t.isTrue(removed, "removeChild returns true");

		var count = 0;
		var it = root.iterator();
		while (it.hasNext()) {
			it.next();
			count++;
		}
		t.intEquals(1, count, "1 child after remove");

		var fc = root.firstChild();
		t.stringEquals("b", fc.nodeName, "remaining child is b");

		var removed2 = root.removeChild(a);
		t.isFalse(removed2, "removeChild nonexistent returns false");
	}

	function checkInsertChild() {
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
		t.stringEquals("abc", names, "insert at position 1");
	}

	function checkFirstChildElement() {
		var root = Xml.createElement("root");
		var t1 = Xml.createPCData("text");
		var el = Xml.createElement("child");
		root.addChild(t1);
		root.addChild(el);

		var fc = root.firstChild();
		t.isTrue(fc.nodeType == Xml.PCData, "firstChild is PCData");

		var fe = root.firstElement();
		t.stringEquals("child", fe.nodeName, "firstElement is child");
	}

	function checkIterator() {
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
		t.intEquals(4, count, "iterator count all");
	}

	function checkElements() {
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
		t.intEquals(2, count, "elements count");
	}

	function checkElementsNamed() {
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
		t.intEquals(2, count, "elementsNamed item count");

		var count2 = 0;
		var it2 = root.elementsNamed("none");
		while (it2.hasNext()) {
			it2.next();
			count2++;
		}
		t.intEquals(0, count2, "elementsNamed none count");
	}

	function checkToString() {
		// Element with no children
		var el = Xml.createElement("br");
		t.stringEquals("<br/>", el.toString(), "self-closing element");

		// Element with text
		var p = Xml.createElement("p");
		p.addChild(Xml.createPCData("hello"));
		t.stringEquals("<p>hello</p>", p.toString(), "element with text");

		// Element with attribute — check contains since quote char varies
		var div = Xml.createElement("div");
		div.set("id", "main");
		div.addChild(Xml.createPCData("content"));
		var ds = div.toString();
		t.isTrue(StringTools.contains(ds, "id="), "attr contains id=");
		t.isTrue(StringTools.contains(ds, "main"), "attr contains main");
		t.isTrue(StringTools.contains(ds, ">content</div>"), "attr contains content");

		// Nested elements
		var root = Xml.createElement("root");
		var child = Xml.createElement("child");
		child.addChild(Xml.createPCData("text"));
		root.addChild(child);
		t.stringEquals("<root><child>text</child></root>", root.toString(), "nested elements");

		// CData
		var cd = Xml.createCData("raw < data");
		t.stringEquals("<![CDATA[raw < data]]>", cd.toString(), "CData toString");

		// Comment
		var cm = Xml.createComment(" note ");
		t.stringEquals("<!-- note -->", cm.toString(), "Comment toString");

		// PI
		var pi = Xml.createProcessingInstruction("xml v1");
		t.stringEquals("<?xml v1?>", pi.toString(), "PI toString");

		// Entity escaping in text
		var esc = Xml.createElement("t");
		esc.addChild(Xml.createPCData("a < b & c > d"));
		t.stringEquals("<t>a &lt; b &amp; c &gt; d</t>", esc.toString(), "entity escaping");
	}

	function checkParse() {
		// Simple element
		var doc = Xml.parse("<root/>");
		var root = doc.firstElement();
		t.stringEquals("root", root.nodeName, "parse simple element");

		// Element with text
		var doc2 = Xml.parse("<p>hello</p>");
		var p = doc2.firstElement();
		t.stringEquals("p", p.nodeName, "parse element name");
		var fc = p.firstChild();
		t.isTrue(fc.nodeType == Xml.PCData, "parse text node type");
		t.stringEquals("hello", fc.nodeValue, "parse text value");

		// Self-closing
		var doc3 = Xml.parse("<br/>");
		var br = doc3.firstElement();
		t.stringEquals("br", br.nodeName, "parse self-closing");
	}

	function checkParseAttributes() {
		// Use single-quoted attributes for parsing (avoids BRS string escape issues)
		var sq = brs.Native.chr(39);
		var doc = Xml.parse("<div id=" + sq + "main" + sq + " class=" + sq + "big" + sq + ">text</div>");
		var div = doc.firstElement();
		t.stringEquals("div", div.nodeName, "parse attr element");
		t.stringEquals("main", div.get("id"), "parse attr id");
		t.stringEquals("big", div.get("class"), "parse attr class");
		var tc = div.firstChild();
		t.stringEquals("text", tc.nodeValue, "parse attr text content");
	}

	function checkParseNested() {
		var doc = Xml.parse("<root><a>1</a><b>2</b></root>");
		var root = doc.firstElement();
		t.stringEquals("root", root.nodeName, "parse nested root");

		var names = "";
		var it = root.elements();
		while (it.hasNext()) {
			var el = it.next();
			names = names + el.nodeName;
		}
		t.stringEquals("ab", names, "parse nested children");

		// Get text of first child element
		var aElem = root.firstElement();
		var aText = aElem.firstChild();
		t.stringEquals("1", aText.nodeValue, "parse nested text");
	}

	function checkNodeTypes() {
		// XmlType constants check (compare against each other)
		t.isTrue(Xml.Element == Xml.Element, "Xml.Element identity");
		t.isTrue(Xml.PCData == Xml.PCData, "Xml.PCData identity");
		t.isTrue(Xml.CData == Xml.CData, "Xml.CData identity");
		t.isTrue(Xml.Comment == Xml.Comment, "Xml.Comment identity");
		t.isTrue(Xml.DocType == Xml.DocType, "Xml.DocType identity");
		t.isTrue(Xml.ProcessingInstruction == Xml.ProcessingInstruction, "Xml.PI identity");
		t.isTrue(Xml.Document == Xml.Document, "Xml.Document identity");

		// All different
		t.isFalse(Xml.Element == Xml.PCData, "Element != PCData");
		t.isFalse(Xml.Element == Xml.Document, "Element != Document");

		// Document parse results in Document node
		var doc = Xml.parse("<r/>");
		t.isTrue(doc.nodeType == Xml.Document, "parse returns Document");
	}

	function checkParent() {
		var root = Xml.createElement("root");
		var child = Xml.createElement("child");
		root.addChild(child);

		t.stringEquals("root", child.parent.nodeName, "child parent is root");

		// Remove sets parent to null
		root.removeChild(child);
		var pIsNull:Bool = child.parent == null;
		t.isTrue(pIsNull, "removed child parent is null");
	}

	function checkParseMixed() {
		var doc = Xml.parse("<root><!--comment--><![CDATA[data]]>text</root>");
		var root = doc.firstElement();
		t.stringEquals("root", root.nodeName, "parse mixed root");

		var it = root.iterator();
		var first = it.next();
		t.isTrue(first.nodeType == Xml.Comment, "parsed comment type");
		t.stringEquals("comment", first.nodeValue, "parsed comment value");

		var second = it.next();
		t.isTrue(second.nodeType == Xml.CData, "parsed cdata type");
		t.stringEquals("data", second.nodeValue, "parsed cdata value");

		var third = it.next();
		t.isTrue(third.nodeType == Xml.PCData, "parsed text type");
		t.stringEquals("text", third.nodeValue, "parsed text value");
	}
}
