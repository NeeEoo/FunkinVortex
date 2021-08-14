package;

import flixel.FlxSprite;

class BaseNote extends FlxSprite
{
	public var strumTime:Float = 0;
	public var section:Int = -1;
	public var noteData:Int = 0;
	public var isSustainNote:Bool = false;

	public function new(strumTime:Float, noteData:Int)
	{
		super();

		this.noteData = noteData % 8;
		this.strumTime = strumTime;
	}
}
