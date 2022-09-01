function onCreate()
	for i = 0, getProperty('unspawnNotes.length')-1 do
	    if  getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'Instakill notes' then
			setPropertyFromGroup('unspawnNotes', i, 'texture', 'deathnote'); --What image is going to be used for the note
			setPropertyFromGroup('unspawnNotes', i, 'noteSplashDisabled', true); --disables notesplashes because you die instally and would have no time to see it
			--setPropertyFromGroup('unspawnNotes', i, 'noteSplashTexture', 'deathsplash'); --here's what you would add if you wanted to have splash texture

			if getPropertyFromGroup('unspawnNotes', i, 'mustPress') == true then --Lets Opponent's instakill notes get ignored
				setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', true); --Miss has no penalties
			else
				setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', true);
			end
		end
	end
end

function goodNoteHit(id, noteData, noteType, isSustainNote)
	if noteType == 'Instakill notes' then
		setProperty('health', -1); --When you hit the note you will lose -1 health and therfore get blueballed
	end
end

-- This custom note was created by A Gamer Named Ryan You can find me here (https://gamebanana.com/members/2038807)