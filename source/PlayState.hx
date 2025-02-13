package;

import Song.SwagSong;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUIState;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.weapon.FlxBullet;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import haxe.Json;
import haxe.ui.Toolkit;
import haxe.ui.components.Button;
import haxe.ui.components.CheckBox;
import haxe.ui.components.NumberStepper;
import haxe.ui.components.Stepper;
import haxe.ui.components.TextField;
import haxe.ui.containers.TabView;
import haxe.ui.containers.VBox;
import haxe.ui.containers.menus.Menu;
import haxe.ui.containers.menus.MenuBar;
import haxe.ui.containers.menus.MenuItem;
import haxe.ui.containers.menus.MenuSeparator;
import haxe.ui.core.Component;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.focus.FocusManager;
import haxe.ui.macros.ComponentMacros;
import haxe.ui.styles.Style;
import openfl.media.Sound;

// import bulbytools.Assets;

enum abstract Snaps(Int) from Int to Int
{
	var Four;
	var Eight;
	var Twelve;
	var Sixteen;
	var Twenty;
	var TwentyFour;
	var ThirtyTwo;
	var FourtyEight;
	var SixtyFour;
	var NinetySix;
	var OneNineTwo;

	@:op(A == B) static function _(_, _):Bool;
}

// By default sections come in steps of 16.
// i should be using tab menu... oh well
// we don't have to worry about backspaces ^-^
class PlayState extends FlxUIState
{
	public static var instance:PlayState;
	static var _song:Song.SwagSong;

	var chart:FlxSpriteGroup;
	var staffLines:FlxSprite;
	var strumLine:FlxSpriteGroup;
	var curRenderedNotes:FlxTypedSpriteGroup<Note>;
	var curRenderedSus:FlxTypedSpriteGroup<HoldNote>;
	var snaptext:FlxText;
	var curSnap:Float = 0;
	// var ui_box:FlxUITabMenu;
	// var haxeUIOpen:Button;
	// var openButton:FlxButton;
	// var saveButton:FlxButton;
	// var exportButton:FlxButton;
	// var loadVocalsButton:FlxButton;
	// var loadInstButton:FlxButton;
	// var sectionTabBtn:FlxButton;
	// var noteTabBtn:FlxButton;
	var menuBar:MenuBar;
	var curSelectedNote:Array<Dynamic>;
	var curHoldSelect:Array<Dynamic>;
	var tabviewThingy:Component;
	var LINE_SPACING = 40;
	var camFollow:FlxObject;
	var lastLineY:Int = 0;
	var sectionMarkers:Array<Float> = [];
	//var songLengthInSteps:Int = 0;
	//var songSectionTimes:Array<Float> = [];
	//var noteControls:Array<Bool> = [false, false, false, false, false, false, false, false];
	//var noteRelease:Array<Bool> = [false, false, false, false, false, false, false, false];
	//var noteHold:Array<Bool> = [false, false, false, false, false, false, false, false];
	var curSectionTxt:FlxText;
	var curRenderedTxt:FlxText;
	var selectBox:FlxSprite;
	//var toolInfo:FlxText;
	var musicSound:Sound;
	var vocals:Sound;

	var enemyBG:FlxSprite;
	var bfBG:FlxSprite;

	static var vocalSound:FlxSound;

	var snapInfo:Snaps = Four;

	static var GRID_S = 40;

	public static var GRID_MH = GRID_S * 32;
	public static var GRID_H = GRID_MH * 3;
	public static var GRID_Y_OFF = GRID_MH;

	override public function create()
	{
		instance = this;
		super.create();
		strumLine = new FlxSpriteGroup(0, 0);
		curRenderedNotes = new FlxTypedSpriteGroup<Note>();
		curRenderedSus = new FlxTypedSpriteGroup<HoldNote>();

		enemyBG = FlxGridOverlay.create(GRID_S, GRID_S, GRID_S * 4, GRID_H);
		bfBG = FlxGridOverlay.create(GRID_S, GRID_S, GRID_S * 4, GRID_H);
		enemyBG.active = false;
		bfBG.active = false;

		if (_song == null)
			_song = {
				song: 'Test',
				notes: [],
				bpm: 150,
				needsVoices: true,
				player1: 'bf',
				player2: 'dad',
				stage: 'stage',
				gfVersion: 'gf',
				speed: 1,
				noteStyle: 'normal'
			};
		// make it ridulously big
		staffLines = new FlxSprite().makeGraphic(FlxG.width, FlxG.height * _song.notes.length, FlxColor.TRANSPARENT);
		staffLines.alpha = 0;
		generateStrumLine();
		strumLine.screenCenter(X);
		trace(strumLine);
		staffLines.screenCenter(X);
		chart = new FlxSpriteGroup();
		chart.add(staffLines);
		chart.add(enemyBG);
		chart.add(bfBG);
		chart.add(strumLine);
		updateGrid();
		chart.add(curRenderedSus);
		chart.add(curRenderedNotes);
		#if !electron
		FlxG.mouse.useSystemCursor = true;
		#end
		// i think UIs in code get out of hand fast and i know others prefer it so.. - creator of the ui thing
		menuBar = new MenuBar();
		menuBar.customStyle.width = FlxG.width;

		var editorName = new Menu();
		editorName.text = "Tandem";
		var creditsOf = new MenuItem();
		creditsOf.text = "Made by:";

		var ne_eoName = new MenuItem();
		ne_eoName.text = "Ne_Eo";
		var whatifyName = new MenuItem();
		whatifyName.text = "Whatify";

		editorName.addComponent(creditsOf);
		editorName.addComponent(new MenuSeparator());
		editorName.addComponent(ne_eoName);
		editorName.addComponent(whatifyName);
		menuBar.addComponent(editorName);

		var fileMenu = new Menu();
		fileMenu.text = "File";

		var saveChartMenu = new MenuItem();
		saveChartMenu.text = "Save Chart";
		// HEY UM SNIFF IS ACTUALLY LIKE A PROGRAM SILVAGUNNER USES SOOO
		saveChartMenu.onClick = function(e:MouseEvent)
		{
			updateTextParams();
			var json = {
				"song": _song,
				"generatedBy": "TandemEditor"
			};
			var data = Json.stringify(json);
			if ((data != null) && (data.length > 0))
				FNFAssets.askToSave("song", data);
		};
		var openChartMenu = new MenuItem();
		openChartMenu.text = "Open Chart";
		openChartMenu.onClick = function(e:MouseEvent)
		{
			var future = FNFAssets.askToBrowse("json");
			future.onComplete(function(s:String)
			{
				_song = Song.loadFromJson(s);
				FlxG.resetGame();
			});
		};
		var loadInstMenu = new MenuItem();
		loadInstMenu.text = "Load Instrument";
		loadInstMenu.onClick = function(e:MouseEvent)
		{
			var future = FNFAssets.askToBrowseForPath("ogg", "Select Instrument Track");
			future.onComplete(function(s:String)
			{
				musicSound = Sound.fromFile(s);
				FlxG.sound.playMusic(musicSound);
				FlxG.sound.music.pause();
			});
		};
		var loadVoiceMenu = new MenuItem();
		loadVoiceMenu.text = "Load Vocals";
		loadVoiceMenu.onClick = function(e:MouseEvent)
		{
			var future = FNFAssets.askToBrowseForPath("ogg", "Select Voice Track");
			future.onComplete(function(s:String)
			{
				vocals = Sound.fromFile(s);
				vocalSound = FlxG.sound.load(vocals);
			});
		};
		var exportMenu = new MenuItem();
		exportMenu.text = "Export to base game";
		exportMenu.onClick = function(e:MouseEvent)
		{
			updateTextParams();
			var cloneThingie = new Cloner();

			var sussySong:SwagSong = cloneThingie.clone(_song);
			// WE HAVE TO STRIP OUT ALL THE GOOD STUFF :grief:
			for (i in 0...sussySong.notes.length)
			{
				for (j in 0...sussySong.notes[i].sectionNotes.length)
				{
					var noteThingie = sussySong.notes[i].sectionNotes[j];
					if ((noteThingie[3] is Int))
					{
						if (noteThingie[3] > 0)
							noteThingie[3] = true;
						else
							noteThingie[3] = false;
					}
				}
				Reflect.deleteField(sussySong.notes[i], "altAnimNum");
			}
			var json = {
				"song": sussySong,
				"generatedBy": "TandemEditor"
			};
			var data = Json.stringify(json);
			if ((data != null) && (data.length > 0))
				FNFAssets.askToSave("song", data);
		};
		fileMenu.addComponent(saveChartMenu);
		fileMenu.addComponent(openChartMenu);
		fileMenu.addComponent(exportMenu);
		fileMenu.addComponent(loadInstMenu);
		fileMenu.addComponent(loadVoiceMenu);
		menuBar.addComponent(fileMenu);

		tabviewThingy = ComponentMacros.buildComponent('assets/data/tabmenu.xml');
		tabviewThingy.findComponent("bfText", TextField).text = _song.player1;
		tabviewThingy.findComponent("enemyText", TextField).text = _song.player2;
		tabviewThingy.findComponent("gfText", TextField).text = _song.gfVersion;
		tabviewThingy.findComponent("stageText", TextField).text = _song.stage;
		tabviewThingy.findComponent("noteStyleText", TextField).text = _song.noteStyle;
		tabviewThingy.findComponent("songTitle", TextField).text = _song.song;
		tabviewThingy.findComponent("needsVoices", CheckBox).onChange = function(e:UIEvent)
		{
			_song.needsVoices = tabviewThingy.findComponent("needsVoices", CheckBox).selected;
		};
		tabviewThingy.findComponent("needsVoices", CheckBox).selected = _song.needsVoices;
		tabviewThingy.findComponent("muteInst", CheckBox).onChange = function(_)
		{
			var vol:Float = 1;
			if (tabviewThingy.findComponent("muteInst", CheckBox).selected)
				vol = 0;
			if (FlxG.sound.music != null)
				FlxG.sound.music.volume = vol;
		};
		tabviewThingy.findComponent("swapsection", Button).onClick = function(_)
		{
			var curSection = getSussySectionFromY(strumLine.y);
			if (_song.notes[curSection] == null)
				return;
			for (i in 0..._song.notes[curSection].sectionNotes.length)
			{
				var note = _song.notes[curSection].sectionNotes[i];
				note[1] = (note[1] + 4) % 8;
				_song.notes[curSection].sectionNotes[i] = note;
			}
			updateNotes();
		};
		tabviewThingy.findComponent("copysection", Button).onClick = function(_)
		{
			copySection(Std.int(tabviewThingy.findComponent("copyid", NumberStepper).pos));
		};
		tabviewThingy.findComponent("addsection", Button).onClick = function(_)
		{
			addSection();
		};
		tabviewThingy.findComponent("clearsection", Button).onClick = function(_)
		{
			var curSection = getSussySectionFromY(strumLine.y);
			if (_song.notes[curSection] == null)
				return;
			_song.notes[curSection].sectionNotes = [];
			updateNotes();
		};
		tabviewThingy.findComponent("musthitsection", CheckBox).onChange = function(e:UIEvent)
		{
			var curSection = getSussySectionFromY(strumLine.y);
			if (_song.notes[curSection] != null)
				_song.notes[curSection].mustHitSection = tabviewThingy.findComponent("musthitsection", CheckBox).selected;
			updateNotes();
		};
		tabviewThingy.findComponent("musthitsection", CheckBox).selected = false;
		tabviewThingy.findComponent("changebpmsection", CheckBox).onChange = function(e:UIEvent)
		{
			var curSection = getSussySectionFromY(strumLine.y);
			if (_song.notes[curSection] != null)
				_song.notes[curSection].changeBPM = tabviewThingy.findComponent("changebpmsection", CheckBox).selected;
		};
		tabviewThingy.findComponent("changebpmsection", CheckBox).selected = false;
		tabviewThingy.findComponent("altnotecheck", CheckBox).onChange = function(e:UIEvent)
		{
			if (curSelectedNote != null)
			{
				curSelectedNote[3] = tabviewThingy.findComponent("altnotecheck", CheckBox).selected ? 1 : 0;
			}
			updateNoteUI();
		};
		tabviewThingy.findComponent("altnotecheck", CheckBox).selected = false;
		tabviewThingy.findComponent("sectionlength", NumberStepper).onChange = function(_)
		{
			var curSection = getSussySectionFromY(strumLine.y);
			if (_song.notes[curSection] != null)
				_song.notes[curSection].lengthInSteps = Std.int(tabviewThingy.findComponent("sectionlength", NumberStepper).pos);
			updateNotes();
		};
		tabviewThingy.findComponent("songspeed", NumberStepper).onChange = function(_)
		{
			_song.speed = tabviewThingy.findComponent("songspeed", NumberStepper).pos;
		};
		tabviewThingy.findComponent("songspeed", NumberStepper).pos = _song.speed;
		tabviewThingy.findComponent("songbpm", NumberStepper).onChange = function(_)
		{
			tempBpm = tabviewThingy.findComponent("songbpm", NumberStepper).pos;
			Conductor.mapBPMChanges(_song);
			Conductor.changeBPM(tempBpm);
		};
		tabviewThingy.findComponent("songbpm", NumberStepper).pos = _song.bpm;
		tabviewThingy.findComponent("sectionbpm", NumberStepper).onChange = function(_)
		{
			var curSection = getSussySectionFromY(strumLine.y);
			if (_song.notes[curSection] != null)
				_song.notes[curSection].bpm = tabviewThingy.findComponent("sectionbpm", NumberStepper).pos;
			updateNotes();
		};
		tabviewThingy.findComponent("altsection", NumberStepper).onChange = function(_)
		{
			var curSection = getSussySectionFromY(strumLine.y);
			if (_song.notes[curSection] != null)
				_song.notes[curSection].altAnimNum = Std.int(tabviewThingy.findComponent("altsection", NumberStepper).pos);

			updateNotes();
		};
		tabviewThingy.findComponent("altnotestep", NumberStepper).onChange = function(_)
		{
			if (curSelectedNote != null)
				curSelectedNote[3] = tabviewThingy.findComponent("altnotestep", NumberStepper).pos;
			updateNoteUI();
		};

		tabviewThingy.x = FlxG.width / 2 + 150;
		tabviewThingy.y = 100;
		LINE_SPACING = Std.int(strumLine.height);
		curSnap = LINE_SPACING * 4;
		updateNotes();
		camFollow = new FlxObject(strumLine.getGraphicMidpoint().x, strumLine.getGraphicMidpoint().y);
		FlxG.camera.follow(camFollow, LOCKON);
		staffLines.y += strumLine.height / 2;

		curSectionTxt = new FlxText(200, FlxG.height, 0, 'Section: 0', 16);
		curSectionTxt.y -= curSectionTxt.height;
		curSectionTxt.scrollFactor.set();

		curRenderedTxt = new FlxText(0, FlxG.height, 0, 'Visible Notes: 0', 16);
		curRenderedTxt.y -= curRenderedTxt.height;
		curRenderedTxt.scrollFactor.set();

		snaptext = new FlxText(0, FlxG.height, 0, '4ths', 24);
		snaptext.y -= snaptext.height;
		snaptext.y -= curRenderedTxt.height;
		snaptext.scrollFactor.set();

		//toolInfo = new FlxText(FlxG.width / 2, FlxG.height, 0, "a", 16);
		//// don't immediately set text to '' because height??
		//toolInfo.y -= toolInfo.height;
		//toolInfo.text = 'hover over things to see what they do';
		//// NOT PIXEL PERFECT
		//toolInfo.scrollFactor.set();

		tempBpm = _song.bpm;
		Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);
		selectBox = new FlxSprite().makeGraphic(1, 1, FlxColor.BLUE);
		selectBox.visible = false;
		selectBox.alpha = 0.7;
		selectBox.scrollFactor.set();
		// add(staffLines);
		add(strumLine);
		add(curRenderedNotes);
		add(curRenderedSus);
		add(chart);
		add(snaptext);
		add(curSectionTxt);
		add(curRenderedTxt);
		// add(openButton);

		add(menuBar);
		// add(saveButton);
		// add(loadVocalsButton);
		// add(loadInstButton);
		// add(toolInfo);
		// add(ui_box);
		add(tabviewThingy);
		// add(selectBox);
		// add(haxeUIOpen);

		FlxG.camera.follow(strumLine);
	}

	function updateGrid()
	{
		#if debug
		trace("updateGrid()");
		#end
		var gridFloor = (strumLine.y % GRID_MH) + GRID_Y_OFF;

		var yPos = strumLine.y - gridFloor;

		if(yPos < 0) yPos = 0;

		enemyBG.x = strumLine.x + 50 - GRID_S * 5;
		enemyBG.y = yPos;

		bfBG.x = strumLine.x + 50;
		bfBG.y = yPos;
	}

	function addSection(lengthInSteps:Int = 16)
	{
		var sec:SwagSection = {
			lengthInSteps: lengthInSteps,
			bpm: _song.bpm,
			changeBPM: false,
			mustHitSection: true,
			sectionNotes: [],
			typeOfSection: 0,
			altAnim: false,
			altAnimNum: 0
		};

		_song.notes.push(sec);
	}

	// can't think of a good name for this; all this do is just set all the songs params to things from the tabmenu
	function updateTextParams()
	{
		_song.player1 = tabviewThingy.findComponent("bfText", TextField).text;
		_song.player2 = tabviewThingy.findComponent("enemyText", TextField).text;
		_song.gfVersion = tabviewThingy.findComponent("gfText", TextField).text;
		_song.stage = tabviewThingy.findComponent("stageText", TextField).text;
		_song.noteStyle = tabviewThingy.findComponent("noteStyleText", TextField).text;
		_song.song = tabviewThingy.findComponent("songTitle", TextField).text;
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (strumLine == null)
			return;
		var curSection = getSussySectionFromY(strumLine.y);
		if (id == FlxUICheckBox.CLICK_EVENT)
		{
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch (label)
			{
				case 'Must hit section':
					_song.notes[curSection].mustHitSection = check.checked;
					updateNotes();

				case 'Change BPM':
					_song.notes[curSection].changeBPM = check.checked;
					FlxG.log.add('changed bpm shit');
				case "Alt Animation":
					// _song.notes[curSection].altAnim = check.checked;
				case 'Alt Anim Note':
					if (curSelectedNote != null)
					{
						curSelectedNote[3] = check.checked ? 1 : 0;
					}
					updateNoteUI();
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;

			//FlxG.log.add(wname);
			if (wname == 'section_length')
			{
				_song.notes[curSection].lengthInSteps = Std.int(nums.value);
				updateNotes();
			}
			else if (wname == 'song_speed')
			{
				_song.speed = nums.value;
			}
			else if (wname == 'song_bpm')
			{
				tempBpm = nums.value;
				Conductor.mapBPMChanges(_song);
				Conductor.changeBPM(nums.value);
			}
			else if (wname == 'note_susLength')
			{
				curSelectedNote[2] = nums.value;
				redrawNote(curSelectedNote);
			}
			else if (wname == 'section_bpm')
			{
				_song.notes[curSection].bpm = nums.value;
				updateNotes();
			}
			else if (wname == 'alt_anim_number')
			{
				_song.notes[curSection].altAnimNum = Std.int(nums.value);
			}
			else if (wname == 'alt_anim_note')
			{
				if (curSelectedNote != null)
					curSelectedNote[3] = nums.value;
				updateNoteUI();
			}
		}
	}

	var tempBpm:Float = 0;

	function updateNoteUI():Void
	{
		if (curSelectedNote != null)
		{
			// stepperSusLength.value = curSelectedNote[2];
			// null is falsy
			tabviewThingy.findComponent("altnotecheck", CheckBox).selected = cast curSelectedNote[3];
			tabviewThingy.findComponent("altnotestep", NumberStepper).pos = curSelectedNote[3] != null ? curSelectedNote[3] : 0;
		}
	}

	private function loadFromFile():Void
	{
		var future = FNFAssets.askToBrowse("json");
		future.onComplete(function(s:String)
		{
			_song = Song.loadFromJson(s);
			FlxG.resetGame();
		});
	}

	function copySection(?sectionNum:Int = 1)
	{
		var curSection = getSussySectionFromY(strumLine.y);
		var daSec = FlxMath.maxInt(curSection, sectionNum);
		for (note in _song.notes[daSec - sectionNum].sectionNotes)
		{
			var strum = note[0] + Conductor.stepCrochet * (_song.notes[daSec].lengthInSteps * sectionNum);

			var copiedNote:Array<Dynamic> = [strum, note[1], note[2]];
			if(note.length > 3) {
				copiedNote.push(note[3]);
			}
			_song.notes[daSec].sectionNotes.push(copiedNote);
		}

		updateNotes();
	}

	var selecting:Bool = false;
	var oldSection:Int = 0;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		var justPressed = FlxG.keys.justPressed;
		var justReleased = FlxG.keys.justReleased;
		var noteControls = [
			justPressed.ONE,
			justPressed.TWO,
			justPressed.THREE,
			justPressed.FOUR,
			justPressed.FIVE,
			justPressed.SIX,
			justPressed.SEVEN,
			justPressed.EIGHT
		];
		var noteRelease = [
			justReleased.ONE,
			justReleased.TWO,
			justReleased.THREE,
			justReleased.FOUR,
			justReleased.FIVE,
			justReleased.SIX,
			justReleased.SEVEN,
			justReleased.EIGHT
		];
		/*noteHold = [
			FlxG.keys.pressed.ONE,
			FlxG.keys.pressed.TWO,
			FlxG.keys.pressed.THREE,
			FlxG.keys.pressed.FOUR,
			FlxG.keys.pressed.FIVE,
			FlxG.keys.pressed.SIX,
			FlxG.keys.pressed.SEVEN,
			FlxG.keys.pressed.EIGHT
		];*/
		if (FocusManager.instance.focus == null)
		{
			if (FlxG.keys.justPressed.UP || FlxG.mouse.wheel > 0)
			{
				moveStrumLine(-1);
			}
			else if (FlxG.keys.justPressed.DOWN || FlxG.mouse.wheel < 0)
			{
				moveStrumLine(1);
			}

			if (FlxG.keys.justPressed.S)
			{
				var sectionNum = getSussySectionFromY(strumLine.y);
				_song.notes[sectionNum].mustHitSection = !_song.notes[sectionNum].mustHitSection;
				updateNotes();
			}

			if (FlxG.keys.justPressed.RIGHT)
			{
				changeSnap(true);
			}
			else if (FlxG.keys.justPressed.LEFT)
			{
				changeSnap(false);
			}

			if (FlxG.keys.justPressed.ESCAPE && curSelectedNote != null)
			{
				deselectNote();
			}
			if (FlxG.keys.justPressed.HOME)
			{
				strumLine.y = 0;
				moveStrumLine(0);
			}
			/*
				if (FlxG.keys.pressed.SHIFT && FlxG.mouse.justPressed)
				{
					selecting = true;
					selectBox.x = FlxG.mouse.screenX;
					selectBox.y = FlxG.mouse.screenY;
					selectBox.scale.x = 1;
					selectBox.scale.y = 1;
					selectBox.visible = true;
				}
				if (FlxG.mouse.justReleased && selecting)
				{
					selecting = false;
					selectBox.visible = false;
				}

				if (selecting)
				{
					selectBox.scale.x = selectBox.x - FlxG.mouse.screenX;
					selectBox.scale.y = selectBox.y - FlxG.mouse.screenY;
					selectBox.offset.x = (selectBox.x - FlxG.mouse.screenX) / 2;
					selectBox.offset.y = (selectBox.y - FlxG.mouse.screenY) / 2;
				}
			 */

			if (FlxG.keys.pressed.SHIFT && FlxG.mouse.justPressed)
			{
				if (FlxG.mouse.overlaps(curRenderedNotes))
				{
					for (note in curRenderedNotes.members)
					{
						if (note.visible && FlxG.mouse.overlaps(note))
						{
							strumLine.y = note.y;
							var noteData = note.noteData;
							if (_song.notes[note.section].mustHitSection)
							{
								noteData = (noteData + 4) % 8;
							}
							selectNote(noteData);
							break;
						}
					}
				}
			}
			if (FlxG.keys.pressed.CONTROL && FlxG.mouse.justPressed)
			{
				if (FlxG.mouse.overlaps(curRenderedNotes))
				{
					for (note in curRenderedNotes.members)
					{
						if (FlxG.mouse.overlaps(note))
						{
							strumLine.y = note.y;
							var noteData = note.noteData;
							if (_song.notes[note.section].mustHitSection)
							{
								noteData = (noteData + 4) % 8;
							}
							addNote(noteData);
							break;
						}
					}
				}
			}

			if (FlxG.keys.justPressed.SPACE && FlxG.sound.music != null)
			{
				if (FlxG.sound.music.playing)
				{
					FlxG.sound.music.pause();
					if (_song.needsVoices && vocalSound != null)
					{
						vocalSound.pause();
					}
				}
				else
				{
					FlxG.sound.music.time = getSussyStrumTime(strumLine.y);
					FlxG.sound.music.play();
					if (_song.needsVoices && vocalSound != null)
					{
						vocalSound.play();
					}
				}
			}
			if (FlxG.sound.music != null && FlxG.sound.music.playing)
			{
				strumLine.y = getSussyYPos(FlxG.sound.music.time);
				var section = getSussySectionFromY(strumLine.y);
				curSectionTxt.text = 'Section: ' + section;
				if (_song.needsVoices && vocalSound != null && !CoolUtil.nearlyEquals(vocalSound.time, FlxG.sound.music.time, 2))
				{
					vocalSound.time = FlxG.sound.music.time;
				}

				curRenderedNotes.forEach(lightStrum);
				curRenderedSus.forEach(lightStrum);

				if(section != oldSection) {
					updateGrid();
					oldSection = section;
				}
			}
		}
		else
		{
			trace(FocusManager.instance.focus);
		}

		strumLine.forEach(function(spr:FlxSprite)
		{
			if (spr.animation.finished)
			{
				spr.animation.play('static');
				spr.centerOffsets();
			}
		});

		optimizeNotes();

		for (i in 0...noteControls.length)
		{
			if (!noteControls[i] || FocusManager.instance.focus != null)
				continue;
			if (FlxG.keys.pressed.CONTROL)
			{
				selectNote(i);
			}
			else
			{
				addNote(i);
			}
		}
		if(curHoldSelect != null) {
			for (i in 0...noteRelease.length)
			{
				if (!noteRelease[i])
					continue;
				if (curHoldSelect[1] == getGoodInfo(i))
				{
					curHoldSelect = null;
					break;
				}
			}
		}
	}

	function lightStrum(note:BaseNote) {
		if(!note.visible) return;

		var noteData = note.noteData;
		if (_song.notes[note.section].mustHitSection)
		{
			noteData = (noteData + 4) % 8;
		}

		var strum = strumLine.members[noteData];

		var shouldLight = if(note.isSustainNote) {
			strum.overlaps(note);
		} else {
			CoolUtil.nearlyEquals(strum.y, note.y, 10);
		}

		if (shouldLight)
		{
			var wasNotConfirm = strum.animation.curAnim.name != "confirm";
			if(wasNotConfirm) {
				strum.centerOffsets();
			}
			strum.animation.play("confirm", true);

			if(wasNotConfirm) {
				strum.offset.add(10, 10);
			}
		}
	}

	function optimizeNotes() {
		var cameraYScroll = FlxG.camera.scroll.y;

		for(note in curRenderedNotes)
		{
			var minY:Float = note.y - note.offset.y - cameraYScroll; //; * note.scrollFactor.y;
			var isOnCamera = minY <= 720 && minY >= -note.height - 200;

			if (isOnCamera)
			{
				note.active = true;
				note.visible = true;
			}
			else
			{
				note.active = false;
				note.visible = false;
			}

			if(note.y < strumLine.y) {
				note.alpha = 0.5;
				note.antialiasing = false;
			} else {
				note.alpha = 1;
				note.antialiasing = true;
			}
		}

		for(sus in curRenderedSus)
		{
			if(sus.y + sus.height < strumLine.y) {
				sus.alpha = 0.5;
			} else {
				sus.alpha = 1;
			}
		}

		if(curRenderedTxt != null) {
			var count = 0;
			for(note in curRenderedNotes) {
				if(note.visible) count++;
			}
			curRenderedTxt.text = "Visible Notes: " + count;
		}
	}

	private function moveStrumLine(change:Int = 0)
	{
		strumLine.y += change * curSnap;
		if (change != 0)
			strumLine.y = Math.round(strumLine.y / curSnap) * curSnap;

		if(strumLine.y < 0)
			strumLine.y = 0;

		var section = getSussySectionFromY(strumLine.y);
		curSectionTxt.text = 'Section: ' + section;
		updateUI();
		if (curSelectedNote != null)
		{
			curSelectedNote[2] = getSussyStrumTime(strumLine.y) - curSelectedNote[0];
			curSelectedNote[2] = FlxMath.bound(curSelectedNote[2], 0);
			redrawNote(curSelectedNote);
		}
		if (curHoldSelect != null)
		{
			curHoldSelect[2] = getSussyStrumTime(strumLine.y) - curHoldSelect[0];
			curHoldSelect[2] = FlxMath.bound(curHoldSelect[2], 0);
			redrawNote(curHoldSelect);
		}

		if(section != oldSection) {
			updateGrid();
			oldSection = section;
		}
	}

	private function generateStrumLine()
	{
		for (i in -4...4)
		{
			var offset = 0;
			if (i < 0)
			{
				offset = 1;
			}
			var babyArrow = new FlxSprite(strumLine.x, strumLine.y);
			babyArrow.frames = FlxAtlasFrames.fromSparrow('assets/images/NOTE_assets.png', 'assets/images/NOTE_assets.xml');
			switch (i)
			{
				case 0 | -4:
					babyArrow.animation.addByPrefix('static', 'arrowLEFT');
					babyArrow.animation.addByPrefix('confirm', 'purple confirm', 24, false);
				case 1 | -3:
					babyArrow.animation.addByPrefix('static', 'arrowDOWN');
					babyArrow.animation.addByPrefix('confirm', 'blue confirm', 24, false);
				case 2 | -2:
					babyArrow.animation.addByPrefix('static', 'arrowUP');
					babyArrow.animation.addByPrefix('confirm', 'green confirm', 24, false);
				case 3 | -1:
					babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
					babyArrow.animation.addByPrefix('confirm', 'red confirm', 24, false);
			}
			babyArrow.animation.play("static");
			babyArrow.antialiasing = true;
			babyArrow.setGraphicSize(GRID_S);
			babyArrow.x += GRID_S * (i - offset) + 50;
			babyArrow.updateHitbox();
			babyArrow.centerOffsets();
			babyArrow.scrollFactor.set();
			//babyArrow.ID = i;
			strumLine.add(babyArrow);
		}
	}

	private function updateUI()
	{
		updateNoteUI();
		var curSection = getSussySectionFromY(strumLine.y);
		var section = _song.notes[curSection];
		if (section != null)
		{
			tabviewThingy.findComponent("sectionbpm", NumberStepper).pos = section.bpm;
			tabviewThingy.findComponent("altsection", NumberStepper).pos = section.altAnimNum;
			tabviewThingy.findComponent("musthitsection", CheckBox).selected = section.mustHitSection;
			tabviewThingy.findComponent("changebpmsection", CheckBox).selected = section.changeBPM;
			tabviewThingy.findComponent("sectionlength", NumberStepper).pos = section.lengthInSteps;
		}
	}

	private function drawChartLines()
	{
		sectionMarkers = []; // Reset markers
		// staffLines.makeGraphic(FlxG.width, FlxG.height * _song.notes.length, FlxColor.TRANSPARENT);
		for (i in 0..._song.notes.length)
		{
			for (o in 0..._song.notes[i].lengthInSteps)
			{
				/*
					var lineColor:FlxColor = FlxColor.GRAY;
					if (o == 0)
					{
						lineColor = FlxColor.WHITE;
						sectionMarkers.push(LINE_SPACING * ((i * 16) + o));
					}
					FlxSpriteUtil.drawLine(staffLines, FlxG.width * -0.5, LINE_SPACING * ((i * 16) + o), FlxG.width * 1.5, LINE_SPACING * ((i * 16) + o),
						{color: lineColor, thickness: 5});
				 */
				if (o == 0)
				{
					sectionMarkers.push(LINE_SPACING * ((i * 16) + o));
				}
				lastLineY = LINE_SPACING * ((i * 16) + o);
			}
		}
	}

	private function addNote(id:Int):Void
	{
		var susInfo = getSussyInfo(strumLine.members[id].y);

		var noteStrum = susInfo.strumTime;
		var curSection = susInfo.section;
		var noteData = id;
		var noteSus = 0;
		if (_song.notes[curSection].mustHitSection)
		{
			noteData = (noteData + 4) % 8;
		}
		// prefer overloading : )
		var goodArray:Array<Dynamic> = [noteStrum, noteData, noteSus, false];
		var compareStrum = CoolUtil.truncateFloat(noteStrum, 1);
		for (note in _song.notes[curSection].sectionNotes)
		{
			if (note[1] % 8 == noteData % 8 && CoolUtil.truncateFloat(note[0], 1) == compareStrum)
			{
				deleteNote(note, curSection);
				// if it was not the same type
				// we replace it instead of outright deleting it
				if (note[1] != noteData)
				{
					break;
				}
				return;
			}
		}
		_song.notes[curSection].sectionNotes.push(goodArray);
		curHoldSelect = goodArray;
		drawNote(goodArray, curSection);
	}

	private function changeSnap(increase:Bool)
	{
		// i have no idea why it isn't throwing a hissy fit. Let's keep it that way.
		if (increase)
		{
			snapInfo += 1;
		}
		else
		{
			snapInfo -= 1;
		}
		snapInfo = cast FlxMath.wrap(cast snapInfo, 0, cast(OneNineTwo));
		switch (snapInfo)
		{
			case Four:
				snaptext.text = '4ths';
				curSnap = (LINE_SPACING * 16) / 4;
			case Eight:
				snaptext.text = '8ths';
				curSnap = (LINE_SPACING * 16) / 8;
			case Twelve:
				snaptext.text = '12ths';
				curSnap = (LINE_SPACING * 16) / 12;
			case Sixteen:
				snaptext.text = '16ths';
				curSnap = (LINE_SPACING * 16) / 16;
			case Twenty:
				snaptext.text = '20ths';
				curSnap = (LINE_SPACING * 16) / 20;
			case TwentyFour:
				snaptext.text = '24ths';
				curSnap = (LINE_SPACING * 16) / 24;
			case ThirtyTwo:
				snaptext.text = '32nds';
				curSnap = (LINE_SPACING * 16) / 32;
			case FourtyEight:
				snaptext.text = '48ths';
				curSnap = (LINE_SPACING * 16) / 48;
			case SixtyFour:
				snaptext.text = '64ths';
				curSnap = (LINE_SPACING * 16) / 64;
			case NinetySix:
				snaptext.text = '96ths';
				curSnap = (LINE_SPACING * 16) / 96;
			case OneNineTwo:
				snaptext.text = '192nds';
				curSnap = (LINE_SPACING * 16) / 192;
		}
	}

	private function deselectNote():Void
	{
		updateTextParams();
		curSelectedNote = null;
	}

	private function selectNote(id:Int):Void
	{
		var susInfo = getSussyInfo(strumLine.members[id].y);

		var noteStrum = susInfo.strumTime;
		var curSection = susInfo.section;

		var noteData = id;
		if (_song.notes[curSection].mustHitSection)
		{
			noteData = (noteData + 4) % 8;
		}
		var compareStrum = CoolUtil.truncateFloat(noteStrum, 1);
		for (note in _song.notes[curSection].sectionNotes)
		{
			if (note[1] == noteData && CoolUtil.truncateFloat(note[0], 1) == compareStrum)
			{
				curSelectedNote = note;
				updateNoteUI();
				return;
			}
		}
	}

	function deleteNote(noteInfo:Array<Dynamic>, section:Int) {
		var curNote:Note = null;

		for(note in curRenderedNotes) {
			if(note.noteInfo == noteInfo) {
				curNote = note;
				break;
			}
		}

		if(curNote == null) {
			return;
		}

		if(curNote.susVis != null) {
			var sustainVis = curNote.susVis;
			curRenderedSus.remove(sustainVis, true);
		}

		curRenderedNotes.remove(curNote, true);
		_song.notes[section].sectionNotes.remove(noteInfo);
	}

	function redrawNote(noteInfo:Array<Dynamic>) {
		var curNote:Note = null;

		for(note in curRenderedNotes) {
			if(note.noteInfo == noteInfo) {
				curNote = note;
				break;
			}
		}

		if(curNote == null) {
			return;
		}

		if(curNote.susVis != null) {
			var sustainVis = curNote.susVis;
			curRenderedSus.remove(sustainVis, true);
		}

		curRenderedNotes.remove(curNote, true);

		drawNote(noteInfo, curNote.section);
	}

	private function getGoodInfo(noteData:Int)
	{
		var curSection = getSussySectionFromY(strumLine.y);
		if (_song.notes[curSection].mustHitSection)
		{
			noteData = (noteData + 4) % 8;
		}
		return noteData;
	}

	private function updateNotes()
	{
		#if debug
		trace("updateNotes()");
		#end
		drawChartLines();
		while (curRenderedNotes.members.length > 0)
		{
			curRenderedNotes.remove(curRenderedNotes.members[0], true);
		}
		while (curRenderedSus.members.length > 0)
		{
			curRenderedSus.remove(curRenderedSus.members[0], true);
		}
		for (j in 0..._song.notes.length)
		{
			var sectionInfo = _song.notes[j].sectionNotes;
			// todo, bpm support
			/*
				if (_song.notes[i].changeBPM && _song.notes[i].bpm > 0)
				{
					Conductor.changeBPM(_song.notes[i].bpm);
			}*/
			Conductor.changeBPM(_song.bpm);
			var susMul:Float = GRID_S / Conductor.stepCrochet; // FlxMath.remapToRange(1, 0, Conductor.stepCrochet * 16, 0, GRID_S * 16))
			//songSectionTimes.push(songLengthInSteps);
			//songLengthInSteps += _song.notes[j].lengthInSteps;

			for (i in sectionInfo)
			{
				drawNote(i, j, susMul);
			}
		}

		optimizeNotes();
	}

	function drawNote(noteInfo:Array<Dynamic>, section:Int, ?susMul:Float) {
		if(susMul == null) {
			susMul = GRID_S / Conductor.stepCrochet;
		}

		var daStrumTime:Float = noteInfo[0];
		var daNoteData:Int = noteInfo[1];
		var daSus:Float = noteInfo[2];

		var note = new Note(daStrumTime, daNoteData);
		note.noteInfo = noteInfo;
		//note.sustainLength = daSus;
		note.setGraphicSize(Std.int(strumLine.members[0].width));
		note.updateHitbox();
		note.section = section;
		var cNoteData = daNoteData % 8;
		if (_song.notes[section].mustHitSection) // Invert placement
		{
			cNoteData = (cNoteData + 4) % 8;
		}
		note.x = strumLine.members[cNoteData % 8].x;
		note.y = Math.floor(getYfromStrum(daStrumTime, section));

		curRenderedNotes.add(note);
		if (daSus > 0)
		{
			var susHeight = Std.int(daSus * susMul);
			var susX = note.x + note.width / 2 - HoldNote.SUS_WIDTH / 2;

			var sustainVis = new HoldNote(daStrumTime, daNoteData, susHeight);
			sustainVis.x = susX;
			sustainVis.y = note.y + GRID_S;
			sustainVis.section = section;

			note.susVis = sustainVis;
			curRenderedSus.add(sustainVis);
		}
	}

	private function getYfromStrum(strumTime:Float, section:Int):Float
	{
		var times = getSectionTimes(section);
		var prevPos = times[0];
		var daPos = times[1];
		return FlxMath.remapToRange(strumTime, prevPos, daPos, sectionMarkers[section], sectionMarkers[section + 1]);
	}

	private function getStrumTime(yPos:Float, section:Int):Float
	{
		var times = getSectionTimes(section);
		var prevPos = times[0];
		var daPos = times[1];
		return FlxMath.remapToRange(yPos, sectionMarkers[section], sectionMarkers[section + 1], prevPos, daPos);
	}

	// Should be called "getAmbiguousStrumTime", too lazy to name it that
	private function getSussyStrumTime(yPos:Float):Float
	{
		for (i in 0..._song.notes.length)
		{
			if (yPos >= sectionMarkers[i] && yPos < sectionMarkers[i + 1])
			{
				return getStrumTime(yPos, i);
			}
		}
		return 0;
	}

	private function getSussyYPos(strumTime:Float):Float
	{
		for (i in 0..._song.notes.length)
		{
			var times = getSectionTimes(i);
			var prevPos = times[0];
			var daPos = times[1];
			if (strumTime >= prevPos && strumTime < daPos)
			{
				//return getYfromStrum(strumTime, i);
				return FlxMath.remapToRange(strumTime, prevPos, daPos, sectionMarkers[i], sectionMarkers[i + 1]);
			}
		}
		return 0;
	}

	function getSussySectionFromY(yPos:Float):Int
	{
		for (i in 0..._song.notes.length)
		{
			if (yPos >= sectionMarkers[i] && yPos < sectionMarkers[i + 1])
			{
				return i;
			}
		}
		return 0;
	}

	private function getSussyInfo(yPos:Float):SussyInfo
	{
		for (i in 0..._song.notes.length)
		{
			if (yPos >= sectionMarkers[i] && yPos < sectionMarkers[i + 1])
			{
				return { strumTime: getStrumTime(yPos, i), section: i };
			}
		}
		return { strumTime: 0, section: 0 };
	}

	inline function sectionStartTime(section:Int):Float
	{
		var daBPM:Float = _song.bpm;
		var daPos:Float = 0;
		for (i in 0...section)
		{
			if (_song.notes[i].changeBPM)
			{
				daBPM = _song.notes[i].bpm;
			}
			daPos += 4 * (1000 * 60 / daBPM);
		}
		return daPos;
	}

	private function getSectionTimes(section:Int):Array<Float> {
		var daBPM:Float = _song.bpm;
		var daPos:Float = 0;
		var prevPos:Float = 0;
		for (i in 0...section+1)
		{
			if (_song.notes[i].changeBPM)
				daBPM = _song.notes[i].bpm;

			prevPos = daPos;
			daPos += 4 * (1000 * 60 / daBPM);
		}

		return [prevPos, daPos];
	}
}

typedef SussyInfo = {
	var strumTime:Float;
	var section:Int;
}