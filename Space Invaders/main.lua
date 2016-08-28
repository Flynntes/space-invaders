-----------------------------------------------------------------------------------------
--
-- main.lua
-- Copyright 2016 Flynn Tesoriero
-- https://github.com/flynntes
-- https://flynntes.com
--
-----------------------------------------------------------------------------------------

-- hide the status bar
display.setStatusBar( display.HiddenStatusBar )

-- include the Corona "composer" module
local composer = require "composer"

-- load menu screen
composer.gotoScene( "menu" )