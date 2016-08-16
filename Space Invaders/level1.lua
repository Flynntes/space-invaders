-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "physics" library
local physics = require "physics"

--------------------------------------------

-- forward declarations and other locals
local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX

function scene:create( event )

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	local sceneGroup = self.view

	-- We need physics started to add bodies, but we don't want the simulaton
	-- running until the scene is on the screen.
	physics.start()
	physics.pause()


	-- create a grey rectangle as the backdrop
	-- the physical screen will likely be a different shape than our defined content area
	-- since we are going to position the background from it's top, left corner, draw the
	-- background at the real top, left corner.
	local background = display.newImageRect( "assets/lvl_bg.png", display.actualContentWidth, display.actualContentHeight )
	background.anchorX = 0
	background.anchorY = 0
	background.x = 0 + display.screenOriginX 
	background.y = 0 + display.screenOriginY

	--HEALTH
	health = 100

	local healthText = display.newText( health, 45, 30, native.systemFont, 40 )

	--PLAYER
	-- Creates and returns a new player.
    local function createPlayer( x, y, width, height, rotation )
        local p = display.newImage( "assets/player.png", x, y )
        p.rotation = rotation
        p.width = 140
        p.height = 168
        p.myName = "player"
        physics.addBody( p, "static" )

        return p
    end

    local player = createPlayer( display.viewableContentWidth / 2, display.viewableContentHeight / 1.2, 1, 100, 0 )

    local function onTouch( event )
        if "began" == event.phase then
            player.isFocus = true

            player.x0 = event.x - player.x
            
        elseif player.isFocus then
            if "moved" == event.phase then
            	posx = event.x - player.x0
            	if (posx <= 0) then
            		posx = 0
            	elseif (posx >= 640) then
            		posx = 640
            	end
                player.x = posx
            elseif "ended" == phase or "cancelled" == phase then
                player.isFocus = false
            end
        end

        -- Return true if the touch event has been handled.
        return true
    end

    -- Only the background receives touches. 
    background:addEventListener( "touch", onTouch)

    --ROCKS
    local numberrocks = 5 --local variable; amount can be changed
 
	local function clearrock( thisrock )
	   display.remove( thisrock ) ; thisrock = nil
	end

	local function spawnrocks()

	   for i=1,numberrocks do
	      local rock = display.newImageRect("assets/rock_1.png", 90, 90);
	      -- rock:setReferencePoint(display.CenterReferencePoint);  --not necessary; center is default
	      x = math.random(30, 600);
	      y = math.random(-1000,0);
	      rock.x = x
	      rock.y = y
	      rock.myName = "rock"
	      transition.to( rock, { time=math.random(10000,15000), x=x , y=1200, onComplete=clearrock } );
	      physics.addBody( rock, { density=1.0, friction=0.3, bounce=0.3 } );

	      --Adding touch event
	      --rock:addEventListener( "touch", touchrock );
	   end

	end

	spawnrocks()

	local function onGlobalCollision( event )

	    if ( event.phase == "began" ) then
	        --print( "began: " .. event.object1.myName .. " and " .. event.object2.myName )
	        if ( event.object1.myName == "player" ) then
	        	if ( event.object2.myName == "rock" ) then
		        	print("Player hit rock")
		        	health = health - 1
		        	healthText.text = health
		        	event.object2.myName = "rock_hit"
		        end
	        end

	    elseif ( event.phase == "ended" ) then
	        --print( "ended: " .. event.object1.myName .. " and " .. event.object2.myName )
	    end
	end

	Runtime:addEventListener( "collision", onGlobalCollision )

	timer.performWithDelay( 7000, spawnrocks, 0 )  --fire every 10 seconds

	--LASER
	local function clearLaser( thislaser )
	   display.remove( thislaser ) ; thislaser = nil
	end

	local function shootLaser()
		local laser = display.newImageRect("assets/beam.png", 90, 90);
		laser.x = player.x
		laser.y = display.viewableContentHeight / 1.2
		transition.to( laser, { time=1000, x=player.x , y=-100, onComplete=clearLaser } );
		physics.addBody( laser, "static" )
	end

	timer.performWithDelay( 200, shootLaser, 0 )  --fire every 10 seconds

	-- all display objects must be inserted into group
	sceneGroup:insert( background )
	--sceneGroup:insert( floor)
	--sceneGroup:insert( crate )
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
		physics.start()
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
		physics.stop()
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end	
	
end

function scene:destroy( event )

	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	local sceneGroup = self.view
	
	package.loaded[physics] = nil
	physics = nil
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene