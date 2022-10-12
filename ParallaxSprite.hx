package;

import flash.geom.Matrix;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.util.FlxDestroyUtil;
import flixel.math.FlxPoint;
import flixel.FlxObject;
import flixel.util.FlxColor;


class ParallaxSprite extends FlxSprite 
{
    public var pointOne:FlxObject = new FlxObject();
    public var pointTwo:FlxObject = new FlxObject();
    var _scrollMatrix:Matrix = new Matrix();
	public var direction:Null<String> = 'horizontal';

        public function new(img:String, x:Float = 0, y:Float = 0) {
			super(x, y); /* ALWAYS call back to constructors immedately whgen overriding low-level functions. Putting super() after loadGraphic causes a crash.*/
            loadGraphic(Paths.image(img));            
            antialiasing = ClientPrefs.globalAntialiasing;
            origin.set(0, 0); //just in case
        }


        /* 
        Call this function to anchor the sprite's neutral position/set skew factors/set direction.
        You can set these outside of the function, but the inaccuracies may lead to the sprite behaving unexpectedly.
        */
        public function fixate(anchorX:Int = 0, anchorY:Int = 0, scrollOneX:Float = 1, scrollOneY:Float = 1, scrollTwoX:Float = 1.1, scrollTwoY:Float = 1.1, direct:String = 'horizontal'):Void {
            direction = direct;
            pointOne.setPosition(anchorX, anchorY);
            switch(direction) {
                case 'horizontal':
                pointTwo.setPosition((anchorX), (anchorY + this.height));
                case 'vertical':
                pointTwo.setPosition((anchorX + this.width), (anchorY));
            }
            scrollFactor.set(scrollOneX, scrollOneY);
            pointOne.scrollFactor.set(scrollOneX, scrollOneY);
            pointTwo.scrollFactor.set(scrollTwoX, scrollTwoY);
        }

        /*destroy EVERYTHING (when not needed)*/
        override public function destroy():Void {
            pointOne = null;
            pointTwo = null;
            direction = null;
            _scrollMatrix = null;
            super.destroy();
        }
   
	    override function drawComplex(camera:FlxCamera):Void { /* low level draw function intercepted by the scrollMatrix*/
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

		switch(direction) {

			case 'horizontal'://floors, ceilings, and other horizontal elements
                setGraphicSize(Std.int(frameWidth), Std.int(pointTwo.getScreenPosition().y - pointOne.getScreenPosition().y));
				_scrollMatrix.c = ((pointTwo.getScreenPosition().x - pointOne.getScreenPosition().x) / ((frameHeight)));
				
                
        	case 'vertical': // walls and other vertical elements
                setGraphicSize(Std.int(pointTwo.getScreenPosition().x - pointOne.getScreenPosition().x), Std.int(frameHeight));
				_scrollMatrix.b = ((frameWidth) / (pointTwo.getScreenPosition().x - pointOne.getScreenPosition().x));
		}
		_matrix.concat(_scrollMatrix);
	}
}

/*
 It'z_Miles

 Sprites with scroll factors that support 3D displacement projection.
 I haven't documented everything on this version, feel free to contact me for any info.
 If you fail to comply with the apache licsence's terms, I will beat you with a sack of oranges.
 (That means you, Bill! Don't nab code and remove the credit!)
*/
