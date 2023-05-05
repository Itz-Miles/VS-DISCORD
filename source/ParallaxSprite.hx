package;

import flash.geom.Matrix;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.FlxObject;
import flixel.math.FlxPoint;

enum Direction {
	HORIZONTAL;
	VERTICAL;
	NULL;
}

class ParallaxSprite extends FlxSprite
{
	private var pointOne:FlxObject = new FlxObject();
	private var pointTwo:FlxObject = new FlxObject();
    private var _bufferOne:FlxPoint = new FlxPoint();
	private var _bufferTwo:FlxPoint = new FlxPoint();
	var _scrollMatrix:Matrix = new Matrix();
	public var direction:Direction = Direction.NULL;

	public function new(path:String, x:Float = 0, y:Float = 0, library:String = 'shared')
	{
		super(x, y);
		loadGraphic(Paths.image('$path', library));
		antialiasing = ClientPrefs.globalAntialiasing;
		origin.set(0, 0);
	}

	/**
	 * Call this function to anchor the sprite's neutral position, set skew factors, and set the direction.
	 * These can be set outside of this function, but doing so may lead to the sprite behaving unexpectedly.
	 * @param anchorX       (deprecated) the camera position where the sprite's x axis appears unchanged.
	 * @param anchorY       (deprecated) the camera position where the sprite's y axis appears unchanged.
	 * @param scrollOneX        the horizontal scroll factor of the first point.
	 * @param scrollOneY        the vertical scroll factor of the first point.
	 * @param scrollTwoX        the horizontal scroll factor fo the second point.
	 * @param scrollTwoY        the vertical scroll factor of the second point.
	 * @param direct        the sprite's direction, which determines the skew.
	 * 
	 * @param direct_horizontal     direct argument. typically for ceilings and floors. Skews on the x axis, stretches on the y axis.
	 * @param direct_vertical       direct argument. typically for walls and backdrops. Stretches on the x axis, skews on the y axis.
	**/
	
	public function fixate(anchorX:Int = 0, anchorY:Int = 0, scrollOneX:Float = 1, scrollOneY:Float = 1, scrollTwoX:Float = 1.1, scrollTwoY:Float = 1.1,
		direct:String = 'horizontal'):Void
	{
		pointOne.scrollFactor.set(1, 1);
		pointTwo.scrollFactor.set(1, 1);
		pointOne.setPosition((anchorX + x), (anchorY + y));
		switch (direct)
		{
			case 'horizontal' | 'orizzontale':
				direction = HORIZONTAL;
				pointTwo.setPosition((x + anchorX), (y + anchorY + frameHeight));
			case 'vertical' | 'vertikale' | 'verticale':
				direction = VERTICAL;
				pointTwo.setPosition((x + anchorX + frameWidth), (y + anchorY));
		}
		scrollFactor.set(scrollOneX, scrollOneY);
		pointOne.scrollFactor.set(scrollOneX, scrollOneY);
		pointTwo.scrollFactor.set(scrollTwoX, scrollTwoY);
	}

override public function destroy():Void
{
	pointOne = null;
	pointTwo = null;
	_bufferOne = null;
	_bufferTwo = null;
	direction = null;
	_scrollMatrix = null;
	super.destroy();
}

override function drawComplex(camera:FlxCamera):Void
{
	_frame.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, flipX, flipY);
	_matrix.translate(-origin.x, -origin.y);

	if (bakedRotationAngle <= 0)
	{
		updateTrig();

		if (angle != 0)
			_matrix.rotateWithTrig(_cosAngle, _sinAngle);
	}

	updateScrollMatrix();
	_matrix.scale(scale.x, scale.y);

	_point.addPoint(origin);
	if (isPixelPerfectRender(camera))
		_point.floor();

	_matrix.translate(_point.x, _point.y);
	camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing);
}

override public function isSimpleRender(?camera:FlxCamera):Bool 
	{
		if (!FlxG.renderBlit) return false;
	
		return super.isSimpleRender(camera) && (_scrollMatrix.c == 0) && (_scrollMatrix.b == 0);
	}

    private function updateScrollMatrix():Void
	{
		_scrollMatrix.identity();
		_bufferOne.copyFrom(pointOne.getScreenPosition());
		_bufferTwo.copyFrom(pointTwo.getScreenPosition());

		if (direction == HORIZONTAL)
		{	
			_scrollMatrix.c = (_bufferTwo.x - _bufferOne.x) / frameHeight;
			scale.y = (_bufferTwo.y - _bufferOne.y) / frameHeight;
		}
		else if (direction == VERTICAL) 
		{	
			_scrollMatrix.b = (_bufferTwo.y - _bufferOne.y) / frameWidth;
			scale.x = (_bufferTwo.x - _bufferOne.x) / frameWidth;
		}
		_matrix.concat(_scrollMatrix);
	}
}
/*
	Sprites with two sets of scroll factors.

	This class remains largely undocumented! Feel free to refer to previous versions or contact me for any info.
	Comply with the license!!!

	© 2022 It'z_Miles, some rights rerserved.

	  Licensed under the Apache License, Version 2.0 (the "License");
	  you may not use this file except in compliance with the License.
	  You may obtain a copy of the License at

			http://www.apache.org/licenses/LICENSE-2.0

	  Unless required by applicable law or agreed to in writing, software
	  distributed under the License is distributed on an "AS IS" BASIS,
	  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	  See the License for the specific language governing permissions and
	  limitations under the License.
 */