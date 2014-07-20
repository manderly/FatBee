------------------------------------------------------------------------------
-- REQUIRES AND CLASSES
------------------------------------------------------------------------------

local class = require 'middleclass'
local Pollen = require("pollen")
local Score = require("score")
local Player = require("player")
local Oneup = require("oneup")

local physics = require "physics"
local mydata = require( "mydata" )
local storyboard = require ("storyboard")
local scene = storyboard.newScene()

------------------------------------------------------------------------------
-- GAMEPLAY VARS
------------------------------------------------------------------------------

--DEBUG OPTIONS DO NOT SET TRUE FALSE HERE THIS IS JUST MEMORY ALLOCATION
local enemyBeesOn -- toggles the presence of enemy bees
local memoryUsageText -- toggles the memory usage text spam in the output


--Player gravity must go before physics
local player 
local gravityDefault = 70

--Start the engines
physics.start()
physics.setGravity( 0, gravityDefault )
--physics.setDrawMode( "hybrid" ) --toggles physics visibility

local random = math.random

--physics
local frictionFlower = 50
local bounceFlower = .9
local frictionBee = 50

--scroll object speeds
local scrollObjectSpeed = 12
local scrollEnemyBeeSpeed = 18
local scrollCloudSpeed = 3

--Flower height min and max
local flowerHeightLowest = 235 -- the lowest height on the screen that the flower pot can appear (if this number gets too small, the pot will be obscured by the grass)
local flowerHeightHighest = display.contentCenterY - 100 -- the center of the screen minus a couple hundred pixels

--Scroll object spacing
local minHiveWait = 2500
local maxHiveWait = 6000

local minEnemyWait = 6000
local maxEnemyWait = 10000

--Enemy height min and max
local enemyHeightLowest = display.contentHeight - 600 -- the lowest height on the screen that the enemy bee can appear (if this number gets too small, the pot will be obscured by the grass)
local enemyHeightHighest = 0 -- the center of the screen minus a couple hundred pixels

--Tutorial flags
local firstDelivery = false
local makeDeliveryReminderFlag = false
local collisionDone = false

--Game state flags
local gameActive = false
local startGamePressed = false
local groundShouldBeMoving = true

--DISPLAY GROUPS. ORDER MATTERS HERE
local staticGroupSky = display.newGroup() -- sky goes in here
local scrollGroupClouds = display.newGroup() -- sky and clouds go into here
local scrollGroupGameObjects  -- flowers, hives go into here
local beeGroup = display.newGroup() -- must go over sky and clouds
local scrollGroupGround = display.newGroup() -- ground goes in here
local newGameGroup = display.newGroup() -- what goes in here?

--Scoring data (probably belongs in score class)
local pointsEarned
local roundsPlayed = 0

function initVars()
	--debug vars
	enemyBeesOn = true -- toggles the presence of enemy bees
	memoryUsageText = false -- toggles the memory usage text spam in the output

	--other vars
	scrollingGround.collisionID = "ground"
	scrollingGround2.collisionID = "ground"
	gravityVar = gravityDefault
	player:setBeeFat(0) --does not exist yet?
	makeDeliveryReminderFlag = false
end

local endGameOptions =
{
    effect = "fade",
    time = 200,
    isModal = true;
}

--PHYSICS SHAPES
shapeFlowerPot = {-100,-233, 100,-233, 100,433, -100,433}
shapeFlowerFace = { -70,-60, 70,-60, 70,50, -70, 50}
shapeBeehive = { -150,-150, 150,-150, 100,100, -100,100}
shapeEnemyBee = { -64,-54, 64,-54, 64,44, -64,44}

------------------------------------------------------------------------------
-- ANIMATION PARAMETERS AND SHEETS
------------------------------------------------------------------------------

-- NEW FLOWER PARTS
local flowerFaceSpriteParams = 
	{
		width = 258,
		height = 291,
		numFrames = 14,
		sheetContentWidth = 1808,
		sheetContentHeight = 582,
	}
local flowerFaceSheet = graphics.newImageSheet( "images/flower_sheet.png", flowerFaceSpriteParams )
local flowerAnimationData = {
	{ name ="idle", start=1, count=4, time=500, loopDirection = "bounce"},
	{ name ="bounceCollect", start=5, count=6, time=300, loopCount = 1},
	{ name ="bounceNoCollect", start=5, count=3, time=300, loopDirection = "bounce", loopCount = 1},
	{ name ="touched", start=11, count=4, time=500, loopDirection = "bounce"}
}

--BEE HIVE PARTS
local beeHiveSpriteParams = 
	{
		width = 321,

		height = 321,
		numFrames = 3,
		sheetContentWidth = 963,
		sheetContentHeight = 321,
	}
local beeHiveSheet = graphics.newImageSheet( "images/beehive.png", beeHiveSpriteParams )
local beeHiveAnimationData = {
	{ name ="idle", start=1, count=1, time=100000 },
	{ name ="smallLoad", start=2, count=1, time=100000},
	{ name ="bigLoad", start=3, count=1, time=100000}
}

--ENEMY ANIM PARTS
local enemySpriteParams = 
{
	width = 148,
	height = 227,
	numFrames = 2,
	sheetContentWidth = 296,
	sheetContentHeight = 227,
}
local enemySheet = graphics.newImageSheet( "images/enemy.png", enemySpriteParams )
local enemyAnimationData = {
	{ name ="idle", start=1, count=1, time=400 },
	{ name ="steal", start=2, count=1, time=400 }
}


------------------------------------------------------------------------------
-- Create Scene is called once
------------------------------------------------------------------------------
function scene:createScene(event)

	--NON SCROLLING ELEMENTS
	--
    sky = display.newImageRect("images/bg.png",900,1425)
	sky.anchorX = 0
	sky.anchorY = 1
	sky.x = 0
	sky.y = display.contentHeight
	sky.speed = 4
	staticGroupSky:insert(sky)
	self.view:insert(staticGroupSky)

	--CLOUDS
	--
	clouds = display.newImageRect('images/clouds.png',920,360)
	clouds.anchorX = 0
	clouds.anchorY = 1
	clouds.x = 0
	clouds.y = display.viewableContentHeight -110
	clouds.speed = 2
	scrollGroupClouds:insert(clouds)

	clouds2 = display.newImageRect('images/clouds2.png',920,360)
	clouds2.anchorX = 0
	clouds2.anchorY = 1
	clouds2.x = clouds2.width
	clouds2.y = display.viewableContentHeight -110
	clouds2.speed = 2
	scrollGroupClouds:insert(clouds2)
	self.view:insert(scrollGroupClouds)

	--CREATE THE GROUND
	scrollingGround = display.newImageRect('images/platform.png',900,53)
	scrollingGround.anchorX = 0
	scrollingGround.anchorY = 1
	scrollingGround.x = 0
	scrollingGround.y = display.viewableContentHeight - 110
	physics.addBody(scrollingGround, "static", {density=.1, bounce=0.0, friction=frictionFlower})
	scrollingGround.speed = 14
	scrollingGround.collisionID = "ground"
	scrollGroupGround:insert(scrollingGround)

	scrollingGround2 = display.newImageRect('images/platform.png',900,53)
	scrollingGround2.anchorX = 0
	scrollingGround2.anchorY = 1
	scrollingGround2.x = scrollingGround2.width
	scrollingGround2.y = display.viewableContentHeight - 110
	physics.addBody(scrollingGround2, "static", {density=.1, bounce=0.0, friction=frictionFlower})
	scrollingGround2.speed = 14
	scrollingGround2.collisionID = "ground"
	scrollGroupGround:insert(scrollingGround2)

end

------------------------------------------------------------------------------
-- Moving objects & timers
------------------------------------------------------------------------------
--This set of functions controls the (randomized) appearance of flower pots on the stage
function addFlowerTimer()
	addFlowerCharacterTimer = timer.performWithDelay(random(500,1600), addFlowerCharacter)
end

function addFlowerCharacter()

	local heightOffset = math.random(flowerHeightLowest, flowerHeightHighest)

	flowerPot = display.newImageRect('images/flowerPot.png',240,520)
	flowerPot.anchorX = 0
	flowerPot.anchorY = 0
	flowerPot.x = display.contentWidth + 100
	flowerPot.y = display.contentHeight - heightOffset
	flowerPot.collisionID = "flowerPot"
	physics.addBody(flowerPot, "static", {density=1, bounce=bounceFlower, friction=frictionFlower, shape=shapeFlowerPot})
	flowers:insert(flowerPot)


	flowerFace = display.newSprite( flowerFaceSheet, flowerAnimationData )
	flowerFace.anchorX = 0
	flowerFace.anchorY = 0
	flowerFace.x = flowerPot.x - 10
	flowerFace.y = flowerPot.y - 252
	flowerFace.collisionID = "flowerFace"
	physics.addBody(flowerFace, "static", {density=1, bounce=bounceFlower, friction=frictionFlower, shape=shapeFlowerFace})
	flowers:insert(flowerFace)
	flowerFace:setSequence("idle")
	flowerFace:play()

	addFlowerTimer()
end

function addBeeHiveTimer()
	addHiveTimer = timer.performWithDelay(random(minHiveWait,maxHiveWait), addBeeHive)
end

function addBeeHive()
	local height = 0
	beeHive = display.newSprite( beeHiveSheet, beeHiveAnimationData)
	beeHive.anchorX = 0.5
	beeHive.anchorY = 0
	beeHive.x = display.contentWidth + 200
	beeHive.y = height
	beeHive.collisionID = "beehive"
	physics.addBody(beeHive, "static", {density=1, bounce=0, friction=frictionFlower, shape=shapeBeehive})
	beehives:insert(beeHive)
	beeHive:setSequence("idle")
	beeHive:play()

	addBeeHiveTimer()
end


function addEnemyBeeTimer()
	addEnemyBeeSpawnTimer = timer.performWithDelay(random(minEnemyWait,maxEnemyWait), addEnemyBee)
end

function addEnemyBee()
	local heightOffset = math.random(enemyHeightHighest, enemyHeightLowest)
	enemyBee = display.newSprite (enemySheet, enemyAnimationData)
	enemyBee.anchorX = 0.5
	enemyBee.anchorY = 0
	enemyBee.x = display.contentWidth + 100
	enemyBee.y = heightOffset
	enemyBee.collisionID = "enemyBee"
	physics.addBody(enemyBee, "static", {density=1, bounce=3, friction=50, shape=shapeEnemyBee})
	enemyBees:insert(enemyBee)
	enemyBee:setSequence("idle")
	enemyBee:play()

	addEnemyBeeTimer()
end

------------------------------------------------------------------------------
-- COLLISION HANDLING
------------------------------------------------------------------------------ 
function preCollisionPlayer(self, event)
	--objects in preCollision are here because they need to be "pass through" to the player

	--turn off collision on touched flowers
	if (event.other.collisionID == "touchedFlowerFace") then
		event.contact.isEnabled = false
	elseif (event.other.collisionID == "beehive") then
	--make delivery and turn off collision on beehive immediately
		event.contact.isEnabled = false
		if (player:getBeeFat() > 0) then
			firstDelivery = true
			hiveDelivery(self, event)
		end
	elseif (event.other.collisionID == "enemyBee") then
	--turn off collision on enemy bees and run logic
		event.contact.isEnabled = false
		if (player:getBeeFat() > 0) then
			player:resetBeeThin()
			enemyBee:setSequence("steal")
			enemyBee:play()
		end
	end

	return true
end



function postCollisionPlayer(self, event)
	--postCollision has access to force, where we can check the player's speed and add points accordingly
	if (event.other.collisionID == "flowerFace") then
		successfulFlowerImpact(self, event) 
	elseif (event.other.collisionID == "ground") then
		event.other.collisionID = "touchedGround"
		timer.performWithDelay(5, endGame())
	end
	return true
end


------------------------------------------------------------------------------
-- GAMEPLAY LOGIC EVENTS
------------------------------------------------------------------------------

function flowerTouchedListener(event)
	if (event.phase == "ended") then
		local thisSprite = event.target
		thisSprite:setSequence("touched")
		thisSprite:play()
	end
end


function flowerBounceNoCollectListener(event)
	if (event.phase == "ended") then
		local thisSprite = event.target
		thisSprite:setSequence("idle")
		thisSprite:play()
	end
end


function successfulFlowerImpact(self, event) 
	event.other.collisionID = "touchedFlowerFace"

    if (player:getBeeFat() < 5) then
    	event.other:setSequence("bounceCollect")
		event.other:addEventListener("sprite", flowerTouchedListener)
	    event.other:play()
	    pollen = Pollen:new(pollens, event.other.x + event.other.width * .5, event.other.y + event.other.height * .5 + 30)

	    --update bee gravity vars, commented out now for simplicity while migrating to a class based bee
	    --gravityVar = gravityVar + 10
	    --physics.setGravity( 0, gravityVar)

	    score:updateCurrentScore(1)
	    player:addBeeFat(1)
	    player:scaleBeeUp()


	    oneupPlusOne = Oneup:new('score_1',player:getBeeX(),player:getBeeY(),newGameGroup)
		--transition.to(scorePlusOne, {time=1000, alpha=0, y=scorePlusOne.y - 50, x=scorePlusOne.x - 150})

	else
		--bee is at maximum capacity 
		event.other:setSequence("bounceNoCollect")
		event.other:addEventListener("sprite", flowerBounceNoCollectListener)
		event.other:play()

		full = Oneup:new('full',player:getBeeX(),player:getBeeY(),newGameGroup)
		makeDeliveryReminder()
	end
end


function makeDeliveryReminder()
		if (makeDeliveryReminderFlag == false) then
			makeDelivery = display.newImageRect('images/make_delivery.png',460,447)
			makeDelivery.anchorX = .5
			makeDelivery.anchorY = .5
			makeDelivery.x = display.viewableContentWidth / 2
			makeDelivery.y = display.viewableContentHeight / 2
			newGameGroup:insert(makeDelivery)
			transition.to(makeDelivery, {time=1500, alpha=0, y=500})
			makeDeliveryReminderFlag = true
		end
end



function hiveDelivery (self, event)
	--if bee has honey to give, take honey, reset it to zero, set bee to thin, turn off collision on hive
	deliveryScoreAndOneUp(player:getBeeFat()) --display multipler one-up text based on size of delivery
	print ("already touched this hive spam")
	--handles graphical change to hive
	if (player:getBeeFat() < 4) then 
		event.other:setSequence("smallLoad")
		event.other:play()
	elseif (player:getBeeFat() >= 4) then 
		event.other:setSequence("bigLoad")
		event.other:play()
	end
	player:resetBeeThin()
end


------------------------------------------------------------------------------
-- ONE UP TEXt
------------------------------------------------------------------------------
function deliveryScoreAndOneUp(multiplier)

	local oneupX = display.viewableContentWidth / 3
	local oneupY = display.viewableContentHeight / 3

	if (multiplier == 5) then
		score:updateCurrentScore(50)
		oneup5 = Oneup:new('oneup_5',oneupX,oneupY,newGameGroup)
	elseif (multiplier == 4) then
		score:updateCurrentScore(25)
		oneup4 = Oneup:new('oneup_4',oneupX,oneupY,newGameGroup)
	elseif (multiplier == 3) then
		score:updateCurrentScore(15)
		oneup3 = Oneup:new('oneup_3',oneupX,oneupY,newGameGroup)
	elseif (multiplier == 2) then
		score:updateCurrentScore(10)
		oneup2 = Oneup:new('oneup_2',oneupX,oneupY,newGameGroup)
	elseif (multiplier == 1) then
		score:updateCurrentScore(5)
		oneup1 = Oneup:new('oneup_1',oneupX,oneupY,newGameGroup)
	end
end



------------------------------------------------------------------------------
-- PLAYER MOVEMENTS
------------------------------------------------------------------------------

function flyUp(event)
	player:tap()
end

-- function rotateBee()
-- 	player:rotate()
-- end


------------------------------------------------------------------------------
-- MOVE AND SCROLL THINGS
------------------------------------------------------------------------------
--TODO: These could probably be combined into one grand "move everything" function, but remember that the ground moves on the first screen and the flower pots / hives do not
function groundScroller(self,event)
	--this moves the ground
	if (groundShouldBeMoving == true) then
		if self.x < (-900 + (self.speed*2)) then
			self.x = 900
		else 
			self.x = self.x - scrollObjectSpeed
		end
	end
end

function cloudScroller(self,event)
	--this moves the clouds
	if (groundShouldBeMoving == true) then
		if self.x < (-900 + (self.speed*2)) then
			self.x = 900
		else 
			self.x = self.x - scrollCloudSpeed
		end
	end
end


function moveStageObjects()
	if (gameActive == true) then
		--print ("moving stage objects check passed")

		--move the beehives
		for a = beehives.numChildren,1,-1  do
			if(beehives[a].x > -200) then 
				beehives[a].x = beehives[a].x - scrollObjectSpeed -- move them 12 left
			else 
				beehives:remove(beehives[a]) --otherwise remove the flower from the array
			end	
		end

		--move the flowers
		for a = flowers.numChildren,1,-1  do
			if(flowers[a].x > -300) then -- if flowers aren't off the left side of the screen yet
				flowers[a].x = flowers[a].x - scrollObjectSpeed -- move them 12 left
				--print ("flower x when destroyed ", flowers[a].x)
			else 
				flowers:remove(flowers[a]) --otherwise remove the flower from the array
			end	
		end

		--move the pollens
		for a = pollens.numChildren,1,-1  do
			transition.to(pollens[a], {time = 400, delay=0, alpha=0})
			if(pollens[a].x > -200) then -- if flowers aren't off the left side of the screen yet
				pollens[a].x = pollens[a].x - scrollObjectSpeed -- move them 12 left
			else 
				flowers:remove(pollens[a]) --otherwise remove the flower from the array
			end	
		end

		for a = enemyBees.numChildren,1,-1 do
			if(enemyBees[a].x > -200) then -- if flowers aren't off the left side of the screen yet
				enemyBees[a].x = enemyBees[a].x - scrollEnemyBeeSpeed -- move them 12 left
			else 
				enemyBees:remove(enemyBee[a]) --otherwise remove the flower from the array
			end	
		
		end	

		--check if the player fell off the far left of the screen
		if (player:getBeeX() < display.contentCenterX - 550) then --TODO this should probably go somewhere else besides move flowers
			print ("end game")
			endGame()
		end
	end 
end


local function checkMemory()
   collectgarbage( "collect" )
   local memUsage_str = string.format( "MEMORY = %.3f KB", collectgarbage( "count" ) )

   	if (memoryUsageText == true) then
		print( memUsage_str, "TEXTURE = "..(system.getInfo("textureMemoryUsed") / (1024 * 1024) ) )
   	end
   
end

------------------------------------------------------------------------------
-- GAME BEGIN AND GAME END
------------------------------------------------------------------------------
function startGame()
	gameActive = true
	initVars()
	player:startGame() -- tell player instance to do its start game function
	start:removeSelf()
	titleScreenGroup:removeSelf()

	score:showScoreText()
	Runtime:addEventListener("touch", flyUp)
 
	--Begin moving elements
	addFlowerTimer()
	addBeeHiveTimer()
	print ("enemy bees is set to:", enemyBees)
	if (enemyBeesOn == true) then
		addEnemyBeeTimer()
	end
	moveStageObjectsTimer = timer.performWithDelay(2, moveStageObjects, -1)
end

function endGame()
	Runtime:removeEventListener("enterFrame", myListener)
	player:removeBeePhysics() -- can't call removeBody while still crunching physics FUCK YOU CORONA AND YOUR CHEAP ASS DEVS
	score:hideScoreText()
	gameActive = false
	collisionDone = false --wtf is this?
	groundShouldBeMoving = false
	storyboard.showOverlay( "restart", endGameOptions)
end

------------------------------------------------------------------------------
-- ENTER SCENE
------------------------------------------------------------------------------
function scene:enterScene(event)
	scrollGroupGameObjects = display.newGroup()
	groundShouldBeMoving = true

	--Create title & start button
	titleScreenGroup = display.newGroup() -- this display group must be recreated in enterScene, since it gets destroyed later on
	title = display.newImageRect("images/title.png",453,128)
	title.anchorX = 0.5
	title.anchorY = 0.5
	title.x = display.contentCenterX
	title.y = display.contentCenterY - 250
	titleScreenGroup:insert(title)

	start = display.newImageRect("images/start_btn.png",420,140)
	start.anchorX = 0.5
	start.anchorY = 1
	start.x = display.contentCenterX
	start.y = display.contentHeight - 300
	titleScreenGroup:insert(start)

	start:addEventListener("touch", startGame)
	self.view:insert(titleScreenGroup)

   	--CREATE DISPLAY GROUPS FOR PLAYER INTERACTABLE GAME OBJECTS
   	--
    beehives = display.newGroup()
	beehives.anchorChildren = true
	beehives.anchorX = 0
	beehives.anchorY = 1
	beehives.x = 0
	beehives.y = 0
	scrollGroupGameObjects:insert(beehives)

	flowers = display.newGroup()
	flowers.anchorChildren = true
	flowers.anchorX = 0
	flowers.anchorY = 1
	flowers.x = 0
	flowers.y = 0
	scrollGroupGameObjects:insert(flowers)
	
	pollens = display.newGroup()
	pollens.anchorChildren = true
	pollens.anchorX = 0
	pollens.anchorY = 1
	pollens.x = 0
	pollens.y = 0
	scrollGroupGameObjects:insert(pollens)

	enemyBees = display.newGroup()
	enemyBees.anchorChildren = true
	enemyBees.anchorX = 0
	enemyBees.anchorY = 1
	enemyBees.x = 0
	enemyBees.y = 0
	scrollGroupGameObjects:insert(enemyBees)

	--put these things into scrollGroupGameObjects 
	self.view:insert(scrollGroupGameObjects) 
	
	--Scroll the ground
	scrollingGround.enterFrame = groundScroller
	scrollingGround2.enterFrame = groundScroller
	Runtime:addEventListener("enterFrame", scrollingGround)
	Runtime:addEventListener("enterFrame", scrollingGround2)

	ground = display.newImageRect('images/ground.png',900,162)
	ground.anchorX = 0
	ground.anchorY = 1
	ground.x = 0
	ground.y = display.contentHeight + 50
	scrollGroupGround:insert(ground)
	self.view:insert(scrollGroupGround)

	--scroll the clouds
	clouds.enterFrame = cloudScroller
	clouds2.enterFrame = cloudScroller
	Runtime:addEventListener("enterFrame", clouds)
	Runtime:addEventListener("enterFrame", clouds2)


	player = Player:new(beeGroup, 100,100) -- instantiate player
	self.view:insert(beeGroup)  -- add to beeGroup
	
	Runtime:addEventListener("enterFrame", myListener) --add event listener "enterFrame" to player

   	memTimer = timer.performWithDelay( 1000, checkMemory, 0 )

	score = Score:new(0)
	score:createScoreText(newGameGroup) 
	self.view:insert(newGameGroup) --put the text field into newGameGroup and then put newGameGroup into self.view 
end

--for some bullshit reason, this has to be a standalone function
function myListener (event)
	player:rotate()
end

function scene:exitScene(event)
	--removing a display group removes its children

	player:removeBee() -- prevents a second bee from lingering on the stage
	beehives:removeSelf() -- makes no difference if on or off ??
	scrollGroupGameObjects:removeSelf()
	ground:removeSelf()
	score:removeScoreText()
	
end

function scene:overlayBegan(event)
	--remove player event listeners
	Runtime:removeEventListener("enterFrame",myListener) -- line 696
	player:removeListeners()
	
	Runtime:removeEventListener("enterFrame", scrollingGround)
	Runtime:removeEventListener("enterFrame", scrollingGround2)
	Runtime:removeEventListener("enterFrame", clouds)
	Runtime:removeEventListener("enterFrame", clouds2)
	Runtime:removeEventListener("touch", flyUp)
	timer.cancel(addFlowerCharacterTimer)
	timer.cancel(addHiveTimer)
	timer.cancel(moveStageObjectsTimer) 
	timer.cancel(memTimer)

	if (enemyBeesOn == true) then
		timer.cancel(addEnemyBeeSpawnTimer)
	end
end

function scene:destroyScene(checkMemory)
end

scene:addEventListener("createScene", scene)
scene:addEventListener("enterScene", scene)
scene:addEventListener("exitScene", scene)
scene:addEventListener("destroyScene", scene)
scene:addEventListener("overlayBegan", scene)

return scene













