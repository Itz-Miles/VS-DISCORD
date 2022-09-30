package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import flixel.math.FlxAngle;
import flixel.input.keyboard.FlxKey;

using StringTools;

class MainMenuState extends MusicBeatState {

	public static var psychEngineVersion:String = '1.0';
	var menuItems:FlxTypedGroup<FlxSprite>; //look, I readded something for the sake of perfomrance!
	var sideBarSelect = 0;
	var selectedSomethin:Bool = false;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	var camFollow:FlxObject;
	public static var camFollowPos:FlxObject;
	var sideBar:FlxSprite;
	var directoryBar:FlxSprite;

	override function create() {

		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;

		#if desktop
		DiscordClient.changePresence("In the Menus", null);
		#end

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;
		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];
		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(483, -166).loadGraphic(Paths.image('bg'));
		bg.scrollFactor.set(0, 0.2);
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		sideBar = new FlxSprite(0, 0).loadGraphic(Paths.image('stripcrude'));
		sideBar.scrollFactor.set(0, 0);
		add(sideBar);
		
		directoryBar = new FlxSprite(130, 0).loadGraphic(Paths.image('serverName'));
		directoryBar.scrollFactor.set(0, 0);
		add(directoryBar);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, null, 1);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...3) {
			var menuItem:FlxSprite = new FlxSprite(130, 87 + (i * 88));
			menuItem.ID = i;
			menuItem.loadGraphic(Paths.image('menuItems/item' + menuItem.ID + (sideBarSelect == menuItem.ID)));
			menuItem.origin.set(0, 0);
			menuItem.setGraphicSize(353, 88);
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.updateHitbox();
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			trace('image path is: menuItems/item' + menuItem.ID + (sideBarSelect == menuItem.ID));
		}

		reloadItemGraphics('precache');

		super.create();
	}

	override function update(elapsed:Float) {

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (FlxG.sound.music.volume < 0.8) {
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}
		if (!selectedSomethin) {

		if (controls.UI_UP_P) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				sideBarSelect -= 1;
				reloadItemGraphics('change');
			}
			if (controls.UI_DOWN_P) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				sideBarSelect += 1;
				reloadItemGraphics('change');
			}
			
			if (controls.BACK) {
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				sideBarSelect = 69420;
				reloadItemGraphics('enter');
				MusicBeatState.switchState(new TitleState());
			}
			if (controls.ACCEPT) {
				selectedSomethin = true;
				reloadItemGraphics('enter');

			switch (sideBarSelect) {
				case 0:
					FlxG.sound.play(Paths.sound('confirmMenu'));
					new FlxTimer().start(1, function(tmr:FlxTimer){MusicBeatState.switchState(new StoryMenuChannel());});
				case 1:
					FlxG.sound.play(Paths.sound('confirmMenu'));
					new FlxTimer().start(1, function(tmr:FlxTimer){MusicBeatState.switchState(new FreeplayState());});
				case 2:
					FlxG.sound.play(Paths.sound('confirmMenu'));
					new FlxTimer().start(1, function(tmr:FlxTimer){MusicBeatState.switchState(new options.OptionsState());});
				}	
			}
		}
	super.update(elapsed);
	}

	function reloadItemGraphics(sus:String = '') {
		if (sideBarSelect == 3) sideBarSelect = 0;
		if (sideBarSelect <= -1) sideBarSelect = 2;
		switch(sus){
			case 'precache': //used during the transition
				menuItems.forEach(function(spr:FlxSprite) { //loads all of the selected graphics in advance
				spr.loadGraphic(Paths.image('menuItems/item' + spr.ID + 'true'));
				reloadItemGraphics('change');
				});

			case 'change':
				menuItems.forEach(function(spr:FlxSprite) { //loads the graphic based on whether it's selected
				spr.loadGraphic(Paths.image('menuItems/item' + spr.ID + (sideBarSelect == spr.ID)));
				});

			case 'enter':
				menuItems.forEach(function(spr:FlxSprite) { //isolates the sprite based on wether it's selected
				/*if (sideBarSelect != 69420)*/ spr.visible = (sideBarSelect == spr.ID);
				});
					}

			menuItems.forEach(function(spr:FlxSprite) { //sets camfollow's position based on whether it's selected
			if (spr.ID == sideBarSelect) camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			});
		}
	}