package;

import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.util.FlxTimer;

class ToolTip extends FlxSprite
{
	public var targetSpr:FlxSprite;
	public var toolText:FlxText;
	public var orientation:String = "";

	private var isShowing:Bool = false;
	private var showTimer:FlxTimer = new FlxTimer();

	override public function new(x:Float, y:Float, image:String, target:Dynamic, orientation:String, duration:Float, library:String)
	{
		super(x, y);
		targetSpr = target;
		loadGraphic(Paths.image(image, library));

		toolText = new FlxText(0, 0, this.width, "text");
		toolText.setFormat(Paths.font("whitney-bold.otf"), 30, 0xffffff, CENTER, FlxTextBorderStyle.OUTLINE, 0xff0000);
		toolText.borderSize = 2.5;
		this.orientation = orientation;
	}

	public function addText()
	{
		PlayState.instance.add(toolText);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if (targetSpr != null && targetSpr.exists)
		{
			switch (orientation)
			{
				case "above":
					x = targetSpr.x + targetSpr.width / 2 - this.width / 2;
					y = (targetSpr.y - height - 1);
				case "left":
					x = targetSpr.x - this.width - 1;
					y = targetSpr.y + targetSpr.height / 2 - this.height / 2;
				case "right":
					x = targetSpr.x + targetSpr.width + 1;
					y = targetSpr.y + this.width / 2 - this.height / 2;
				case "below":
					x = targetSpr.x + targetSpr.width / 2 - this.width / 2;
					y = targetSpr.y + targetSpr.height + 1;
				default:
					trace('orientations are above, left, right, and below. Argument: {$orientation}');
			}
			toolText.setPosition(this.x + (this.width - toolText.width) / 2, this.y + (this.height - toolText.height) / 2);
		}
	}

	public function showToolTip():Void
	{
		if (!isShowing)
		{
			this.visible = true;
			toolText.visible = true;

			showTimer.start(3, function(timer:FlxTimer):Void
			{
				this.visible = false;
				toolText.visible = false;
				isShowing = false;
			});

			isShowing = true;
		}
	}
}
