
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local physics = require("physics")
physics.start()
physics.setGravity(0, 0)


local score = 0
local backSpeed = 2
local died = false
local passed = false
local shakeMagnitude = 20-- Adjust the magnitude of the shake effect
local shakeDuration = 0.5 -- Adjust the duration of the shake effect
local shakeX, shakeY = 0, 0 -- Initialize the shake offsets
local obstacleTable = {}
local hearts = {}
local triangleSpaceShip = { 0, -50, 50, 50, -50, 50 }
local scaleFactor = display.contentHeight / 960  -- Calculate the scaling factor based on the screen height


--Variables
local astrokid
local currentPositionX
local currentPositionY
local xOfShip
local yOfShip
local newObstacle
local gameLoopTimer
local obstacleTimer
local obstacleTimer2
local scoreTimer
local scoreText
local back1
local back2
local back3
local rightBoundary
local leftBoundary
local rightButton
local leftButton
local gameOver

--Initialized Variables
local heartSize = 40
local heartSpacing = 1
local maxHearts = 4
local startX = display.contentWidth - 315
local startY = display.contentHeight - 25
local currentHearts = maxHearts
local heartImage = "Pixel Art/Heart.png"
local livesText
local invincibleDuration = 3000
local invincibleAlpha = 0.75
local isInvincible = false
local scaleFactor = display.contentHeight / 960  -- Calculate the scaling factor based on the screen height

--Groups
local backGroup 
local mainGroup
local uiGroup


--Functions


local function shakeScreen()
    local shakeCount = 5 -- Number of shake iterations
    local shakeDelay = 50 -- Delay between each shake iteration (in milliseconds)
    local shakeMagnitude = 10 -- Maximum magnitude of shake offsets


    local function performShake()
        -- Generate random shake offsets
        local shakeX = math.random(-shakeMagnitude, shakeMagnitude)
        local shakeY = math.random(-shakeMagnitude, shakeMagnitude)


        -- Disable physics temporarily
        physics.pause()
        if obstacleTimer then
              timer.pause(obstacleTimer)
          end
        if obstacleTimer2 then
            timer.pause(obstacleTimer2)
        end




        -- Apply shake offsets to the screen
        display.currentStage.x = shakeX
        display.currentStage.y = shakeY


        -- Reset screen position after shake duration
        timer.performWithDelay(shakeDuration * 1000, function()
            display.currentStage.x = 0
            display.currentStage.y = 0


            -- Resume physics after the shake is complete
            physics.start()
            physicsPaused = false
            if obstacleTimer then
             timer.resume(obstacleTimer)
            end
            if obstacleTimer2 then
              timer.resume(obstacleTimer2)
            end
        end)
    end


    -- Perform multiple shake iterations
    for i = 1, shakeCount do
        timer.performWithDelay((i - 1) * shakeDelay, performShake)
    end
end


local function storeCoordinates()
	if astrokid.isVisible then
	   currentPositionX = astrokid.x
	   currentPositionY = astrokid.y
	elseif not astrokid.isVisible then
	   xOfShip = currentPositionX
	   yOfShip = currentPositionY
	end
end
  


local function loadExplosion()
    local currentIndex = 1  -- Current frame index
    local frameCount = 11  -- Total number of frames


    local function loadNextFrame()
        if (currentIndex <= frameCount) then
            local indexString = tostring(currentIndex)  -- Convert the index to a string
            local explosion = display.newImageRect(mainGroup, "Animations/Explosion/Frame " .. indexString .. ".png", 160, 160)
            explosion.x = currentPositionX
            explosion.y = currentPositionY


            local function hideFire()
                display.remove(explosion)
                explosion = nil
                currentIndex = currentIndex + 1  -- Move to the next frame


                loadNextFrame()  -- Load the next frame
            end


            explosion.isVisible = true  -- Show the explosion object
            local frameRate = 98 -- Frame rate in milliseconds
            timer.performWithDelay(frameRate, hideFire)  -- Start the timer to hide the explosion object
        end
    end


    loadNextFrame()  -- Start loading the frames
end


local function moveBackground()
    back1.y = back1.y - backSpeed
    back2.y = back2.y - backSpeed
    back3.y = back3.y - backSpeed


    if back1.y < -back1.contentHeight * 0.5 then
        back1.y = back3.y + back1.contentHeight
    end
    if back2.y < -back2.contentHeight * 0.5 then
        back2.y = back1.y + back2.contentHeight
    end
    if back3.y < -back3.contentHeight * 0.5 then
        back3.y = back2.y + back3.contentHeight
    end
end



local function scoreIncrementer()
	score = score + 50
	scoreText.text = "Score: " .. score
end




local function createObstacle()
    newObstacle = display.newImageRect(mainGroup, "Pixel Art/Asteroid.png", 120, 120)
    table.insert(obstacleTable, newObstacle)


    physics.addBody(newObstacle, "dynamic", { radius = 50 })
    newObstacle.myName = "I am your death!"


    local whereFrom = math.random(3)


    if whereFrom == 1 then
        newObstacle.x = 205
    elseif whereFrom == 2 then
        newObstacle.x = display.contentCenterX
    elseif whereFrom == 3 then
        newObstacle.x = 550
    end


    newObstacle.y = 1000
    newObstacle:applyTorque( math.random( -6,6 ) )
    newObstacle:setLinearVelocity(0, -400)
end



local function onRightButton(event)
	local rightButton = event.target
	local phase = event.phase


	if ("began" == phase) then
	  display.currentStage:setFocus(rightButton)
	  rightButton.xScale = 0.95
	  rightButton.yScale = 0.95
	  transition.to(astrokid, {time = 100, x = astrokid.x + 166})
	elseif ("moved" == phase) then
	  rightButton.xScale = 0.95
	  rightButton.yScale = 0.95
	elseif ("ended" == phase or "cancelled" == phase) then
	  display.currentStage:setFocus(nil)
	  rightButton.xScale = 1
	  rightButton.yScale = 1
	end


	return true
end




local function onLeftButton(event)
	local leftButton = event.target
	local phase = event.phase


	if ("began" == phase) then
	  display.currentStage:setFocus(leftButton)
	  leftButton.xScale = 0.95
	  leftButton.yScale = 0.95
	  transition.to(astrokid, {time = 100, x = astrokid.x - 166})
	elseif ("ended" == phase or "cancelled" == phase) then
	  display.currentStage:setFocus(nil)
	  leftButton.xScale = 1
	  leftButton.yScale = 1
	end


	return true
end




local function endGame()

    timer.cancel(scoreTimer)
	timer.cancel(obstacleTimer)
	timer.cancel(obstacleTimer2)
    display.remove( scoreText )


    gameOver = display.newImageRect("Pixel Art/gameOver.png", 200, 100)
    gameOver.x = display.contentCenterX
    gameOver.y = display.contentCenterY
    gameOver.alpha = 0
    display.currentStage:insert(gameOver)
    -- Display the final score and game over sign
    scoreText = display.newText(uiGroup, " Final Score: " .. score, display.contentCenterX, display.contentCenterY - 200, "text fonts/ka1.ttf", 30)
    scoreText.x = display.contentCenterX
    scoreText.y = display.contentCenterY + 55
    scoreText.alpha = 0
    transition.to( gameOver, { time  = 1500, alpha = 1 })
    transition.to( scoreText, { time = 1500, alpha = 1 })
	timer.performWithDelay(3000, function()
		composer.gotoScene("menu", { time = 3000, effect = "crossFade" })
	end)
	
end




local function invincible()
	isInvincible = true
	astrokid.alpha = invincibleAlpha
	physics.removeBody( astrokid )
  
  
	-- After the invincible duration, restore the astrokid's original opacity and re-enable collisions
	timer.performWithDelay(invincibleDuration, function()
	  if astrokid.isVisible == true then
		  isInvincible = false
		  astrokid.alpha = 1
		  physics.addBody(astrokid, "static", { shape = triangleSpaceShip })
	  end
	end)
  end
  




--to remove a life from the spaceship when it has hit a 'certain' object
local function removeHeart()
    if currentHearts > 0 then
        hearts[currentHearts].isVisible = false
        currentHearts = currentHearts - 1
    end
    if currentHearts == 0 then
      died = true
      display.remove(leftButton)
      display.remove(rightButton)
      shakeScreen()
      local removeTimer = timer.performWithDelay(1000, function() display.remove( astrokid ) end)
      local explosionTimer =  timer.performWithDelay( 1050, loadExplosion, 1 )
      local endingTimer = timer.performWithDelay( 2000, endGame, 1 )
      for i = #obstacleTable, 1, -1 do
         if obstacleTable[i] == obj1 or obstacleTable[i] == obj2 then
            display.remove( obstacleTable[i] )
            table.remove(obstacleTable, i)
            break
         end
      end
    end
end




local function checkMate()
	if score >= 600 and not died then
	  newObstacle = display.newImageRect(mainGroup, "Pixel Art/Asteroid.png", 120, 120)
	  table.insert(obstacleTable, newObstacle)
  
  
	  physics.addBody(newObstacle, "dynamic", { radius = 50 })
	  newObstacle.myName = "I am your death!"
  
  
	  local whereFrom = math.random(3)
  
  
	  if whereFrom == 1 then
		  newObstacle.x = 205
	  elseif whereFrom == 2 then
		  newObstacle.x = display.contentCenterX
	  elseif whereFrom == 3 then
		  newObstacle.x = 550
	  end
  
  
	  newObstacle.y = 1000
	  newObstacle:applyTorque( math.random( -6,6 ) )
	end
end


local function onCollision(event)
	if event.phase == "began" then
	  local obj1 = event.object1
	  local obj2 = event.object2
  
  
	  if (obj1.myName == "John1298" and obj2.myName == "I am your death!") or
		  (obj1.myName == "I am your death!" and obj2.myName == "John1298") then
		timer.performWithDelay(0.5, function()
		  if astrokid.isVisible == true then
			shakeScreen()
			removeHeart()
			invincible()
  
  
			for i = #obstacleTable, 1, -1 do
			  if obstacleTable[i] == obj1 or obstacleTable[i] == obj2 then
				display.remove( obstacleTable[i] )
				table.remove(obstacleTable, i)
				break
			  end
			end
		  end
		end)
	  elseif (obj1.myName == "John1298" and obj2.myName == "No trespassing!") or
		  (obj1.myName == "No trespassing!" and obj2.myName == "John1298") then
		timer.performWithDelay(0.5, function()
			  for i = 1,currentHearts do
				  display.remove( hearts[i] )
			  end
			  died = true
			  display.remove(leftButton)
			  display.remove(rightButton)
			  shakeScreen()
			  removeTimer = timer.performWithDelay(1000, function() display.remove( astrokid ) end)
			  endingTimer = timer.performWithDelay( 1500, endGame, 1 )
			  for i = #obstacleTable, 1, -1 do
				 if obstacleTable[i] == obj1 or obstacleTable[i] == obj2 then
					display.remove( obstacleTable[i] )
					table.remove(obstacleTable, i)
					break
				 end
			  end
		end)
	  elseif (obj1.myName == "John1298" and obj2.myName == "No trespassing 2!") or
		  (obj1.myName == "No trespassing 2!" and obj2.myName == "John1298") then
			timer.performWithDelay(0.5, function()
				  for i = 1,currentHearts do
					  display.remove( hearts[i] )
				  end
				  died = true
				  display.remove(leftButton)
				  display.remove(rightButton)
				  shakeScreen()
				  removeTimer = timer.performWithDelay(1000, function() display.remove( astrokid ) end)
				  endingTimer = timer.performWithDelay( 1500, endGame, 1 )
				  for i = #obstacleTable, 1, -1 do
					 if obstacleTable[i] == obj1 or obstacleTable[i] == obj2 then
						display.remove( obstacleTable[i] )
						table.remove(obstacleTable, i)
						break
					 end
				  end
			end)
	  end
	end
end


local function thisIsIt()
	if score >= 600 and not died then
	  timer.cancel( obstacleTimer )
	end
end

  

local function cutscene()
   local animationDone2 = false
   timer.pause( obstacleTimer )
   timer.pause( obstacleTimer2 )
   timer.pause( scoreTimer )
   transition.to( astrokid, { time = 3000, y = 130, onComplete = function()


        for i = 1, maxHearts do
          transition.to(hearts[i], { time = 1000, alpha = 1})
        end


        transition.to(scoreText, { time = 1000, alpha = 1})


        transition.to( rightBoundary, { time = 1000, alpha = 1 } )
        transition.to( leftBoundary, { time = 1000, alpha = 1 } )


        transition.to(rightButton, { time = 1500, alpha = 1, onComplete = function ()
          if ( rightButton.alpha == 1 ) then
            rightButton:addEventListener("touch", onRightButton)
          end
        end})


        transition.to(leftButton, { time = 1500, alpha = 1, onComplete = function ()
          if ( leftButton.alpha == 1 ) then
            leftButton:addEventListener("touch", onLeftButton)
          end
        end})


        animationDone2 = true
        if animationDone2 == true then
          timer.resume( obstacleTimer )
          timer.resume( obstacleTimer2 )
          timer.resume( scoreTimer )
        end
    end})
end



local function gameLoop()


    for i = #obstacleTable, 1, -1 do
        local thisObstacle = obstacleTable[i]


        if thisObstacle.isVisible and score >= 600 and not died then
            backSpeed = 4
            thisObstacle:setLinearVelocity(0, -650)
        end


        if thisObstacle.y < -50 then
            display.remove(thisObstacle)
            table.remove(obstacleTable, i)
        end
    end
end




local function levelComplete()
	if ( score == 1000 ) and ( died == false ) then
	  timer.cancel( obstacleTimer2 )
	  timer.cancel( scoreTimer )
	  astrokid.isSensor = true -- Set astrokid as a sensor to disable collisions temporarily
	  transition.to( rightBoundary, { time  = 1000, alpha = 0} )
	  transition.to( leftBoundary, { time  = 1000, alpha = 0} )
	  timer.performWithDelay(4000, function()
		composer.gotoScene("menu", { time = 3000, effect = "crossFade" })
	end)
	end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	physics.pause()  -- Temporarily pause the physics engine

	backGroup = display.newGroup()
	sceneGroup:insert( backGroup )  -- Insert into the scene's view group

    mainGroup = display.newGroup()
	sceneGroup:insert( mainGroup )  -- Insert into the scene's view group

    uiGroup = display.newGroup()
	sceneGroup:insert( uiGroup )  -- Insert into the scene's view group


	-- Set up the background images
	back1 = display.newImageRect(backGroup, "Background Art/level1Back.png", 768*scaleFactor, 1400*scaleFactor)
	back1.x = display.contentCenterX
	back1.y = display.contentCenterY


	back2 = display.newImageRect(backGroup, "Background Art/level1Back.png", 768*scaleFactor, 1400*scaleFactor)
	back2.x = display.contentCenterX
	back2.y = back1.y + 480 * scaleFactor


	back3 = display.newImageRect(backGroup, "Background Art/level1Back.png", 768*scaleFactor, 1400*scaleFactor)
	back3.x = display.contentCenterX
	back3.y = back2.y + 480 * scaleFactor

    
	--the main hero
	astrokid = display.newImage(mainGroup, "Pixel Art/Space Ship.png", 100, 100)
	astrokid.x = display.contentCenterX
	astrokid.y = -40
	astrokid.myName = "John1298"
	physics.addBody(astrokid, "dynamic", { shape = triangleSpaceShip, isSensor = true })
	astrokid:rotate(180)


	--create the left boundary
	rightBoundary = display.newRect(mainGroup, 788, 15, 80, 2000)
	rightBoundary:setFillColor(0.3, 0.2, 0.5)
	rightBoundary.myName = "No trespassing 2!"
	rightBoundary.alpha = 0
	physics.addBody(rightBoundary, "static", { isSensor = true })


	--create the left boundary
	leftBoundary = display.newRect(mainGroup, -20, 15, 80, 2000)
	leftBoundary:setFillColor(0.3, 0.2, 0.5)
	leftBoundary.myName = "No trespassing!"
	leftBoundary.alpha = 0
	physics.addBody(leftBoundary, "static", { isSensor = true })

    
	--create the right button
	rightButton = display.newImageRect(uiGroup, "Pixel Art/Right Button.png", 256, 160)
	rightButton.x = 560
	rightButton.y = 900
	rightButton.alpha = 0

    
	--create the left button
	leftButton = display.newImageRect(uiGroup, "Pixel Art/Left Button.png", 256, 160)
	leftButton.x = 205
	leftButton.y = 900
	leftButton.alpha = 0

    
	--create the hearts
	for i = 1, maxHearts do
	hearts[i] = display.newImageRect(uiGroup, heartImage, heartSize, 35)
	hearts[i].alpha = 0
	hearts[i].x = startX + (i - 1) * (heartSize + heartSpacing)
	hearts[i].y = startY
	end

 
	--create the score text
	scoreText = display.newText(uiGroup, "Score: " .. score, 260, 60, "text fonts/ka1.ttf", 28)
	scoreText.alpha = 0


end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		physics.start()
		Runtime:addEventListener("collision", onCollision)
		Runtime:addEventListener("enterFrame", storeCoordinates)
		Runtime:addEventListener("enterFrame", moveBackground)
		Runtime:addEventListener("enterFrame", thisIsIt)
		Runtime:addEventListener("enterFrame", gameLoop)
		Runtime:addEventListener("enterFrame", levelComplete)
		scoreTimer = timer.performWithDelay( 3000, scoreIncrementer, 0 )
		obstacleTimer = timer.performWithDelay(900, createObstacle, 0)
		obstacleTimer2 = timer.performWithDelay( 750, checkMate, 0 )
		local cutsceneTimer = timer.performWithDelay( 0, cutscene, 1 )


	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		physics.pause()
		Runtime:removeEventListener("collision", onCollision)
		Runtime:removeEventListener("enterFrame", storeCoordinates)
		Runtime:removeEventListener("enterFrame", moveBackground)
		Runtime:removeEventListener("enterFrame", thisIsIt)
		Runtime:removeEventListener("enterFrame", gameLoop)
		Runtime:removeEventListener("enterFrame", levelComplete)
		composer.removeScene("Level1")
		print("Everything has successfully been removed, Sir..")

	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
