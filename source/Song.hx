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
	var gfVersion:String;
	var noteStyle:String;
	var stage:String;
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
		if (parsedJson.stage == null) parsedJson.stage = 'stage';
		if (parsedJson.gfVersion == null) parsedJson.gfVersion = 'gf';
		if (parsedJson.noteStyle == null) parsedJson.noteStyle = 'normal';

		return parsedJson;
	}

	public static function parseJSONshit(rawJson:String):SwagSong
	{
		var swagShit:SwagSong = cast CoolUtil.parseJson(rawJson).song;
		return swagShit;
	}
}
