function onCreate()
	-- background shit
	makeLuaSprite('spacestageback', 'spacestageback', -600, -300);
	setScrollFactor('stageback', 0.9, 0.9);
	
	makeLuaSprite('spacestagefront', 'spacestagefront', -650, 600);
	setScrollFactor('spacestagefront', 0.9, 0.9);
	scaleObject('spacestagefront', 1.1, 1.1);


	addLuaSprite('spacestageback', false);
	addLuaSprite('spacestagefront', false);
	
	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end