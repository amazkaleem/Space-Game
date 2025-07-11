
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local function gotoLevel2()
    composer.gotoScene( "Level2", { time=800, effect="crossFade" } )
end

local function gotToGame()
	composer.gotoScene( "Cutscene1", { time=800, effect="crossFade" } )
end
 
local function gotoHowToPlay()
    composer.gotoScene( "HowToPlay", { time=800, effect="crossFade" } )
end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	local customFont = native.newFont( "text fonts/ka1.ttf", 20 )

	local title = display.newImageRect(sceneGroup, "Pixel Art/MainTitle(Final).png", 640, 128)
	title.x = display.contentCenterX
	title.y = display.contentHeight - 800
	
	local BlackHole = display.newImageRect(sceneGroup, "Pixel Art/Black Core.png", 100, 100)
	BlackHole.x = display.contentCenterX
	BlackHole.y = display.contentCenterY + 10
	
	local playButton = display.newText( sceneGroup, "Play", display.contentCenterX, display.contentCenterY + 100, customFont, 50 )
	local Level2Button = display.newText( sceneGroup, "Level2", display.contentCenterX, display.contentCenterY + 200, customFont, 50 )
	local howToPlayButton = display.newText( sceneGroup, "How To Play", display.contentCenterX, display.contentCenterY + 300, customFont, 50 )

	playButton:addEventListener( "tap", gotToGame )
	Level2Button:addEventListener( "tap", gotoLevel2 )
	howToPlayButton:addEventListener( "tap", gotoHowToPlay )

end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

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
