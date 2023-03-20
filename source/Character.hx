package;

import Discord;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import animateatlas.AtlasFrameMaker;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.effects.FlxTrail;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.tweens.FlxTween;
import flixel.util.FlxSort;
import Section.SwagSection;
import flixel.math.FlxMath;
import flixel.group.FlxGroup;
import flixel.FlxState;
import openfl.utils.AssetType;
import openfl.utils.Assets;
import haxe.Json;
import haxe.format.JsonParser;
import flixel.math.FlxPoint;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;

using StringTools;
typedef CharacterFile = {
	var animations:Array<AnimArray>;
	var image:String;
	var scale:Float;
	var sing_duration:Float;
	var healthicon:String;
	/*
    var initalGravity:Float;
    var initialDrag:Array;
    var initalAddVelocity:Array;
    var initialTarget:Character;
	*/
	var position:Array<Float>;
	var camera_position:Array<Float>;

	var flip_x:Bool;
	var no_antialiasing:Bool;
	var healthbar_colors:Array<Int>;
}

typedef AnimArray = {
	var anim:String;
	var name:String;
	var fps:Int;
	var loop:Bool;
	var indices:Array<Int>;
	var offsets:Array<Int>;
}

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var isDead:Bool = false;
	public var curCharacter:String = DEFAULT_CHARACTER;

	public var colorTween:FlxTween;
	public var holdTimer:Float = 0;
	public var heyTimer:Float = 0;
	public var specialAnim:Bool = false;
	public var animationNotes:Array<Dynamic> = [];
	public var stunned:Bool = false;
	public var singDuration:Float = 4; //Multiplier of how long a character holds the sing pose
	public var idleSuffix:String = '';
	public var danceIdle:Bool = false; //Character use "danceLeft" and "danceRight" instead of "idle"
	public var skipDance:Bool = false;
	public var danceMult:Int = 1;

	public var healthIcon:String = 'face';
	public var animationsArray:Array<AnimArray> = [];

	public var positionArray:Array<Float> = [0, 0];
	public var cameraPosition:Array<Float> = [0, 0];

	public var hasMissAnimations:Bool = false;

	//Used on Character Editor
	public var imageFile:String = '';
	public var jsonScale:Float = 1;
	public var noAntialiasing:Bool = false;
	public var originalFlipX:Bool = false;
	public var healthColorArray:Array<Int> = [255, 0, 0];

	public static var DEFAULT_CHARACTER:String = 'bf'; //In case a character is missing, it will use BF on its place
	var isShielding:Bool;
	var elapsedDamage:Float;
	public var stupidRatColor:FlxColor;
    // target   
    public var target:Character;
	public var targetSpeed:Float;
	var facingLeft:Bool; //ok
    // movement
	var overrideCollision:Dynamic;
	var addVelocityY:Dynamic;
	var overrideGravity:Dynamic;
	var overrideDragX:Dynamic;
	var addVelocityX:Dynamic;
	// offhand

	public function new(x:Float, y:Float, ?character:String = 'bf', ?isPlayer:Bool = false, ?library:String)
	{
		super(x, y);

		animOffsets = new Map();
		
		curCharacter = character;
		this.isPlayer = isPlayer;
		antialiasing = ClientPrefs.globalAntialiasing;
		switch (curCharacter) {
			default:
				var characterPath:String = 'characters/' + curCharacter + '.json';

	
				var path:String = Paths.getPreloadPath(characterPath);
				if (!Assets.exists(path)) {
					path = Paths.getPreloadPath('characters/' + DEFAULT_CHARACTER + '.json'); //If a character couldn't be found, change him to BF just to prevent a crash
				}

				var rawJson = Assets.getText(path);

				var json:CharacterFile = cast Json.parse(rawJson);
				var spriteType = "sparrow";
				//sparrow, packer, texture
			
				if (Assets.exists(Paths.getPath('images/' + json.image + '.txt', TEXT, library))) {
					spriteType = "packer";
				}
				
			
				if (Assets.exists(Paths.getPath('images/' + json.image + '/Animation.json', TEXT, library))) {
					spriteType = "texture";
				}

				switch (spriteType) {
					
					case "packer":
						frames = Paths.getPackerAtlas(json.image, library);
					
					case "sparrow":
						frames = Paths.getSparrowAtlas(json.image, library);
					
					case "texture":
						frames = AtlasFrameMaker.construct(json.image); //far too busy to add library stuff to atlasframemaker rn.
				}
				imageFile = json.image;

				if(json.scale != 1) {
					jsonScale = json.scale;
					setGraphicSize(Std.int(width * jsonScale));
					updateHitbox();
				}

				positionArray = json.position;
				cameraPosition = json.camera_position;

				healthIcon = json.healthicon;
				singDuration = json.sing_duration;
				flipX = !!json.flip_x;
				if(json.no_antialiasing) {
					antialiasing = false;
					noAntialiasing = true;
				}

				if(json.healthbar_colors != null && json.healthbar_colors.length > 2)
					healthColorArray = json.healthbar_colors;

				antialiasing = !noAntialiasing;
				if(!ClientPrefs.globalAntialiasing) antialiasing = false;

				animationsArray = json.animations;
				if(animationsArray != null && animationsArray.length > 0) {
					for (anim in animationsArray) {
						var animAnim:String = '' + anim.anim;
						var animName:String = '' + anim.name;
						var animFps:Int = anim.fps;
						var animLoop:Bool = !!anim.loop; //Bruh
						var animIndices:Array<Int> = anim.indices;
						if(animIndices != null && animIndices.length > 0) {
							animation.addByIndices(animAnim, animName, animIndices, "", animFps, animLoop);
						} else {
							animation.addByPrefix(animAnim, animName, animFps, animLoop);
						}

						if(anim.offsets != null && anim.offsets.length > 1) {
							addOffset(anim.anim, anim.offsets[0], anim.offsets[1]);
						}
					}
		}
		originalFlipX = flipX;

		if(animOffsets.exists('singLEFTmiss') || animOffsets.exists('singDOWNmiss') || animOffsets.exists('singUPmiss') || animOffsets.exists('singRIGHTmiss')) hasMissAnimations = true;
		recalculateDanceIdle();
		dance();

			if (isPlayer) 
				flipX = !flipX;
		}
	}

	override function update(elapsed:Float)
	{
		if(target != null) {//target code 
					var xDelta:Float = target.getMidpoint().x - this.getMidpoint().x;
					target.facingLeft = !target.flipX; //the player graphic faces left by default
				
					if ((xDelta > 0 && target.facingLeft) || (xDelta < 0 && !target.facingLeft)) {
						// The target is looking towards this sprite
						return;
					}
				
					// Calculate the new x-coordinate for this sprite based on the xDiff and speed
					var newX:Float = x + FlxMath.signOf(xDelta) * targetSpeed * FlxG.elapsed;
				
					// Update the position of the sprite
					this.x = newX;
				
					// Update the flipX value of the sprite based on the xDiff
					xDelta < 0 ? this.flipX = true : this.flipX = false;
					this.facingLeft = this.flipX;
		}

		if(!debugMode && animation.curAnim != null)
		{
			if(heyTimer > 0)
			{
				heyTimer -= elapsed;
				if(heyTimer <= 0)
				{
					if(specialAnim && animation.curAnim.name == 'hey' || animation.curAnim.name == 'cheer')
					{
						specialAnim = false;
						dance();
					}
					heyTimer = 0;
				}
			} else if(specialAnim && animation.curAnim.finished)
			{
				specialAnim = false;
				dance();
			}

			if (!isPlayer)
			{
				if (animation.curAnim.name.startsWith('sing'))
				{
					holdTimer += elapsed;
				}

				if (holdTimer >= Conductor.stepCrochet * 0.0011 * singDuration)
				{
					dance();
					holdTimer = 0;
				}
			}

			if(animation.curAnim.finished && animation.getByName(animation.curAnim.name + '-loop') != null)
			{
				playAnim(animation.curAnim.name + '-loop');
			}
		}

		//jumping test
		if(this.overrideCollision != "false" && Math.abs(this.y - this.overrideCollision) < 10 && this.velocity.y > 0) {
			this.y = this.overrideCollision;
			this.overrideCollision = null;
			this.overrideGravity = null;
			this.acceleration.y = 0;
			this.velocity.y = 0;
		}
		super.update(elapsed);
	}

	public var danced:Bool = false;

	/**
	 * FOR DANCING
	 */
	public function dance(?force:Bool)
	{
		if (!debugMode && !skipDance && !specialAnim)
		{
			if(danceIdle)
			{
				danced = !danced;

				if (danced)
					playAnim('danceRight' + idleSuffix);
				else
					playAnim('danceLeft' + idleSuffix);
			}
			else if(animation.getByName('idle' + idleSuffix) != null) {
					playAnim('idle' + idleSuffix, force);
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		specialAnim = false;
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);

		if (curCharacter.startsWith('gf'))
		{
			if (AnimName == 'singLEFT')
			{
				danced = true;
			}
			else if (AnimName == 'singRIGHT')
			{
				danced = false;
			}

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
			{
				danced = !danced;
			}
		}
	}

	function sortAnims(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0], Obj2[0]);
	}

	public var danceEveryNumBeats:Int = 2;
	private var settingCharacterUp:Bool = true;
	public function recalculateDanceIdle() {
		var lastDanceIdle:Bool = danceIdle;
		danceIdle = (animation.getByName('danceLeft' + idleSuffix) != null && animation.getByName('danceRight' + idleSuffix) != null);

		if(settingCharacterUp)
		{
			danceEveryNumBeats = (danceIdle ? 1 : 2);
		}
		else if(lastDanceIdle != danceIdle)
		{
			var calc:Float = danceEveryNumBeats;
			if(danceIdle)
				calc /= 2;
			else
				calc *= 2;

			danceEveryNumBeats = Math.round(Math.max(calc, 1));
		}
		settingCharacterUp = false;
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}

	public function act(arguments:Array<Dynamic>) {

		var theAction = arguments[0];
		var theArgumentsArray = arguments.slice(1);

		switch(theAction){

		case 'idle':
			this.idleSuffix = theArgumentsArray[0];
			this.recalculateDanceIdle();

		case 'fade':
			var duritation:Float = Std.parseFloat(theArgumentsArray[0]);
			var targetedAlpha:Float = Std.parseFloat(theArgumentsArray[1]);

			if (duritation <= 0){
			this.alpha = targetedAlpha;
			//this.icon.alpha = targetedAlpha;
			} else {
			FlxTween.tween(this, {alpha: targetedAlpha}, duritation);
			//FlxTween.tween(this.icon, {alpha: targetedAlpha}, duritation);
			}
			//might give multiple characters their own individual icons without needing reflection

		case 'hey':
				var time:Float = Std.parseFloat(theArgumentsArray[0]);
				if(Math.isNaN(time) || time <= 0) time = 0.6;
				this.playAnim('hey', true);
				this.specialAnim = true;
				this.heyTimer = time;

		case 'animation':
			this.playAnim(theArgumentsArray[0], true);
			this.specialAnim = true;

		case 'attack':
			this.playAnim(theArgumentsArray[0], theArgumentsArray[1], theArgumentsArray[2], theArgumentsArray[3]);
			switch(theArgumentsArray[4]) {
				case 'punch':

				case 'kick':
					//
				case 'shoot':

				case 'swing':

				case 'stun':
					Reflect.field(PlayState.instance, theArgumentsArray[0]).stunned = true; //ok?

				default:
					trace('error: cannot define attack type ${theArgumentsArray[4]}');
			}
			//this.elapsedDamage = theArgumentsArray[4],
		
		case 'parkour':
			//wether the chracter is controlled
			//sets the parkour stuff
			//can jump, jump height, jump tween
			//can unbound, unbound vars, unbound action
			//can move, move limitations
			//other velocity variables an stuff

		case 'shield':
			//shields from attacks
			this.isShielding = true; //yes

		case 'jump':
			overrideGravity = theArgumentsArray[0];
			addVelocityY = theArgumentsArray[1];
			overrideCollision = theArgumentsArray[2];

			this.velocity.y = this.addVelocityY;
			if (overrideGravity != 'false') this.acceleration.y = this.overrideGravity;
			//collision in update

			//reset variables

		case 'move':
			addVelocityX = theArgumentsArray[0];
			this.velocity.x += addVelocityX;
			if(theArgumentsArray[1] != 'false') {
				overrideDragX = theArgumentsArray[1];
				this.drag.x = overrideDragX;
			}
		case 'grab': //might change this to an attack later
			//grabs existing item


		case 'die':
			//change this to vs discord death
			this.isDead = true;
			this.origin.set(this.width /2, (this.height));
			if (theArgumentsArray[0] != null) 	
				FlxG.sound.play(Paths.sound(theArgumentsArray[0]));

			if (this.isPlayer) {
				FlxTween.tween(FlxG.camera, {zoom: 1.1}, 1, {ease: FlxEase.elasticInOut, onComplete: function(twn:FlxTween) {		
					
					FlxTween.angle(this, 0, 90, 0.5, {ease: FlxEase.quadInOut});	
					
					FlxTween.color(this, 0.5, FlxColor.WHITE, 0xFFe6726a, {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween) {
					
						PlayState.instance.killNotes();
					
						new FlxTimer().start(1, function(tmr:FlxTimer) {
							
							this.visible = false;
							PlayState.instance.openSubState(new GameOverSubstate());
							#if desktop
							DiscordClient.changePresence("Game Over - " + PlayState.instance.detailsText, PlayState.SONG.song + " (" + PlayState.instance.storyDifficultyText + ")", this.curCharacter);
							#end
						});
					
					}});
				
				}});
			
			} else {
				new FlxTimer().start(1, function(tmr:FlxTimer) {	
				
					FlxTween.angle(this, 0, 90, 0.5, {ease: FlxEase.quadInOut});	
				
					FlxTween.color(this, 0.5, FlxColor.WHITE, 0xFFe6726a, {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween) {
				
						new FlxTimer().start(1, function(tmr:FlxTimer) {
							this.visible = false;
						});
					
					}});
			
				});
			
			}

		case 'despawn':
			//might seperate die and respawn
		case 'respawn':
			this.visible = true;

			FlxTween.tween(FlxG.camera, {zoom: 1}, 1, {ease: FlxEase.elasticInOut, onComplete: function(twn:FlxTween) {
			
				FlxTween.angle(this, 90, 0, 0.5, {ease: FlxEase.quadInOut});
				
					FlxTween.color(this, 0.5, 0xFFe6726a,  FlxColor.WHITE,{ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween) {
			
						new FlxTimer().start(1, function(tmr:FlxTimer) {
							LoadingState.loadAndSwitchState(new PlayState(), true);
						});
			
					}});
			
				}});
		case 'command':

		case 'target':
			this.target = Std.downcast(Reflect.field(PlayState.instance, theArgumentsArray[0]), Character);
			trace('target: ' + this.target);
			trace('target x: ' + this.target.x);
        	this.targetSpeed = theArgumentsArray[1];

		default:
			trace('No particular action called ' + theAction);
			trace('arguments called for ' + theAction + ": " + theArgumentsArray);
		}
	}
}




class Boyfriend extends Character
{
	public var startedDeath:Bool = false;

	public function new(x:Float, y:Float, ?char:String = 'bf')
	{
		super(x, y, char, true);
	}

	override function update(elapsed:Float)
	{
		if (!debugMode && animation.curAnim != null)
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}
			else
				holdTimer = 0;

			if (animation.curAnim.name.endsWith('miss') && animation.curAnim.finished && !debugMode)
			{
				playAnim('idle', true, false, 10);
			}

			if (animation.curAnim.name == 'firstDeath' && animation.curAnim.finished && startedDeath)
			{
				playAnim('deathLoop');
			}
		}

		super.update(elapsed);
	}
}
