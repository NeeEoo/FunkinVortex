package;

import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;
import tjson.TJSON;

using StringTools;

#if sys
import haxe.io.Path;
import lime.system.System;
import sys.io.File;
#end

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var stage:String;
	var gf:String;
	var isMoody:Null<Bool>;
	var cutsceneType:String;
	var uiType:String;
	var isSpooky:Null<Bool>;
	var isHey:Null<Bool>;
	var isCheer:Null<Bool>;
	var preferredNoteAmount:Null<Int>;
	var forceJudgements:Null<Bool>;
	var convertMineToNuke:Null<Bool>;
	var mania:Null<Int>;
}

class Song
{
	public static function loadFromJson(file:String):SwagSong
	{
		var rawJson:String = "";
		rawJson = file;

		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
			// LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
		}
		var parsedJson = parseJSONshit(rawJson);
		var songName = parsedJson.song.toLowerCase();
		if (parsedJson.stage == null)
		{
			if (songName == 'spookeez' || songName == 'monster' || songName == 'south')
			{
				parsedJson.stage = 'spooky';
			}
			else if (songName == 'pico' || songName == 'philly' || songName == 'blammed')
			{
				parsedJson.stage = 'philly';
			}
			else if (songName == 'milf' || songName == 'high' || songName == 'satin-panties')
			{
				parsedJson.stage = 'limo';
			}
			else if (songName == 'cocoa' || songName == 'eggnog')
			{
				parsedJson.stage = 'mall';
			}
			else if (songName == 'winter-horrorland')
			{
				parsedJson.stage = 'mallEvil';
			}
			else if (songName == 'senpai' || songName == 'roses')
			{
				parsedJson.stage = 'school';
			}
			else if (songName == 'thorns')
			{
				parsedJson.stage = 'schoolEvil';
			}
			else if (songName == "ugh" || songName == "stress" || songName == "guns")
			{
				parsedJson.stage = 'tank';
			}
			else
			{
				parsedJson.stage = 'stage';
			}
		}
		if (parsedJson.forceJudgements == null)
			parsedJson.forceJudgements = false;
		if (parsedJson.preferredNoteAmount == null)
		{
			switch (parsedJson.mania)
			{
				case 1:
					parsedJson.preferredNoteAmount = 6;
				case 2:
					parsedJson.preferredNoteAmount = 9;
				default:
					parsedJson.preferredNoteAmount = 4;
			}
		}
		if (parsedJson.mania == null)
		{
			switch (parsedJson.preferredNoteAmount)
			{
				case 4:
					parsedJson.mania = 0;
				case 6:
					parsedJson.mania = 1;
				case 9:
					parsedJson.mania = 2;
				default:
					parsedJson.mania = 0;
			}
		}
		if (parsedJson.isHey == null)
		{
			parsedJson.isHey = false;
			if (songName == 'bopeebo')
				parsedJson.isHey = true;
		}
		if (parsedJson.isCheer = null)
		{
			parsedJson.isCheer = false;
			if (songName == "tutorial")
			{
				parsedJson.isCheer = true;
			}
		}
		trace(parsedJson.stage);
		if (parsedJson.gf == null)
		{
			// are you kidding me did i really do song to lowercase
			switch (parsedJson.stage)
			{
				case 'limo':
					parsedJson.gf = 'gf-car';
				case 'mall':
					parsedJson.gf = 'gf-christmas';
				case 'mallEvil':
					parsedJson.gf = 'gf-christmas';
				case 'school' | 'schoolEvil':
					parsedJson.gf = 'gf-pixel';
				case 'tank':
					parsedJson.gf = 'gf-tankmen';
					if (songName == "stress")
					{
						parsedJson.gf = "pico-speaker";
					}
				default:
					parsedJson.gf = 'gf';
			}
		}
		if (parsedJson.isMoody == null)
		{
			if (songName == 'roses')
			{
				parsedJson.isMoody = true;
			}
			else
			{
				parsedJson.isMoody = false;
			}
		}
		// is spooky means trails on spirit
		if (parsedJson.isSpooky == null)
		{
			if (parsedJson.stage.toLowerCase() == 'mallEvil')
			{
				parsedJson.isSpooky = true;
			}
			else
			{
				parsedJson.isSpooky = false;
			}
		}
		if (songName == 'winter-horrorland')
		{
			parsedJson.cutsceneType = "monster";
		}
		if (parsedJson.cutsceneType == null)
		{
			switch (songName)
			{
				case 'roses':
					parsedJson.cutsceneType = "angry-senpai";
				case 'senpai':
					parsedJson.cutsceneType = "senpai";
				case 'thorns':
					parsedJson.cutsceneType = 'spirit';
				case 'winter-horrorland':
					parsedJson.cutsceneType = 'monster';
				default:
					parsedJson.cutsceneType = 'none';
			}
		}
		if (parsedJson.uiType == null)
		{
			if (songName == 'roses' || songName == 'senpai' || songName == 'thorns')
			{
				parsedJson.uiType = 'pixel';
			}
			else
			{
				parsedJson.uiType = 'normal';
			}
		}

		return parsedJson;
	}

	public static function parseJSONshit(rawJson:String):SwagSong
	{
		var swagShit:SwagSong = cast CoolUtil.parseJson(rawJson).song;
		return swagShit;
	}
}
