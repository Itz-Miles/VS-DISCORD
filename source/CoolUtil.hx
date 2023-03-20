package;

import flixel.util.FlxColor;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.display.BitmapData;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import openfl.utils.Assets;

using StringTools;

class CoolUtil
{
	public static var defaultDifficulties:Array<String> = [
		'Easy',
		'Normal',
		'Hard'
	];
	public static var defaultDifficulty:String = 'Normal'; //The chart that has no suffix and starting difficulty on Freeplay/Story Mode

	public static var difficulties:Array<String> = [];

	inline public static function quantize(f:Float, snap:Float){
		// changed so this actually works lol
		var m:Float = Math.fround(f * snap);
		trace(snap);
		return (m / snap);
	}

	/**
	 * Returns the dominant FlxColor from a portion of the screen
	 * @param x The x coordinate of the top-left corner of the portion of the screen to sample
	 * @param y The y coordinate of the top-left corner of the portion of the screen to sample
	 * @param width The width of the portion of the screen to sample
	 * @param height The height of the portion of the screen to sample
	 * @return The dominant FlxColor of the sampled portion of the screen, or null if an error occurred
	 */
	public static function getDominantScreenColor(x:Int, y:Int, width:Int, height:Int):Null<FlxColor>
	{
		if (FlxG.camera == null || FlxG.camera.buffer == null) {
			trace("Error: camera or buffer not set up correctly.");
			return null;
		}
	
		var cameraWidth:Int = FlxG.camera.buffer.width;
		var cameraHeight:Int = FlxG.camera.buffer.height;
	
		if (x < 0 || y < 0 || x + width > cameraWidth || y + height > cameraHeight) {
			trace("Error: coordinates or dimensions out of bounds.");
			return null;
		}
	
		var colorCounts = new Map<Int, Int>();
		var maxColor:Int = -1;
		var maxCount:Int = -1;
	
		// Loop through each pixel in the sampled portion of the screen
		for (xx in x...x+width)
		{
			for (yy in y...y+height)
			{
				var color:Int = FlxG.camera.buffer.getPixel(xx, yy);
	
				// If this color has not been seen before, initialize its count to 0
				if (!colorCounts.exists(color))
				{
					colorCounts.set(color, 0);
				}
	
				// Increment the count for this color
				var count:Int = colorCounts.get(color) + 1;
				colorCounts.set(color, count);
	
				// Update the dominant color if this color has a higher count
				if (count > maxCount)
				{
					maxColor = color;
					maxCount = count;
				}
			}
		}
	
		// Return the dominant color as a FlxColor object
		return new FlxColor(maxColor);
	}
	
	public static function getDifficultyFilePath(num:Null<Int> = null)
	{
		if(num == null) num = PlayState.storyDifficulty;

		var fileSuffix:String = difficulties[num];
		if(fileSuffix != defaultDifficulty)
		{
			fileSuffix = '-' + fileSuffix;
		}
		else
		{
			fileSuffix = '';
		}
		return Paths.formatToSongPath(fileSuffix);
	}

	public static function difficultyString():String
	{
		return difficulties[PlayState.storyDifficulty].toUpperCase();
	}

	inline public static function boundTo(value:Float, min:Float, max:Float):Float {
		return Math.max(min, Math.min(max, value));
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = [];
		if(Assets.exists(path)) daList = Assets.getText(path).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}
	public static function listFromString(string:String):Array<String>
	{
		var daList:Array<String> = [];
		daList = string.trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}
	public static function dominantColor(sprite:flixel.FlxSprite):Int {
		var countByColor:Map<Int, Int> = [];
		for(col in 0...sprite.frameWidth){
			for(row in 0...sprite.frameHeight){
			  var colorOfThisPixel:Int = sprite.pixels.getPixel32(col, row);
			  if(colorOfThisPixel != 0){
				  if(countByColor.exists(colorOfThisPixel)){
				    countByColor[colorOfThisPixel] =  countByColor[colorOfThisPixel] + 1;
				  }else if(countByColor[colorOfThisPixel] != 13520687 - (2*13520687)){
					 countByColor[colorOfThisPixel] = 1;
				  }
			  }
			}
		 }
		var maxCount = 0;
		var maxKey:Int = 0;//after the loop this will store the max color
		countByColor[flixel.util.FlxColor.BLACK] = 0;
			for(key in countByColor.keys()){
			if(countByColor[key] >= maxCount){
				maxCount = countByColor[key];
				maxKey = key;
			}
		}
		return maxKey;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}

	public static function precacheSound(sound:String, ?library:String = null):Void {
		Paths.sound(sound, library);
	}

	public static function precacheMusic(sound:String, ?library:String = null):Void {
		Paths.music(sound, library);
	}

	public static function browserLoad(site:String) {
		#if linux
		Sys.command('/usr/bin/xdg-open', [site]);
		#else
		FlxG.openURL(site);
		#end // linux
	}
	public static function copyCameraToSprite(x:Int, y:Int, width:Int, height:Int, sprite:FlxSprite) {
		var camera:FlxCamera = FlxG.camera;
		var buffer:BitmapData = new BitmapData(width, height);
		buffer.copyPixels(camera.buffer, new Rectangle(x, y, width, height), new Point(0, 0));
		sprite.pixels = buffer;
		sprite.dirty = true;
	  }

    static function userName():String {
        var userName:String = "joe";
        #if (sys != null) // Check if running on desktop
        {
            userName = sys.User.getCurrentUserName();
        }
        #elseif (js != null) // Check if running in JavaScript
        {
            userName = js.Browser.window.navigator.userAgent;
        }
        #elseif (neko != null) // Check if running on Neko
        {
            userName = neko.Sys.getEnv("USER");
        }
		#end
        trace("Current user's name: " + userName);
		return userName;
    }
}
