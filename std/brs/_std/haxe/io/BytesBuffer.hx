package haxe.io;

class BytesBuffer {
	var b:Array<Int>;

	public var length(get, never):Int;

	public function new() {
		b = new Array();
	}

	inline function get_length():Int {
		return b.length;
	}

	public inline function addByte(byte:Int) {
		b.push(byte);
	}

	public inline function add(src:Bytes) {
		var b2 = src.getData();
		for (i in 0...src.length)
			b.push(b2[i]);
	}

	public inline function addString(v:String, ?encoding:Encoding) {
		add(Bytes.ofString(v, encoding));
	}

	public function addInt32(v:Int) {
		addByte(v & 0xFF);
		addByte((v >> 8) & 0xFF);
		addByte((v >> 16) & 0xFF);
		addByte((v >> 24) & 0xFF);
	}

	public function addInt64(v:haxe.Int64) {
		addInt32(v.low);
		addInt32(v.high);
	}

	public inline function addFloat(v:Float) {
		addInt32(FPHelper.floatToI32(v));
	}

	public inline function addDouble(v:Float) {
		addInt64(FPHelper.doubleToI64(v));
	}

	public inline function addBytes(src:Bytes, pos:Int, len:Int) {
		if (pos < 0 || len < 0 || pos + len > src.length)
			throw Error.OutsideBounds;
		var b2 = src.getData();
		for (i in pos...pos + len)
			b.push(b2[i]);
	}

	public function getBytes():Bytes {
		var bytes = Bytes.alloc(b.length);
		for (i in 0...b.length)
			bytes.set(i, b[i]);
		b = null;
		return bytes;
	}
}
