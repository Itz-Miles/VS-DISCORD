function onCreate()
	-- background shit
	makeLuaSprite('vcback', 'vcback', -600, -300);
	setScrollFactor('vcback', 0.9, 0.9);
	
	makeLuaSprite('vcfront', 'vcfront', -465, 750);
	setScrollFactor('vcfront', 0.9, 0.9);
	scaleObject('vcfront', 0.9, 0.9);

	addLuaSprite('vcback', false);
	addLuaSprite('vcfront', false);
	
	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end