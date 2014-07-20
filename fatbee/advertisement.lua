-- requires 


local storyboard = require ("storyboard")
local scene = storyboard.newScene()
local mydata = require( "mydata" )
local score = require( "score" )

function dismissAd(event)
     if event.phase == "ended" then
     	--player is exiting the advertisement
     	storyboard.hideOverlay("advertisement")
		storyboard.reloadScene()
     end
end

function showAdFadeIn()
	startTransition = transition.to(ad,{time=200, alpha=1})
end

function scene:createScene(event)

	local screenGroup = self.view

	ad = display.newImageRect("images/ad_ph.png",700,900)
	ad.anchorX = 0.5
	ad.anchorY = 0.5
	ad.x = display.contentCenterX 
	ad.y = display.contentCenterY
	ad.alpha = 0
	screenGroup:insert(ad)
end


function scene:enterScene(event)
	showAdFadeIn()
	ad:addEventListener("touch", dismissAd)
end

function scene:exitScene(event)
	ad:removeEventListener("touch", restartGame)
end

function scene:destroyScene(event)

end


scene:addEventListener("createScene", scene)
scene:addEventListener("enterScene", scene)
scene:addEventListener("exitScene", scene)
scene:addEventListener("destroyScene", scene)

return scene













