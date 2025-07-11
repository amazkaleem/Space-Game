
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local textGroup


local cutsceneFinish = false


local poem = {
  "Sailing through the cosmic sea,",
  "a ship so brave and free,",
  "Its crew unaware of the imminent mystery,",
  "Guided by the stars, they ventured on their quest,",
  "To chart the uncharted,",
  "to put the unknown to the test,",
  " ",
  "But as fate would have it, their course took a turn,",
  "A black hole emerged, a cosmic fire to burn,",
  "With swirling depths, it beckoned them near,",
  "A portal to darkness, to what lay unclear,",
  " ",
  "The ship hesitated, its crew filled with awe,",
  "An abyss of shadows, a gravitational draw,",
}


local customFont


local function loadText()
    local yOfText = 350
    local transitionTime = 5000
    local fadeOutTime = 15000


    for index = 1, #poem, 1 do
        local text = display.newText(textGroup, poem[index], display.contentCenterX, yOfText, customFont, 18)
        text.alpha = 0
        text.y = yOfText
        yOfText = yOfText + 30


        transition.to(text, { time = transitionTime, alpha = 1, onComplete = function()
            timer.performWithDelay(fadeOutTime, function()
                transition.to(text, { time = transitionTime, alpha = 0, onComplete = function()
                    text:removeSelf()
					composer.gotoScene( "Level1", { time=800, effect="crossFade" } )
                end })
            end)
        end })
    end
    cutsceneFinish = true
    print(cutsceneFinish)
end


local function checkSpaceshipPosition()
    if not cutsceneFinish then
        loadText()
    end
end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

    textGroup = display.newGroup()
	sceneGroup:insert(textGroup)

	customFont = native.newFont("text fonts/November.ttf", 15)



end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		Runtime:addEventListener("enterFrame", checkSpaceshipPosition)

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
		Runtime:addEventListener("enterFrame", checkSpaceshipPosition)
		composer.removeScene( "Cutscene1" )

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
