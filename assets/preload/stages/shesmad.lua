function onCreate()
	-- background shit
	makeLuaSprite('shesmadstageback', 'shesmadstageback', -600, -300);
	setScrollFactor('shesmadstageback', 0.9, 0.9);
	
	makeLuaSprite('generalstagefront', 'generalstagefront', -650, 600);
	setScrollFactor('generalstagefront', 0.9, 0.9);
	scaleObject('generalstagefront', 1.1, 1.1);

	addLuaSprite('shesmadstageback', false);
	addLuaSprite('generalstagefront', false);
	
	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end