


--This is the pollen class
--When game.lua needs to spawn a pollen, it creates an instance of this class

--not sure if these are essential
local class = require 'middleclass'
local Pollen = class('Pollen')

--constructor?
function Pollen:initialize(displayGroupThing, x,y)
	--POLLEN ANIM PARTS
	local pollenSpriteParams = 
	{
		width = 182,
		height = 164,
		numFrames = 10,
		sheetContentWidth = 1822,
		sheetContentHeight = 164,
	}
	local pollenSheet = graphics.newImageSheet( "images/pollen_sheet.png", pollenSpriteParams )
	local pollenAnimationData = {
		{ name ="idle", start=1, count=10, time=400, loopCount = 1}
	}

	pollen = display.newSprite( pollenSheet, pollenAnimationData)
	pollen.anchorX = 0.5
	pollen.anchorY = 0
	pollen.x = x
	pollen.y = y
	displayGroupThing:insert(pollen)
	pollen:setSequence("idle")
	pollen:play()

end

return Pollen