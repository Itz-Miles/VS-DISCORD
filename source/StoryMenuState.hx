package;

import flixel.effects.FlxFlicker;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import WeekData;
import flixel.util.FlxColor;
import flixel.text.FlxText;

using StringTools;

class StoryMenuState extends MusicBeatState
{
	// Wether you have to beat the previous week for playing this one, defaults to True
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();
	private static var lastDifficultyName:String = '';
	var curDifficulty:Int = CoolUtil.difficultyIndex(CoolUtil.defaultDifficulties, ClientPrefs.optionsDifficulty);
	private static var curWeek:Int = 0;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		#if desktop
		DiscordClient.changePresence("Story Mode", null);
		#end

		PlayState.isStoryMode = true;
		WeekData.reloadWeekFiles(true);
		if (curWeek >= WeekData.weeksList.length)
			curWeek = 0;

		for (i in 0...WeekData.weeksList.length)
		{
			WeekData.setDirectoryFromWeek(WeekData.weeksLoaded.get(WeekData.weeksList[i]));
		}

		WeekData.setDirectoryFromWeek(WeekData.weeksLoaded.get(WeekData.weeksList[0]));

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		if (lastDifficultyName == '')
		{
			lastDifficultyName = ClientPrefs.optionsDifficulty;
		}

		changeDifficulty();
		changeWeek();
		selectWeek();
	}

	override function closeSubState()
	{
		persistentUpdate = true;
		changeWeek();
		super.closeSubState();
	}

	function selectWeek()
	{
		if (!weekIsLocked(curWeek))
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			var songArray:Array<String> = [];
			var leWeek:Array<Dynamic> = WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]).songs;
			for (i in 0...leWeek.length)
			{
				songArray.push(leWeek[i][0]);
			}
			PlayState.storyPlaylist = songArray;
			PlayState.isStoryMode = true;
			var diffic = CoolUtil.getDifficultyFilePath(curDifficulty);
			if (diffic == null)
				diffic = '';
			PlayState.storyDifficulty = curDifficulty;
			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
			PlayState.campaignScore = 0;
			PlayState.campaignMisses = 0;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState(), true);
				FreeplayState.destroyFreeplayVocals();
			});
		}
		else
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}
	}

	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficulties.length - 1;
		if (curDifficulty >= CoolUtil.difficulties.length)
			curDifficulty = 0;

		lastDifficultyName = CoolUtil.difficulties[curDifficulty];

		#if !switch
		intendedScore = Highscore.getWeekScore(WeekData.weeksList[curWeek], curDifficulty);
		#end
	}

	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= WeekData.weeksList.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = WeekData.weeksList.length - 1;

		var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]);
		WeekData.setDirectoryFromWeek(leWeek);
		PlayState.storyWeek = curWeek;

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		var diffStr:String = WeekData.getCurrentWeek().difficulties;
		if (diffStr != null)
			diffStr = diffStr.trim(); // Fuck you HTML5

		if (diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if (diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if (diffs[i].length < 1)
						diffs.remove(diffs[i]);
				}
				--i;
			}
			if (diffs.length > 0 && diffs[0].length > 0)
			{
				CoolUtil.difficulties = diffs;
			}
		}

		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(ClientPrefs.optionsDifficulty)));
		var newPos:Int = CoolUtil.difficulties.indexOf(lastDifficultyName);
		if (newPos > -1)
		{
			curDifficulty = newPos;
		}
	}

	function weekIsLocked(weekNum:Int)
	{
		var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[weekNum]);
		return (!leWeek.startUnlocked
			&& leWeek.weekBefore.length > 0
			&& (!weekCompleted.exists(leWeek.weekBefore) || !weekCompleted.get(leWeek.weekBefore)));
	}
}