-----------------------------------------------------------------------------------------
--
-- end.lua
-- Copyright 2016 Flynn Tesoriero
-- https://github.com/flynntes
-- https://flynntes.com
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "widget" library
local widget = require "widget"

-- include Corona's "physics" library
local physics = require "physics"

--------------------------------------------

local w,h = display.contentWidth, display.contentHeight

local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX


-- forward declarations and other locals
local playBtn

-- 'onRelease' event listener for playBtn
local function onPlayBtnRelease()
	
	-- go to level.lua scene
	composer.gotoScene( "level", "fade", 500 )
	
	return true	-- indicates successful touch
end

function scene:create( event )
	local sceneGroup = self.view

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	-- display a background image
	local background = display.newImageRect( "assets/bg.png", display.actualContentWidth, display.actualContentHeight )
	background.anchorX = 0
	background.anchorY = 0
	background.x = 0 + display.screenOriginX 
	background.y = 0 + display.screenOriginY
	
	-- create/position logo/title image on upper-half of the screen
	local titleLogo = display.newImageRect( "assets/logo.png", 640, 432 )
	titleLogo.x = display.contentCenterX
	titleLogo.y = 220

	local function titleAnimation()
		local animUp = function()
			transition.to(titleLogo, { time=3000, y=220, alpha=0.7, rotation=-8 })
			transition.to(titleLogo, { time=3000, y=220, alpha=0.7, rotation=-2, onComplete=titleAnimation })
		end

		transition.to(titleLogo, { time=1500, y=230, alpha=1, rotation=8, onComplete=animUp })
	end

	titleAnimation()
	
	local copyText = display.newText( '© 2016 flynntes.com', 100, h/1.015, native.systemFont, 20 )

	local finalTime = display.newText( 'Time: '..timeCount, screenW/2, screenH/2, native.systemFontBold, 60 )
		--finalTime.anchorX = 0
		--finalTime.anchorY = 0
		finalTime:setFillColor( 0.62549019607843, 0.13333333333333, 1 )

	if (timeCount > bestTime) then
		bestTime = timeCount
	end
	
	-- create a widget button (which will loads level.lua on release)
	playBtn = widget.newButton{
		defaultFile="assets/button.png",
		overFile="assets/button.png",
		width=400, height=123,
		onRelease = onPlayBtnRelease	-- event listener function
	}
	playBtn.x = display.contentCenterX
	playBtn.y = 720
	
	-- all display objects must be inserted into group
	sceneGroup:insert( background )
	sceneGroup:insert( titleLogo )
	sceneGroup:insert( playBtn )
	sceneGroup:insert( copyText )
	sceneGroup:insert( finalTime )
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
		composer.removeScene("level"); 
		display.remove( healthBar ) ; healthBar = nil
	end	
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end	
end

function scene:destroy( event )
	local sceneGroup = self.view
	
	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.

	if playBtn then
		playBtn:removeSelf()	-- widgets must be manually removed
		playBtn = nil
	end
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene