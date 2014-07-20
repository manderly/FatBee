-- requires 
local physics = require "physics"
physics.start()
local mydata = require( "mydata" )

local storyboard = require ("storyboard")
local scene = storyboard.newScene()

local player 

local startGamePressed = false
-------------------------------------------------------------------------------------

function startGame(event)
     if event.phase == "ended" then
     	if (startGamePressed == false ) then
     		startGamePressed = true
			storyboard.gotoScene("game")
		end 
     end
end

function groundScroller(self,event)
	
	if self.x < (-900 + (self.speed*2)) then
		self.x = 900
	else 
		self.x = self.x - self.speed
	end
	
end


function titleTransitionDown()
	downTransition = transition.to(titleGroup,{time=400, y=titleGroup.y+20,onComplete=titleTransitionUp})
	
end

function titleTransitionUp()
	upTransition = transition.to(titleGroup,{time=400, y=titleGroup.y-20, onComplete=titleTransitionDown})
	
end

function titleAnimation()
	titleTransitionDown()
end

-------------------------------------------------------------------------------------

function scene:createScene(event)

	local screenGroup = self.view

	background = display.newImageRect("images/bg.png",900,1425)
	background.anchorX = 0.5
	background.anchorY = 1
	background.x = display.contentCenterX
	background.y = display.contentHeight
	screenGroup:insert(background)
	
	title = display.newImageRect("images/title.png",367,100)
	title.anchorX = 0.5
	title.anchorY = 0.5
	title.x = display.contentCenterX - 30
	title.y = display.contentCenterY 
	screenGroup:insert(title)
	
	platform = display.newImageRect('images/platform.png',900,53)
	platform.anchorX = 0
	platform.anchorY = 1
	platform.x = 0
	platform.y = display.viewableContentHeight - 110
	physics.addBody(platform, "static", {density=.1, bounce=0.1, friction=.2})
	platform.speed = 14
	screenGroup:insert(platform)

	platform2 = display.newImageRect('images/platform.png',900,53)
	platform2.anchorX = 0
	platform2.anchorY = 1
	platform2.x = platform2.width
	platform2.y = display.viewableContentHeight - 110
	physics.addBody(platform2, "static", {density=.1, bounce=0.1, friction=.2})
	platform2.speed = 14
	screenGroup:insert(platform2)
	
	start = display.newImageRect("images/start_btn.png",300,65)
	start.anchorX = 0.5
	start.anchorY = 1
	start.x = display.contentCenterX
	start.y = display.contentHeight - 400
	screenGroup:insert(start)
	
	p_options = 
	{
		-- Required params
		width = 202,
		height = 162,
		numFrames = 2,
		-- content scaling
		sheetContentWidth = 404,
		sheetContentHeight = 162,
	}

	playerSheet = graphics.newImageSheet( "images/bee.png", p_options )
	player = display.newSprite( playerSheet, { name="player", start=1, count=2, time=500 } )
	player.anchorX = 0.5
	player.anchorY = 0.5
	player.x = display.contentCenterX
	player.y = display.contentCenterY
	physics.addBody(player, "static", {density=.1, bounce=0.05, friction=1})
	player:applyForce(0, startBeePopup, player.x, player.y)
	player:play()
	screenGroup:insert(player)
	
	titleGroup = display.newGroup()
	titleGroup.anchorChildren = true
	titleGroup.anchorX = 0.5
	titleGroup.anchorY = 0.5
	titleGroup.x = display.contentCenterX
	titleGroup.y = display.contentCenterY - 250
	titleGroup:insert(title)
	screenGroup:insert(titleGroup)
	titleAnimation()

end


function scene:enterScene(event)
	storyboard.removeScene("game")
	start:addEventListener("touch", startGame)
	platform.enterFrame = groundScroller
	Runtime:addEventListener("enterFrame", platform)
	platform2.enterFrame = groundScroller
	Runtime:addEventListener("enterFrame", platform2)

end

function scene:exitScene(event)

	start:removeEventListener("touch", startGame)
	Runtime:removeEventListener("enterFrame", platform)
	Runtime:removeEventListener("enterFrame", platform2)
	transition.cancel(downTransition)
	transition.cancel(upTransition)
	
end

function scene:destroyScene(event)

end


scene:addEventListener("createScene", scene)
scene:addEventListener("enterScene", scene)
scene:addEventListener("exitScene", scene)
scene:addEventListener("destroyScene", scene)

return scene













