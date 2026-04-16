package;

enum abstract XmlType(Int) {
	var Element = 0;
	var PCData = 1;
	var CData = 2;
	var Comment = 3;
	var DocType = 4;
	var ProcessingInstruction = 5;
	var Document = 6;
}

extern class Xml {
	@:nativeFunctionCode("0")
	static var Element(default, never):XmlType;

	@:nativeFunctionCode("1")
	static var PCData(default, never):XmlType;

	@:nativeFunctionCode("2")
	static var CData(default, never):XmlType;

	@:nativeFunctionCode("3")
	static var Comment(default, never):XmlType;

	@:nativeFunctionCode("4")
	static var DocType(default, never):XmlType;

	@:nativeFunctionCode("5")
	static var ProcessingInstruction(default, never):XmlType;

	@:nativeFunctionCode("6")
	static var Document(default, never):XmlType;

	@:nativeFunctionCode("__Xml_parse__({arg0})")
	static function parse(str:String):Xml;

	@:nativeFunctionCode("__Xml_createElement__({arg0})")
	static function createElement(name:String):Xml;

	@:nativeFunctionCode("__Xml_createPCData__({arg0})")
	static function createPCData(data:String):Xml;

	@:nativeFunctionCode("__Xml_createCData__({arg0})")
	static function createCData(data:String):Xml;

	@:nativeFunctionCode("__Xml_createComment__({arg0})")
	static function createComment(data:String):Xml;

	@:nativeFunctionCode("__Xml_createDocType__({arg0})")
	static function createDocType(data:String):Xml;

	@:nativeFunctionCode("__Xml_createPI__({arg0})")
	static function createProcessingInstruction(data:String):Xml;

	@:nativeFunctionCode("__Xml_createDocument__()")
	static function createDocument():Xml;

	// Properties
	public var nodeType(default, null):XmlType;
	public var nodeName:String;
	public var nodeValue:String;
	public var parent(default, null):Xml;

	// Attribute methods
	@:nativeFunctionCode("__Xml_get__({this}, {arg0})")
	function get(att:String):String;

	@:nativeFunctionCode("__Xml_set__({this}, {arg0}, {arg1})")
	function set(att:String, value:String):Void;

	@:nativeFunctionCode("__Xml_remove__({this}, {arg0})")
	function remove(att:String):Void;

	@:nativeFunctionCode("__Xml_exists__({this}, {arg0})")
	function exists(att:String):Bool;

	@:nativeFunctionCode("__Xml_attributes__({this})")
	function attributes():Iterator<String>;

	// Child iteration
	@:nativeFunctionCode("__Xml_iterator__({this})")
	function iterator():Iterator<Xml>;

	@:nativeFunctionCode("__Xml_elements__({this})")
	function elements():Iterator<Xml>;

	@:nativeFunctionCode("__Xml_elementsNamed__({this}, {arg0})")
	function elementsNamed(name:String):Iterator<Xml>;

	@:nativeFunctionCode("__Xml_firstChild__({this})")
	function firstChild():Xml;

	@:nativeFunctionCode("__Xml_firstElement__({this})")
	function firstElement():Xml;

	// Tree manipulation
	@:nativeFunctionCode("__Xml_addChild__({this}, {arg0})")
	function addChild(x:Xml):Void;

	@:nativeFunctionCode("__Xml_removeChild__({this}, {arg0})")
	function removeChild(x:Xml):Bool;

	@:nativeFunctionCode("__Xml_insertChild__({this}, {arg0}, {arg1})")
	function insertChild(x:Xml, pos:Int):Void;

	// Serialization
	@:nativeFunctionCode("__Xml_toString__({this})")
	function toString():String;
}

// --- Node creation ---

@:keep @:brs_global function __Xml_nextId__():Int {
	untyped __brs__('
		if m.DoesExist("__xml_id_ctr__") = false then m["__xml_id_ctr__"] = 0
		m["__xml_id_ctr__"] = m["__xml_id_ctr__"] + 1
	');
	return untyped __brs__('m["__xml_id_ctr__"]');
}

@:keep @:brs_global function __Xml_createNode__(nodeType:Int, nodeName:String, nodeValue:String):Dynamic {
	return untyped __brs__('{"nodeType": {0}, "nodeName": {1}, "nodeValue": {2}, "parent": invalid, "children": [], "attrs": {}, "_id": __Xml_nextId__()}', nodeType, nodeName, nodeValue);
}

@:keep @:brs_global function __Xml_createElement__(name:String):Dynamic {
	final node:Dynamic = untyped __brs__('__Xml_createNode__(0, {0}, "")', name);
	untyped __brs__('__xa = {}');
	brs.Native.setCaseSensitive(untyped __brs__('__xa'));
	brs.Native.fieldSet(node, "attrs", untyped __brs__('__xa'));
	return node;
}

@:keep @:brs_global function __Xml_createPCData__(data:String):Dynamic {
	return untyped __brs__('__Xml_createNode__(1, "", {0})', data);
}

@:keep @:brs_global function __Xml_createCData__(data:String):Dynamic {
	return untyped __brs__('__Xml_createNode__(2, "", {0})', data);
}

@:keep @:brs_global function __Xml_createComment__(data:String):Dynamic {
	return untyped __brs__('__Xml_createNode__(3, "", {0})', data);
}

@:keep @:brs_global function __Xml_createDocType__(data:String):Dynamic {
	return untyped __brs__('__Xml_createNode__(4, "", {0})', data);
}

@:keep @:brs_global function __Xml_createPI__(data:String):Dynamic {
	return untyped __brs__('__Xml_createNode__(5, "", {0})', data);
}

@:keep @:brs_global function __Xml_createDocument__():Dynamic {
	return untyped __brs__('__Xml_createNode__(6, "", "")');
}

// --- Attribute access ---

@:keep @:brs_global function __Xml_get__(self:Dynamic, att:String):Dynamic {
	var attrs:Dynamic = brs.Native.fieldGet(self, "attrs");
	var has:Bool = brs.Native.doesExist(attrs, att);
	if (has == true) {
		return brs.Native.fieldGet(attrs, att);
	}
	return null;
	// return untyped __brs__('invalid !15!');
}

@:keep @:brs_global function __Xml_set__(self:Dynamic, att:String, value:String):Dynamic {
	var attrs:Dynamic = brs.Native.fieldGet(self, "attrs");
	brs.Native.fieldSet(attrs, att, value);
	return value;
	// return untyped __brs__('invalid !16!');
}

@:keep @:brs_global function __Xml_remove__(self:Dynamic, att:String):Dynamic {
	var attrs:Dynamic = brs.Native.fieldGet(self, "attrs");
	untyped __brs__('{0}.Delete({1})', attrs, att);
	return att;
	// return untyped __brs__('invalid !17!');
}

@:keep @:brs_global function __Xml_exists__(self:Dynamic, att:String):Dynamic {
	var attrs:Dynamic = brs.Native.fieldGet(self, "attrs");
	var has:Bool = brs.Native.doesExist(attrs, att);
	if (has == true)
		return untyped __brs__('true');
	return untyped __brs__('false');
}

// --- Iterator factory ---

@:keep @:brs_global function __Xml_makeIterator__(arr:Dynamic):Dynamic {
	untyped __brs__('
		__xit = {
			"a": {0},
			"i": 0,
			"hasNext": function() as Boolean
				return m.i < m.a.Count()
			end function,
			"next": function() as Object
				__v = m.a[m.i]
				m.i = m.i + 1
				return __v
			end function
		}
	', arr);
	return untyped __brs__('__xit');
}

// --- Attribute iterator ---

@:keep @:brs_global function __Xml_attributes__(self:Dynamic):Dynamic {
	var attrs:Dynamic = brs.Native.fieldGet(self, "attrs");
	return untyped __brs__('__Xml_makeIterator__({0})', brs.Native.keys(attrs));
}

// --- Child iterators ---

@:keep @:brs_global function __Xml_iterator__(self:Dynamic):Dynamic {
	return untyped __brs__('__Xml_makeIterator__({0})', brs.Native.fieldGet(self, "children"));
}

@:keep @:brs_global function __Xml_elements__(self:Dynamic):Dynamic {
	var children:Dynamic = brs.Native.fieldGet(self, "children");
	var result:Dynamic = brs.Native.emptyArray();
	var cnt:Int = brs.Native.count(children);
	var i:Int = 0;
	while (i < cnt) {
		var child:Dynamic = brs.Native.arrayGet(children, i);
		var ct:Int = brs.Native.fieldGet(child, "nodeType");
		if (ct == 0) {
			brs.Native.push(result, child);
		}
		i = i + 1;
	}
	return untyped __brs__('__Xml_makeIterator__({0})', result);
}

@:keep @:brs_global function __Xml_elementsNamed__(self:Dynamic, name:String):Dynamic {
	var children:Dynamic = brs.Native.fieldGet(self, "children");
	var result:Dynamic = brs.Native.emptyArray();
	var cnt:Int = brs.Native.count(children);
	var i:Int = 0;
	while (i < cnt) {
		var child:Dynamic = brs.Native.arrayGet(children, i);
		var ct:Int = brs.Native.fieldGet(child, "nodeType");
		if (ct == 0) {
			var cn:String = brs.Native.fieldGet(child, "nodeName");
			var match:Bool = brs.Native.eq(cn, name);
			if (match == true) {
				brs.Native.push(result, child);
			}
		}
		i = i + 1;
	}
	return untyped __brs__('__Xml_makeIterator__({0})', result);
}

// --- First child / element ---

@:keep @:brs_global function __Xml_firstChild__(self:Dynamic):Dynamic {
	var children:Dynamic = brs.Native.fieldGet(self, "children");
	if (brs.Native.count(children) == 0)
		return null;
		// return untyped __brs__('invalid !18!');
	return brs.Native.arrayGet(children, 0);
}

@:keep @:brs_global function __Xml_firstElement__(self:Dynamic):Dynamic {
	var children:Dynamic = brs.Native.fieldGet(self, "children");
	var cnt:Int = brs.Native.count(children);
	var i:Int = 0;
	while (i < cnt) {
		var child:Dynamic = brs.Native.arrayGet(children, i);
		var ct:Int = brs.Native.fieldGet(child, "nodeType");
		if (ct == 0)
			return child;
		i = i + 1;
	}
	return null;
	// return untyped __brs__('invalid !19!');
}

// --- Tree manipulation ---

@:keep @:brs_global function __Xml_addChild__(self:Dynamic, x:Dynamic):Void {
	// Remove from old parent
	var oldParent:Dynamic = brs.Native.fieldGet(x, "parent");
	untyped __brs__('if {0} <> invalid then __Xml_removeChild__({0}, {1})', oldParent, x);
	// Add to new parent
	var children:Dynamic = brs.Native.fieldGet(self, "children");
	brs.Native.push(children, x);
	brs.Native.fieldSet(x, "parent", self);
	// return untyped __brs__(x);
	// return untyped __brs__('invalid !20!');
}

@:keep @:brs_global function __Xml_removeChild__(self:Dynamic, x:Dynamic):Dynamic {
	var children:Dynamic = brs.Native.fieldGet(self, "children");
	var cnt:Int = brs.Native.count(children);
	var xid:Int = brs.Native.fieldGet(x, "_id");
	var i:Int = 0;
	while (i < cnt) {
		var child:Dynamic = brs.Native.arrayGet(children, i);
		var cid:Int = brs.Native.fieldGet(child, "_id");
		if (cid == xid) {
			brs.Native.delete(children, i);
			brs.Native.fieldSet(x, "parent", untyped __brs__('invalid'));
			return untyped __brs__('true');
		}
		i = i + 1;
	}
	return untyped __brs__('false');
}

@:keep @:brs_global function __Xml_insertChild__(self:Dynamic, x:Dynamic, pos:Int):Void {
	// Remove from old parent
	var oldParent:Dynamic = brs.Native.fieldGet(x, "parent");
	untyped __brs__('if {0} <> invalid then __Xml_removeChild__({0}, {1})', oldParent, x);
	// Insert at position
	var children:Dynamic = brs.Native.fieldGet(self, "children");
	var cnt:Int = brs.Native.count(children);
	// Build new array with insertion using while loops (for..to fails with Object-typed pos)
	untyped __brs__('
		__p = 0 + {2}
		__nc = []
		__j = 0
		while __j < __p
			if __j < {0}.Count() then __nc.Push({0}[__j])
			__j = __j + 1
		end while
		__nc.Push({1})
		__j = __p
		while __j < {0}.Count()
			__nc.Push({0}[__j])
			__j = __j + 1
		end while
		while {0}.Count() > 0
			{0}.Pop()
		end while
		for each __item in __nc
			{0}.Push(__item)
		end for
	', children, x, pos);
	brs.Native.fieldSet(x, "parent", self);
	// return untyped __brs__('invalid !22!');
}

// --- XML entity escaping ---

@:keep @:brs_global function __Xml_escape__(s:String):String {
	var r:String = brs.Native.replace(s, "&", "&amp;");
	r = brs.Native.replace(r, "<", "&lt;");
	r = brs.Native.replace(r, ">", "&gt;");
	return r;
}

@:keep @:brs_global function __Xml_escapeAttr__(s:String):String {
	var r:String = untyped __brs__('__Xml_escape__({0})', s);
	var dq:String = brs.Native.chr(34);
	r = brs.Native.replace(r, dq, "&quot;");
	return r;
}

@:keep @:brs_global function __Xml_unescape__(s:String):String {
	var r:String = brs.Native.replace(s, "&lt;", "<");
	r = brs.Native.replace(r, "&gt;", ">");
	var dq:String = brs.Native.chr(34);
	r = brs.Native.replace(r, "&quot;", dq);
	var sq:String = brs.Native.chr(39);
	r = brs.Native.replace(r, "&apos;", sq);
	r = brs.Native.replace(r, "&amp;", "&");
	return r;
}

// --- toString ---

@:keep @:brs_global function __Xml_serializeAttrs__(self:Dynamic):String {
	final attrs:Dynamic = brs.Native.fieldGet(self, "attrs");
	final k:Dynamic = brs.Native.keys(attrs);
	final kc:Int = brs.Native.count(k);
	var s:String = "";
	var ki:Int = 0;
	while (ki < kc) {
		final an:String = brs.Native.arrayGet(k, ki);
		final av:String = brs.Native.fieldGet(attrs, an);
		s = s + " " + an + "=" + brs.Native.chr(34) + untyped __brs__('__Xml_escapeAttr__({0})', av) + brs.Native.chr(34);
		ki = ki + 1;
	}
	return s;
}

@:keep @:brs_global function __Xml_serializeChildren__(self:Dynamic):String {
	final children:Dynamic = brs.Native.fieldGet(self, "children");
	final cc:Int = brs.Native.count(children);
	var s:String = "";
	var i:Int = 0;
	while (i < cc) {
		s = s + untyped __brs__('__Xml_toString__({0})', brs.Native.arrayGet(children, i));
		i = i + 1;
	}
	return s;
}

@:keep @:brs_global function __Xml_toString__(self:Dynamic):String {
	final nt:Int = brs.Native.fieldGet(self, "nodeType");
	switch (nt) {
		case 0:
			final nm:String = brs.Native.fieldGet(self, "nodeName");
			final children:Dynamic = brs.Native.fieldGet(self, "children");
			var s:String = "<" + nm + untyped __brs__('__Xml_serializeAttrs__({0})', self);
			if (brs.Native.count(children) == 0)
				return s + "/>";
			return s + ">" + untyped __brs__('__Xml_serializeChildren__({0})', self) + "</" + nm + ">";
		case 1:
			return untyped __brs__('__Xml_escape__({0})', brs.Native.fieldGet(self, "nodeValue"));
		case 2:
			return "<![CDATA[" + brs.Native.fieldGet(self, "nodeValue") + "]]>";
		case 3:
			return "<!--" + brs.Native.fieldGet(self, "nodeValue") + "-->";
		case 4:
			return "<!" + brs.Native.fieldGet(self, "nodeValue") + ">";
		case 5:
			return "<?" + brs.Native.fieldGet(self, "nodeValue") + "?>";
		case 6:
			return untyped __brs__('__Xml_serializeChildren__({0})', self);
		default:
			return "";
	}
}

// --- XML Parser ---

@:keep @:brs_global function __Xml_parse__(str:String):Dynamic {
	untyped __brs__('__xdoc = __Xml_createDocument__()');
	final l:Int = brs.Native.len(str);
	untyped __brs__('__xps = {"s": {0}, "p": 0, "l": {1}}', str, l);
	untyped __brs__('__Xml_pKids__(__xps, __xdoc)');
	return untyped __brs__('__xdoc');
}

// --- Parser node helpers ---

@:keep @:brs_global function __Xml_pDelimited__(st:Dynamic, parent:Dynamic, startOffset:Int, endDelim:String, nodeType:Int):Void {
	final s:String = brs.Native.fieldGet(st, "s");
	final l:Int = brs.Native.toInt(brs.Native.fieldGet(st, "l"));
	final p:Int = brs.Native.toInt(brs.Native.fieldGet(st, "p"));
	final contentStart:Int = p + startOffset;
	final endLen:Int = brs.Native.len(endDelim);
	var endPos:Int = brs.Native.instrFrom(contentStart, s, endDelim);
	if (endPos == -1)
		endPos = l - endLen;
	final content:String = brs.Native.mid(s, contentStart, endPos - contentStart);
	brs.Native.fieldSet(st, "p", endPos + endLen);
	untyped __brs__('__Xml_addChild__({0}, __Xml_createNode__({1}, "", {2}))', parent, nodeType, content);
	// return untyped __brs__('invalid !23!');
}

@:keep @:brs_global function __Xml_pText__(st:Dynamic, parent:Dynamic):Void {
	final s:String = brs.Native.fieldGet(st, "s");
	final l:Int = brs.Native.toInt(brs.Native.fieldGet(st, "l"));
	final p:Int = brs.Native.toInt(brs.Native.fieldGet(st, "p"));
	var endPos:Int = brs.Native.instrFrom(p, s, "<");
	var content:String;
	if (endPos == -1) {
		content = brs.Native.midFrom(s, p);
		brs.Native.fieldSet(st, "p", l);
	} else {
		content = brs.Native.mid(s, p, endPos - p);
		brs.Native.fieldSet(st, "p", endPos);
	}
	if (brs.Native.len(content) > 0)
		untyped __brs__('__Xml_addChild__({0}, __Xml_createPCData__(__Xml_unescape__({1})))', parent, content);
	// return untyped __brs__('invalid !24!');
}

// --- Parser attribute & whitespace helpers ---

@:keep @:brs_global function __Xml_pSkipWs__(s:String, p:Int, l:Int):Int {
	while (p < l) {
		switch (brs.Native.charCodeAt(s, p)) {
			case 32: p = p + 1;
			case 9: p = p + 1;
			case 10: p = p + 1;
			case 13: p = p + 1;
			default: return p;
		}
	}
	return p;
}

@:keep @:brs_global function __Xml_pQuotedVal__(s:String, p:Int, l:Int, el:Dynamic, attrName:String):Int {
	final qt:String = brs.Native.mid(s, p, 1);
	p = p + 1;
	var ve:Int = brs.Native.instrFrom(p, s, qt);
	if (ve == -1)
		ve = l;
	final attrVal:String = brs.Native.mid(s, p, ve - p);
	untyped __brs__('__Xml_set__({0}, {1}, __Xml_unescape__({2}))', el, attrName, attrVal);
	return ve + 1;
}

@:keep @:brs_global function __Xml_pScanName__(s:String, p:Int, l:Int):Int {
	var scanning:Bool = true;
	while (scanning) {
		if (p >= l) {
			scanning = false;
		} else {
			switch (brs.Native.charCodeAt(s, p)) {
				case 61: scanning = false;
				case 32: scanning = false;
				case 62: scanning = false;
				case 47: scanning = false;
				case 9: scanning = false;
				case 10: scanning = false;
				case 13: scanning = false;
				default: p = p + 1;
			}
		}
	}
	return p;
}

@:keep @:brs_global function __Xml_pAttr__(s:String, p:Int, l:Int, el:Dynamic):Int {
	final nameStart:Int = p;
	p = brs.Native.toInt(untyped __brs__('__Xml_pScanName__({0}, {1}, {2})', s, p, l));
	final attrName:String = brs.Native.mid(s, nameStart, p - nameStart);
	if (p < l) {
		if (brs.Native.mid(s, p, 1) == "=") {
			p = p + 1;
			if (p < l) {
				switch (brs.Native.charCodeAt(s, p)) {
					case 34:
						p = brs.Native.toInt(untyped __brs__('__Xml_pQuotedVal__({0}, {1}, {2}, {3}, {4})', s, p, l, el, attrName));
					case 39:
						p = brs.Native.toInt(untyped __brs__('__Xml_pQuotedVal__({0}, {1}, {2}, {3}, {4})', s, p, l, el, attrName));
				}
			}
		}
	}
	return p;
}

// --- Parser orchestrators ---

@:keep @:brs_global function __Xml_pBang__(st:Dynamic, parent:Dynamic):Void {
	final s:String = brs.Native.fieldGet(st, "s");
	final p:Int = brs.Native.toInt(brs.Native.fieldGet(st, "p"));
	if (brs.Native.mid(s, p, 4) == "<!--")
		untyped __brs__('__Xml_pDelimited__({0}, {1}, 4, "-->", 3)', st, parent);
	else if (brs.Native.mid(s, p, 9) == "<![CDATA[")
		untyped __brs__('__Xml_pDelimited__({0}, {1}, 9, "]]>", 2)', st, parent);
	else
		untyped __brs__('__Xml_pDelimited__({0}, {1}, 2, ">", 4)', st, parent);
	// return untyped __brs__('invalid !25!');
}

@:keep @:brs_global function __Xml_pKids__(st:Dynamic, parent:Dynamic):Void {
	final s:String = brs.Native.fieldGet(st, "s");
	final l:Int = brs.Native.toInt(brs.Native.fieldGet(st, "l"));
	while (brs.Native.toInt(brs.Native.fieldGet(st, "p")) < l) {
		final p:Int = brs.Native.toInt(brs.Native.fieldGet(st, "p"));
		if (brs.Native.mid(s, p, 1) != "<") {
			untyped __brs__('__Xml_pText__({0}, {1})', st, parent);
		} else {
			switch (brs.Native.charCodeAt(s, p + 1)) {
				case 33:
					untyped __brs__('__Xml_pBang__({0}, {1})', st, parent);
				case 63:
					untyped __brs__('__Xml_pDelimited__({0}, {1}, 2, "?>", 5)', st, parent);
				case 47: // closing tag
					var endPos:Int = brs.Native.instrFrom(p, s, ">");
					if (endPos >= 0)
						brs.Native.fieldSet(st, "p", endPos + 1);
					// return untyped __brs__('invalid !26!');
					return;
				default:
					untyped __brs__('__Xml_pElem__({0}, {1})', st, parent);
			}
		}
	}
	// return untyped __brs__('invalid !27!');
}

@:keep @:brs_global function __Xml_pOpenTag__(st:Dynamic, el:Dynamic):Void {
	final s:String = brs.Native.fieldGet(st, "s");
	final l:Int = brs.Native.toInt(brs.Native.fieldGet(st, "l"));
	var p:Int = brs.Native.toInt(brs.Native.fieldGet(st, "p"));
	var done:Bool = false;
	while (!done) {
		p = brs.Native.toInt(untyped __brs__('__Xml_pSkipWs__({0}, {1}, {2})', s, p, l));
		if (p >= l) {
			done = true;
		} else {
			switch (brs.Native.charCodeAt(s, p)) {
				case 62: // '>' — children follow
					p = p + 1;
					brs.Native.fieldSet(st, "p", p);
					untyped __brs__('__Xml_pKids__({0}, {1})', st, el);
					p = brs.Native.toInt(brs.Native.fieldGet(st, "p"));
					done = true;
				case 47: // '/' — self-closing
					p = p + 2;
					done = true;
				default:
					p = brs.Native.toInt(untyped __brs__('__Xml_pAttr__({0}, {1}, {2}, {3})', s, p, l, el));
			}
		}
	}
	brs.Native.fieldSet(st, "p", p);
	// return untyped __brs__('invalid !28!');
}

@:keep @:brs_global function __Xml_pElem__(st:Dynamic, parent:Dynamic):Void {
	final s:String = brs.Native.fieldGet(st, "s");
	final l:Int = brs.Native.toInt(brs.Native.fieldGet(st, "l"));
	final p:Int = brs.Native.toInt(brs.Native.fieldGet(st, "p")) + 1; // skip '<'
	final nameEnd:Int = brs.Native.toInt(untyped __brs__('__Xml_pScanName__({0}, {1}, {2})', s, p, l));
	final tagName:String = brs.Native.mid(s, p, nameEnd - p);
	untyped __brs__('__xel = __Xml_createElement__({0})', tagName);
	brs.Native.fieldSet(st, "p", nameEnd);
	untyped __brs__('__Xml_pOpenTag__({0}, __xel)', st);
	untyped __brs__('__Xml_addChild__({0}, __xel)', parent);
	// return untyped __brs__('invalid !29!');
}
