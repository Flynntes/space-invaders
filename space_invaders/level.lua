-----------------------------------------------------------------------------------------
--
-- level.lua
-- Copyright 2016 Flynn Tesoriero
-- https://github.com/flynntes
-- https://flynntes.com
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "physics" library
local physics = require "physics"

-- include Corona's "widget" library
local widget = require "widget"

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

	-- Level music
	levelMusic = audio.loadStream("assets/music_3.mp3")

	-- Hit sound
	hitSound = audio.loadSound( "assets/hit.wav" )

	-- Background image
	local background = display.newImageRect( "assets/lvl_bg.png", display.actualContentWidth, display.actualContentHeight )
	background.anchorX = 0
	background.anchorY = 0
	background.x = 0 + display.screenOriginX 
	background.y = 0 + display.screenOriginY
	sceneGroup:insert( background )

	----------------
	--GLOBAL TIMER--
	----------------

	timeCount = 0

	local timeText = display.newText( 'Time: '..timeCount, 0, 0, native.systemFont, 30 )
	timeText.anchorX = 0
	timeText.anchorY = 0
	timeText:setFillColor( 0.62549019607843, 0.13333333333333, 1 )

	local bestTime = display.newText( 'Best time: '..bestTime, 640, 35, native.systemFont, 30 )
	bestTime.anchorX = 1
	bestTime.anchorY = 1
	bestTime:setFillColor( 0.62549019607843, 0.13333333333333, 1 )

	-- Increase rock and enemy count as game goes on
	function counter()
		timeCount = timeCount + 1
		timeText.text = 'Time: '..timeCount

		if (timeCount > 20) then
			numberrocks = 10
		elseif (timeCount > 40) then
			numberrocks = 15
		elseif (timeCount > 60) then
			numberrocks = 20
		end

		if (timeCount > 20) then
			numberenemies = 3
		elseif (timeCount > 40) then
			numberenemies = 5
		elseif (timeCount > 60) then
			numberenemies = 7
		end
	end


	----------
	--HEALTH--
	----------

	health = 100

	healthBarWidth = health*6.4

	local healthText = display.newText( 'Health', 3, screenH-55, native.systemFont, 30 )
	healthText.anchorX = 0
	healthText.anchorY = 0
	healthText:setFillColor( 0.62549019607843, 0.13333333333333, 1 )

	healthBar = display.newRect( 0, 1116, healthBarWidth, 20 )
	healthBar.anchorX = 0
	healthBar.anchorY = 0
	healthBar:setFillColor( 0.62549019607843, 0.13333333333333, 1, 0.5 )
	

	local function healthCheck() --Check if health has run out
		if (health <= 0) then
			composer.gotoScene( "end", "fade", 500 )
		end
	end

	sceneGroup:insert( healthBar )


	----------
	--PLAYER--
	----------

	-- Creates and returns a new player.
    local function createPlayer( x, y, width, height, rotation )
    	local p = display.newImage( "assets/player.png", x, y )
    	local pOutline = graphics.newOutline( 1, "assets/player.png" )
        p.rotation = rotation
        p.width = 140
        p.height = 168
        p.myName = "player"
        local shape = { 0,-80, 75, 50, -75, 50 }
        physics.addBody( p, "static", {shape=shape} )

        return p
    end

    local player = createPlayer( display.viewableContentWidth / 2, display.viewableContentHeight / 1.2, 1, 100, 0 )

    -- Move player
    local function onTouch( event )
        if "began" == event.phase then
            player.isFocus = true

            player.x0 = event.x - player.x

        elseif player.isFocus then
            if "moved" == event.phase then
            	posx = event.x - player.x0
            	if (posx <= 80) then
            		posx = 80
            	elseif (posx >= 560) then
            		posx = 560
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


    -----------
    --ENEMIES--
    -----------

    local numberenemies = 2 --local variable; amount can be changed

    local function clearenemy( thisenemy )
	   display.remove( thisenemy ) ; thisenemy = nil
	end

	enemyGroup = display.newGroup()

	function spawnenemies()
		for i=1,numberenemies do
			enemy = display.newImageRect("assets/enemy_1.png", 90, 90);
			x = math.random(30, 600);
			y = math.random(-1000,0);
			enemy.x = x
			enemy.y = y
			enemy.myName = "enemy"
			enemyGroup:insert( enemy )
			transition.to( enemy, { time=math.random(14000,20000), x=x , y=screenH+100, onComplete=clearenemy})	
			physics.addBody( enemy, { density=1.0, friction=0.3, bounce=0.3 } );
			enemy.isFixedRotation = true
	    end
	end

	spawnenemies()


	---------
    --ROCKS--
    ---------

    local numberrocks = 5 --local variable; amount can be changed
 
	local function clearrock( thisrock )
	   display.remove( thisrock ) ; thisrock = nil
	end

	rockGroup = display.newGroup()

	function spawnrocks()

	   for i=1,numberrocks do
	      rock = display.newImageRect("assets/rock_2.png", 90, 90);
	      x = math.random(30, 600);
	      y = math.random(-1000,0);
	      rock.x = x
	      rock.y = y
	      rock.myName = "rock"
	      rockGroup:insert( rock )
	      transition.to( rock, { time=math.random(10000,15000), x=x , y=1200, onComplete=clearrock } );
	      physics.addBody( rock, { density=1.0, friction=0.3, bounce=0.3 } );
	      rock.isFixedRotation = true

	      --Adding touch event
	      --rock:addEventListener( "touch", touchrock );
	   end

	   for i=1,numberrocks do
	      local rock = display.newImageRect("assets/rock_1.png", 90, 90);
	      x = math.random(30, 600);
	      y = math.random(-1000,0);
	      rock.x = x
	      rock.y = y
	      rock.myName = "rock"
	      rockGroup:insert( rock )
	      transition.to( rock, { time=math.random(10000,15000), x=x , y=1200, onComplete=clearrock } );
	      physics.addBody( rock, { density=1.0, friction=0.3, bounce=0.3 } );
	      rock.isFixedRotation = true

	      --Adding touch event
	      --rock:addEventListener( "touch", touchrock );
	   end

	end

	spawnrocks()


	---------
	--LASER--
	---------

	function clearLaser( thislaser )
	   display.remove( thislaser ) ; thislaser = nil
	end

	function shootLaser()
		local laser = display.newImageRect("assets/beam.png", 90, 90);
		sceneGroup:insert( laser ) --Insert into scene group
		player:toFront() --Keep player on top
		laser.x = player.x
		laser.y = display.viewableContentHeight / 1.2
		laser.myName = "laser"
		transition.to( laser, { time=1000, x=player.x , y=80, alpha=0.6, onComplete=clearLaser } );
		physics.addBody( laser, "static" )
	end


	--------------
	--ANIMATIONS--
	--------------

	local function playHitAnimation()

		transition.to( player, { time=100, xScale=1.1, yScale=1.1, onComplete=
            function()
                transition.to( player, {time=100, xScale=1, yScale=1})
            end
    	})

	end

	function rockExplodeAnimation(rock_target, laser_target)
		playLaserSound = audio.play( hitSound, { channel=0, fadein=300 } )
		display.remove( laser_target ) ; laser_target = nil
		transition.to( rock_target, { time=200, xScale=3, yScale=3, alpha=0, onComplete=
            function()
                display.remove( rock_target ) ; rock_target = nil
            end
    	})
	end

	local function enemyExplodeAnimation(enemy_target, laser_target)
		display.remove( laser_target ) ; laser_target = nil
		transition.to( enemy_target, { time=200, xScale=3, yScale=3, alpha=0, onComplete=
            function()
                display.remove( enemy_target ) ; enemy_target = nil
            end
    	})
	end

	local function playDamangeAnimation()

		transition.to( player, { time=100, alpha=0, onComplete=
            function()
                transition.to( player, {time=100,  alpha=1})
            end
    	})
    	
	end


	--------------
	--COLLISIONS--
	--------------

	function onGlobalCollision( event )

	    if ( event.phase == "began" ) then
	        if ( event.object1.myName == "player" ) then
	        	if ( event.object2.myName == "rock" ) then
		        	health = health - 10
		        	print(health)
		        	print(healthBar)
		        	healthBar.width = health*6.4
		        	--healthBar:setFillColor( 0.62549019607843, 0.13333333333333, health/100, 0.5 )
		        	event.object2.myName = "rock_hit"
		        	transition.to( event.object2, { time=200, xScale=3, yScale=3, onComplete=
			            function()
			                display.remove( event.object2 ) ; event.object2 = nil
			            end
			    	})
		        	playDamangeAnimation()
		    		healthCheck()
		        elseif ( event.object2.myName == "enemy" ) then
		        	health = health - 20
		        	print(health)
		        	print(healthBar)
		        	healthBar.width = health*6.4
		        	--healthBar:setFillColor( 0.62549019607843, 0.13333333333333, health/100, 0.5 )
		        	event.object2.myName = "rock_hit"
		        	transition.to( event.object2, { time=200, xScale=3, yScale=3, onComplete=
			            function()
			                display.remove( event.object2 ) ; event.object2 = nil
			            end
			    	})
		        	playDamangeAnimation()
		    		healthCheck()
		        end
	        end

	        if ( event.object1.myName == "rock" ) then
	        	if ( event.object2.myName == "laser" ) then
		        	--print("Laser hit rock")
		        	rockExplodeAnimation(event.object1, event.object2)
		        end
	       	elseif ( event.object1.myName == "laser" ) then
	        	if ( event.object2.myName == "rock" ) then
		        	--print("Laser hit rock")
		        	rockExplodeAnimation(event.object2, event.object1)
		        end
	        end

	    elseif ( event.phase == "ended" ) then
	        --print( "ended: " .. event.object1.myName .. " and " .. event.object2.myName )
	    end
	end

	Runtime:addEventListener( "collision", onGlobalCollision )


	-- all display objects must be inserted into group
	
	sceneGroup:insert( healthText )
	sceneGroup:insert( timeText )
	sceneGroup:insert( player )
	sceneGroup:insert( bestTime )

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

		-- Start timers
		laserTimer = timer.performWithDelay( 700, shootLaser, 0 )
		spawnRocksTimer = timer.performWithDelay( 7000, spawnrocks, 0 )
		spawnEnemyTimer = timer.performWithDelay( 7000, spawnenemies, 0 )
		globalCounter = timer.performWithDelay( 1000, counter, 0 )

		-- Play music
		levelMusicPlay = audio.play( levelMusic, { channel=1, loops=-1, fadein=500 } )

		composer.removeScene("end"); 

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

		display.remove( player ) ; player = nil -- Remove the player

		for i = 1, rockGroup.numChildren do -- Loop through all the rocks and remove them
		   	local child = rockGroup[i]
			display.remove( child ) ; child = nil
		end

		for i = 1, enemyGroup.numChildren do -- Loop through all the enemies and remove them
		   	local child = enemyGroup[i]
			display.remove( child ) ; child = nil
		end

		-- Stop transitions
		transition.cancel()

		-- Remove display items
		display.remove( laser )
		display.remove( enemy )
		display.remove( rock ) ; rock = nil

		enemy:removeSelf();
    	enemy = nil;

		physics.setGravity( 0, 99999 )

		-- Cancel timers, stop movement
		timer.cancel( laserTimer )
		timer.cancel( spawnRocksTimer )
		timer.cancel( spawnEnemyTimer )
		timer.cancel( globalCounter )

		-- Clean up vars
		shootLaser = nil

		spawnrocks = nil

		audio.stop( playLaserSound ) -- Make sure the laser sound is stopped
		playLaserSound = nil

		audio.dispose( hitSound ) -- Clean up hit sound
		hitSound = nil

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