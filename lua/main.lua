----------------------------------------------------------------
-- Copyright (c) 2010-2011 Zipline Games, Inc. 
-- All Rights Reserved. 
-- http://getmoai.com
----------------------------------------------------------------

require 'game'

screenWidth = MOAIEnvironment.horizontalResolution
screenHeight = MOAIEnvironment.verticalResolution
if screenWidth == nil then screenWidth = 320 end
if screenHeight == nil then screenHeight = 480 end

ROWS = 6
COLS = 8

--MOAISim.openWindow ( "test", WIDTH, HEIGHT )
--moai.logger:debug("" .. MOAIEnvironment.screenWidth .. " " .. MOAIEnvironment.screenHeight)
MOAISim.openWindow ("test", screenWidth, screenHeight)

viewport = MOAIViewport.new ()
viewport:setSize ( screenWidth, screenHeight )
viewport:setScale ( COLS, -ROWS )
--viewport:setOffset(-math.floor(COLS / 2), -math.floor(ROWS / 2))
viewport:setOffset(-1, 1) -- origin at top left
layer = MOAILayer2D.new ()
layer:setViewport ( viewport )
MOAISim.pushRenderPass ( layer )

--[[function onDraw()
    MOAIGfxDevice.setPenColor ( 1, 0, 0, 1 )
    MOAIGfxDevice.setPenWidth ( 2 )
    MOAIDraw.fillRect(1,1,3,3)
end

scriptDeck = MOAIScriptDeck.new ()
scriptDeck:setRect ( -4, -4, 4, 4 )
scriptDeck:setDrawCallback ( onDraw )]]

resources = {}
resources[MOUSE] = 'mouse.png'
resources[CHEESE] = 'cheese.png'
resources[BANANA] = 'banana.png'
resources[ORANGE] = 'orange.png'
resources[GRAPE] = 'grape.png'
resources[EMPTY] = 'empty.png'

gfx = {}
for id, fname in pairs(resources) do
    gfx[id] = MOAIGfxQuad2D.new()
    gfx[id]:setTexture (fname)
    gfx[id]:setRect (-1, -1, 0, 0)
    gfx[id]:setUVRect ( 0, 0, 1, 1 ) -- landscape textures
end

--gfxQuad:setRect ( 0, 0, 1, 1 )
--gfxQuad:setUVRect ( 0, 1, 1, 0 ) -- landscape textures

--[[prop = MOAIProp2D.new ()
prop:setDeck ( gfxQuad )
prop:setLoc(1.7, 1.7)
layer:insertProp ( prop )
prop:moveRot ( 360, 1.5 )]]

function drawBoard()
    tiles = {}
    layer:clear()
    for y=1, ROWS do
        col = {}
        for x=1, COLS do
            tile = MOAIProp2D.new ()
            local what = board[x][y]
            tile:setDeck ( gfx[what] )
            tile:setLoc(x, y)
            layer:insertProp (tile)
            table.insert(col, tile)
        end
        table.insert(tiles, col)
    end
end

function init()
    board = Board:new(COLS, ROWS)
    board:fill_random()
    board[1][1] = MOUSE
    board[COLS][ROWS] = CHEESE
    drawBoard()
end


init()

MOAIInputMgr.device.touch:setCallback (
    function ( eventType, idx, sx, sy, tapCount )
        if eventType ~= MOAITouchSensor.TOUCH_UP then
            return
        end
        x, y = layer:wndToWorld(sx, sy)
        x, y = math.ceil(x), math.ceil(y)
        if board:is_legal(x, y) then
            board:eat(x, y)
            drawBoard()
        end
    end
)

