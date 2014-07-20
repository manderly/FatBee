--This is the player class

local class = require 'middleclass'
local Player = class('Player')

--bee gameplay vars
local beeFat = 0

--bee physics vars
local tapLiftVar = -600
local forwardLiftVar = 50
local playerMaxYVar = 0
local startBeePopup = -200

local playerMaxX = display.viewableContentWidth * .5
local beeMaxXVelocityAllowed = 15
local beeResetToThisXVelocity = 10
local rotationDamper = 30

--bee size vars
local beeRadius1 = 45
local beeRadius2 = 120
local beeRadius3 = 160

local beeScaleUpVar = 1.23

local playerBee

function Player:initialize(displayGroupName,x,y) --when you make a player, pass the display group and the x y it belongs in
	--GRAPHIC AND ANIMATION DATA
	local playerSpriteParams = 
		{
			-- Required params
			width = 202,
			height = 162,
			numFrames = 2,
			-- content scaling
			sheetContentWidth = 404,
			sheetContentHeight = 162,
		}

	local playerSheet = graphics.newImageSheet( "images/bee.png", playerSpriteParams )

	self.playerBee = display.newSprite( playerSheet, { name="player", start=1, count=2, time=500 } )
	self.playerBee.anchorX = 0.5
	self.playerBee.anchorY = 0.5
	self.playerBee.x = display.contentCenterX
	self.playerBee.y = display.contentCenterY
	
	--player collision listeners
	self.playerBee.preCollision = preCollisionPlayer
	self.playerBee:addEventListener("preCollision", player)
	self.playerBee.postCollision = postCollisionPlayer
	self.playerBee:addEventListener("postCollision", player)

	self.beeFat = 0

	--polygonal bee shape
	physics.addBody(self.playerBee, "static", {density=1, bounce=0, friction=frictionBee, radius=beeRadius1})

	displayGroupName:insert(self.playerBee)
	self.playerBee:play()
end

function Player:startGame()
	self.playerBee.bodyType = "dynamic" -- turns physics on for the player body

	--one of these two applyForces is probably unnecessary 
	--player:applyForce(forwardLiftVar, -900, player.x, player.y)
	self.playerBee:applyForce(0, startBeePopup, self:getBeeX(), self:getBeeY())
end

function Player:setBeeX(x)
	self.playerBee.x = x
end

function Player:getBeeX()
	return self.playerBee.x
end

function Player:getBeeY()
	return self.playerBee.y
end

function Player:tap()
	if (self:getBeeY() > playerMaxYVar) then -- if player is below the top of the screen
    	-- pop up 
    	self.playerBee:setLinearVelocity(forwardLiftVar, tapLiftVar, self:getBeeX(), self:getBeeY())
	end
end

function Player:rotate()
	if (self.playerBee) then
		local xVelocityVar,yVelocityVar = self.playerBee:getLinearVelocity()
		if (yVelocityVar > 80) then
			self.playerBee.rotation = yVelocityVar * 1.1 / rotationDamper
		else
			self.playerBee.rotation = (yVelocityVar + 50) / rotationDamper
		end

		--restrict X speed to prevent shoot outs
		
		if (self:getBeeX() > playerMaxX) then --if player's X velocity is greater than the max velocity allowed
			self:setBeeX(playerMaxX) --set beeX to player max X
			self.playerBee:setLinearVelocity(beeResetToThisXVelocity, yVelocityVar) --also cap velocity
		end
	end
end


function Player:setBeeFat(beeFatVar)
	self.beeFat = beeFatVar
end

function Player:getBeeFat()
	print ("beeFat level ", self.beeFat)
	return self.beeFat
end

function Player:addBeeFat(beeFatVar)
	self.beeFat = self.beeFat + beeFatVar
end

function Player:scaleBeeUp()
	self.playerBee.xScale = self.playerBee.xScale * beeScaleUpVar
	self.playerBee.yScale = self.playerBee.yScale * beeScaleUpVar
end

function Player:scaleBeeDefault(scaleSize)
	self.playerBee.xScale = scaleSize
	self.playerBee.yScale = scaleSize
end


function Player:resetBeeThin()
	print ("reset bee thin OK")
	self:scaleBeeDefault(1)
	self.beeFat = 0
	--gravityVar = gravityDefault
	--physics.setGravity( 0, gravityVar )
end 


function Player:removeBee()
	--self:removeBeePhysics()
	self:removeListeners()
	self.playerBee:removeSelf()
	self.playerBee = nil
end


function Player:removeBeePhysics()
	physics.removeBody(self.playerBee) -- does not work, bee continues to have physics
end

function Player:removeListeners()
	self.playerBee:removeEventListener("preCollision", player)
	self.playerBee:removeEventListener("postCollision", player)
end


return Player