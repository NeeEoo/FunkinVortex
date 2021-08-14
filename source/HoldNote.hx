package;

class HoldNote extends BaseNote
{
	public inline static var SUS_WIDTH:Int = 8;

	static var susColor:Array<Int> = [
		0xFFC24B99,
		0xFF00FFFF,
		0xFF12FA05,
		0xFFF9393F
	];

	public function new(strumTime:Float, noteData:Int, susHeight:Int)
	{
		super(strumTime, noteData);

		isSustainNote = true;

		var color = susColor[noteData % 4];

		makeGraphic(SUS_WIDTH, susHeight, color);
		active = false;
	}
}
