-- requires 


local storyboard = require ("storyboard")
local scene = storyboard.newScene()
local Score = require("score")

local roundsPlayed = 0

function restartGame(event)
     if event.phase == "ended" then
     --player is restarting game, check if it's time to show the advertisement
		if (roundsPlayed >= 3) then
			print ("SHOW ADVERTISEMENT")
			roundsPlayed = 0
			storyboard.hideOverlay("restart")
			storyboard.showOverlay("advertisement")
		else
	     	storyboard.hideOverlay("restart")
			storyboard.reloadScene()
		end 
     end
end


function showGameOver()
	roundsPlayed = roundsPlayed + 1
	print ("Rounds Played", roundsPlayed)
	fadeTransition = transition.to(gameOver,{time=300, alpha=1,onComplete=showScore})
end


function showScore()
	scoreTransition = transition.to(scoreBg,{time=500, y=display.contentCenterY,onComplete=showStart})
	
end

function showStart()
	restartTransition = transition.to(restart,{time=600, alpha=1})
	shareTransition = transition.to(share,{time=600, alpha=1})
	scoreTextTransition = transition.to(scoreText,{time=400, alpha=1})
	scoreTextTransition = transition.to(bestText,{time=400, alpha=1})
	--print ("SAVED BEST SCORE from score.get is", score.get())
	--print ("CURRENT ROUND SCORE from score.get is", mydata.score)
	-- if (score:getCurrentScore() > score:getSavedScore) then
	-- 	newHighScoreTransition = transition.to(newHighScore,{time=400, alpha=1})
	-- end
	score:compareScore()
end

-- function saveScore()
-- 	score.save()
-- end

function scene:createScene(event)

	local screenGroup = self.view

	gameOver = display.newImageRect("images/gameOver.png",500,100)
	gameOver.anchorX = 0.5
	gameOver.anchorY = 0.5
	gameOver.x = display.contentCenterX 
	gameOver.y = display.contentCenterY - 400
	gameOver.alpha = 0
	screenGroup:insert(gameOver)
	
	scoreBg = display.newImageRect("images/menuBg.png",500,292)
	scoreBg.anchorX = 0.5
	scoreBg.anchorY = 0.5
    scoreBg.x = display.contentCenterX
    scoreBg.y = display.contentHeight + 300 -- puts it off screen 
    screenGroup:insert(scoreBg)
	
	restart = display.newImageRect("images/restart_btn.png",283,96)
	restart.anchorX = 0.5
	restart.anchorY = 1
	restart.x = display.contentCenterX - 180
	restart.y = display.contentCenterY + 400
	restart.alpha = 0
	screenGroup:insert(restart)

	share = display.newImageRect("images/share_btn.png",283,96)
	share.anchorX = 0.5
	share.anchorY = 1
	share.x = display.contentCenterX + 180
	share.y = display.contentCenterY + 400
	share.alpha = 0
	screenGroup:insert(share)

	newHighScore = display.newImageRect("images/new_high_score.png",437,69)
	newHighScore.anchorX = 0.5
	newHighScore.anchorY = 1
	newHighScore.alpha = 0
	newHighScore.x = display.contentCenterX
	newHighScore.y = display.contentCenterY + 120
	screenGroup:insert(newHighScore)
	
	scoreText = display.newText(score:getCurrentScore(),display.contentCenterX - 110,display.contentCenterY - 20, native.systemFont, 70)
	scoreText:setFillColor(0,0,0)
	scoreText.alpha = 0 
	screenGroup:insert(scoreText)


	bestTextDisplay = display.newText ({
		text = score:getSavedScore(),
		fontSize = 70,
		font = "Helvetica",
		x = display.contentCenterX + 80,
		y = display.contentCenterY - 20,
		--maxDigits = 3,
		--leadingZeros = false,
		--filename = "scorefile.txt",
		})
	
	bestTextDisplay.alpha = 0
	bestTextDisplay:setFillColor(0,0,0)
	screenGroup:insert(bestTextDisplay)


	--banner ad placeholder
	bannerAd = display.newImageRect("images/ad_banner.png",640,100)
	bannerAd.anchorX = 0.5
	bannerAd.anchorY = 1
	bannerAd.x = display.contentCenterX
	bannerAd.y = display.contentHeight - 10
	bannerAd.alpha = 1
	screenGroup:insert(bannerAd)
	
end

function scene:enterScene(event)
	restart:addEventListener("touch", restartGame)
	share:addEventListener("touch", restartGame)
	showGameOver()
end

function scene:exitScene(event)
	restart:removeEventListener("touch", restartGame)
	transition.cancel(fadeTransition)
	transition.cancel(scoreTransition)
	transition.cancel(scoreTextTransition)
	transition.cancel(restartTransition)
	transition.cancel(shareTransition)
end

function scene:destroyScene(event)

end


scene:addEventListener("createScene", scene)
scene:addEventListener("enterScene", scene)
scene:addEventListener("exitScene", scene)
scene:addEventListener("destroyScene", scene)

return scene













