package;

import flash.geom.Matrix;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.FlxObject;
import flixel.util.FlxColor;


class ParallaxSprite extends FlxSprite 
{
    public var pointOne:FlxObject = new FlxObject();
    public var pointTwo:FlxObject = new FlxObject();
    var _scrollMatrix:Matrix = new Matrix();
    public var direction:Null<String> = 'horizontal';

    public function new(path:String, x:Float = 0, y:Float = 0) {
        super(x, y);
        loadGraphic(Paths.image('archpieces test/$path'));
        antialiasing = ClientPrefs.globalAntialiasing;
        origin.set(0, 0);
    }
    
    /**
     * Call this function to anchor the sprite's neutral position, set skew factors, and set the direction.
     * You can set these outside of this function, but this may lead to the sprite behaving unexpectedly.
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

    public function fixate(anchorX:Int = 0, anchorY:Int = 0, scrollOneX:Float = 1, scrollOneY:Float = 1, scrollTwoX:Float = 1.1, scrollTwoY:Float = 1.1, direct:String = 'horizontal'):Void {
        direction = direct;
        pointOne.scrollFactor.set(1, 1);
        pointTwo.scrollFactor.set(1, 1);
        pointOne.setPosition((anchorX + this.x), (anchorY + this.y));
        switch(direction) {
            case 'horizontal'|'orizzontale':
                pointTwo.setPosition((this.x + anchorX), (this.y + anchorY + this.height));
            case 'vertical'|'vertikale'|'verticale':
                pointTwo.setPosition((this.x + anchorX + this.width), (this.y + anchorY));
        }
        scrollFactor.set(scrollOneX, scrollOneY);
        pointOne.scrollFactor.set(scrollOneX, scrollOneY);
        pointTwo.scrollFactor.set(scrollTwoX, scrollTwoY);
    }

    override public function destroy():Void {
        pointOne = null;
        pointTwo = null;
        direction = null;
        _scrollMatrix = null;
        super.destroy();
    }

    override function drawComplex(camera:FlxCamera):Void {
            _frame.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, checkFlipX(), checkFlipY());
            _matrix.translate(-origin.x, -origin.y);
    
        if (bakedRotationAngle <= 0) {
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
    
                override public function isSimpleRender(?camera:FlxCamera):Bool {
                    if (FlxG.renderBlit) {
                        return super.isSimpleRender(camera) && (_scrollMatrix.c == 0) && (_scrollMatrix.b == 0);
                    }
                    else {
                        return false;
                    }
                }

    function updateScrollMatrix():Void {
		_scrollMatrix.identity();

		switch(direction) {//todo: update matrix only under certain conditions to avoid jittering every other frame

			case 'horizontal'|'orizzontale':
                setGraphicSize(Std.int(frameWidth), Std.int(pointTwo.getScreenPosition().y - pointOne.getScreenPosition().y));
				_scrollMatrix.c = ((pointTwo.getScreenPosition().x - pointOne.getScreenPosition().x) / ((frameHeight)));
				
        	case 'vertical'|'vertikale'|'verticale':
                setGraphicSize(Std.int(pointTwo.getScreenPosition().x - pointOne.getScreenPosition().x), Std.int(frameHeight));
				_scrollMatrix.b = ((pointTwo.getScreenPosition().y - pointOne.getScreenPosition().y) / (frameWidth));
		}
		_matrix.concat(_scrollMatrix);
	}
}

/*
 Sprites with multiple scroll factors to create a parallax effect.

 This class remains largely undocumented! Feel free to refer to previous versions or contact me for any info.

 Copyright 2022 It'z_Miles, some rights rerserved.

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