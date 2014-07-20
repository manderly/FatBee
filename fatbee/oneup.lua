--This is the one up class
--When game.lua needs to spawn a one up graphic, it spawns an instance of this class using parameters passed to it from game.lua

local class = require 'middleclass'
local Oneup = class('Oneup')

local oneupDestY = 200
local fullDestY = 50
local oneupTransitionTime = 1000

local oneupScaleNormal = .75
local oneupScaleBIG = 1

local oneupGraphic 


local oneupSizes = {
	   oneup_1 	= 	{sizeX=460, sizeY=198, 	scale=oneupScaleNormal, 	xDest=0, 					yDest=oneupDestY},
	   oneup_2 	= 	{sizeX=460, sizeY=198,	scale=oneupScaleNormal, 	xDest=0, 					yDest=oneupDestY},
	   oneup_3 	= 	{sizeX=460, sizeY=198,	scale=oneupScaleNormal, 	xDest=0, 					yDest=oneupDestY},
	   oneup_4 	= 	{sizeX=460, sizeY=198, 	scale=oneupScaleNormal, 	xDest=0, 					yDest=oneupDestY},
	   oneup_5 	= 	{sizeX=460, sizeY=198, 	scale=oneupScaleBIG, 		xDest=0, 					yDest=oneupDestY},
	   full 	= 	{sizeX=165, sizeY=73, 	scale=oneupScaleBIG, 		xDest=0, 					yDest=fullDestY},
	   score_1 	= 	{sizeX =92,	sizeY=73, 	scale=oneupScaleBIG, 		xDest=150, 					yDest=-50}
	}


function Oneup:initialize(graphicName,xPos,yPos,group)
	self.oneupGraphic = display.newImageRect('images/' .. graphicName .. '.png',oneupSizes[graphicName].sizeX,oneupSizes[graphicName].sizeY)
	self.oneupGraphic.anchorX = 0
	self.oneupGraphic.anchorY = 1
	self.oneupGraphic.xScale = oneupSizes[graphicName].scale
	self.oneupGraphic.yScale = oneupSizes[graphicName].scale
	self.oneupGraphic.x = xPos
	self.oneupGraphic.y = yPos

	group:insert(self.oneupGraphic)
	self:oneupMove(oneupTransitionTime, graphicName)
end

function Oneup:oneupRemove()
	self.oneupGraphic:removeSelf()
	self.oneupGraphic = nil
end

function Oneup:oneupMove(transitionTime, graphicName)
	transition.to(self.oneupGraphic, {time=transitionTime, alpha=0, x=oneupSizes[graphicName].xDest, y=oneupSizes[graphicName].yDest, onComplete = function()
		self:oneupRemove()
	end
	})
end



return Oneup