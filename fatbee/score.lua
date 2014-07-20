--This is the Score
--When game.lua needs to manipulate the player's score, it uses this class

--not sure if these are essential
local class = require 'middleclass'
local Score = class('Score')

local path = system.pathForFile("scorefile.txt",system.DocumentsDirectory)

   

function Score:initialize()
	self.currentScore = 0
	self.bestScore = 0
end


function Score:createScoreText (newGameGroup)
	--create the score's on-screen text field
	self.scoreText = display.newText(self.currentScore,display.contentCenterX,150, "Arial", 58)
	self.scoreText:setFillColor(0,0,0)
	self.scoreText.alpha = 0
	
	--insert into display group
	newGameGroup:insert(self.scoreText)
end


function Score:resetCurrentScoreVar() --not sure if needed, maybe initialize again?
	self.currentScore = 0
end

function Score:updateCurrentScore(pointsEarned)
	--update both the var and the text field. these never occur separately 
	self.currentScore = self.currentScore + pointsEarned
	self.scoreText.text = self.currentScore
end

function Score:getCurrentScore()
	return self.currentScore
end


function Score:showScoreText()
	self.scoreText.alpha = 100
end


function Score:hideScoreText()
	self.scoreText.alpha = 0
end

function Score:removeScoreText()
	self.scoreText:removeSelf()
end



function Score:compareScore()
	local prevScore = self:getSavedScore() -- pull the saved score out of the data file
	if (prevScore ~= nil) then -- if it's not nil then compare it to the new current score
		if (prevScore <= self.currentScore) then --if the previous score is less than the current score
			self:setBestScore(self.currentScore) --update the saved score with the new current score and save it
			self:save()
		else 
			self:setBestScore(prevScore) --previous score is not less than the current score
			--wouldn't it be cleaner to just do nothing here? does the old score have to be re-entered like this?
		end
	else --previou score is nil, just take the current score and save it
		self:setBestScore(self.currentScore)
		self:save()
	end

end

--self means save it to the instance, make sure the instance has it

function Score:setBestScore(saveThisData)
	self.bestScore = saveThisData -- set best score to match current score
end


function Score:getSavedScore()
	--local score = tostring(load())
	--return score
	return self:load() or 0
end

function Score:save()
    local file = io.open(path, "w")
    if file then
        local contents = tostring( self.bestScore )
        file:write( contents )
        io.close( file )
        return true
    else
    	print("Error: could not read ", self.filename, ".")
        return false
    end
end

function Score:load()
	print ("calling LOAD")
    local contents = ""
    local file = io.open( path, "r" )
    if file then
    	print ("Contents of ".. path .. "\n" .. contents )
         -- read all contents of file into a string
         local contents = file:read( "*a" )
         local score = tonumber(contents);
         io.close( file )
         return score
    end
    print("Could not read scores from ", self.filename, ".")
    return nil
end

return Score
