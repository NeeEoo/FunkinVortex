package;

import flixel.graphics.frames.FlxAtlasFrames;

class Note extends BaseNote
{
	public var sustainLength:Float = 0;
	public var noteInfo:Array<Dynamic>;
	public var susVis:HoldNote;

	public function new(strumTime:Float, noteData:Int)
	{
		super(strumTime, noteData);

		isSustainNote = false;

		frames = FlxAtlasFrames.fromSparrow('assets/images/NOTE_assets.png', 'assets/images/NOTE_assets.xml');
		animation.addByPrefix('greenScroll', 'green0');
		animation.addByPrefix('redScroll', 'red0');
		animation.addByPrefix('blueScroll', 'blue0');
		animation.addByPrefix('purpleScroll', 'purple0');

		animation.addByPrefix('purpleholdend', 'pruple end hold');
		animation.addByPrefix('greenholdend', 'green hold end');
		animation.addByPrefix('redholdend', 'red hold end');
		animation.addByPrefix('blueholdend', 'blue hold end');

		animation.addByPrefix('purplehold', 'purple hold piece');
		animation.addByPrefix('greenhold', 'green hold piece');
		animation.addByPrefix('redhold', 'red hold piece');
		animation.addByPrefix('bluehold', 'blue hold piece');

		antialiasing = true;

		switch (noteData % 4)
		{
			case 0: animation.play('purpleScroll');
			case 1: animation.play('blueScroll');
			case 2: animation.play('greenScroll');
			case 3: animation.play('redScroll');
		}
	}
}
