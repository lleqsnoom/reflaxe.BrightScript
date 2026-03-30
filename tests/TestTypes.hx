package;

class MapKey {
	public var id:Int;

	public function new(val:Int) {
		this.id = val;
	}
}

enum Colors {
	Red;
	Green;
	Blue;
}

enum abstract ColorValues(Int) from Int to Int {
	final Red = 0xff0000;
	final Green = 0x00ff00;
	final Blue = 0x0000ff;
}
