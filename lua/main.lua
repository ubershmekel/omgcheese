----------------------------------------------------------------
-- Copyright (c) 2010-2011 Zipline Games, Inc. 
-- All Rights Reserved. 
-- http://getmoai.com
----------------------------------------------------------------

require 'game'
require 'particle'

screenWidth = MOAIEnvironment.horizontalResolution
screenHeight = MOAIEnvironment.verticalResolution
if screenWidth == nil then screenWidth = 800 end
if screenHeight == nil then screenHeight = 480 end

ROWS = 9
COLS = 16

function getGfx(fname)
    local quad = MOAIGfxQuad2D.new()
    quad:setTexture (fname)
    quad:setRect (-1, -1, 0, 0)
    quad:setUVRect ( 0, 0, 1, 1 ) -- landscape textures
    return quad
end

--MOAISim.openWindow ( "test", WIDTH, HEIGHT )
--moai.logger:debug("" .. MOAIEnvironment.screenWidth .. " " .. MOAIEnvironment.screenHeight)
MOAISim.openWindow ("test", screenWidth, screenHeight)

viewport = MOAIViewport.new ()
viewport:setSize ( screenWidth, screenHeight )
viewport:setScale ( COLS, -ROWS )
--viewport:setOffset(-math.floor(COLS / 2), -math.floor(ROWS / 2))
viewport:setOffset(-1, 1) -- origin at top left

bgLayer = MOAILayer2D.new ()
bgLayer:setViewport ( viewport )
MOAISim.pushRenderPass ( bgLayer )

highlightsLayer = MOAILayer2D.new ()
highlightsLayer:setViewport ( viewport )
MOAISim.pushRenderPass ( highlightsLayer )

tilesLayer = MOAILayer2D.new ()
tilesLayer:setViewport ( viewport )
MOAISim.pushRenderPass ( tilesLayer )

fgLayer = MOAILayer2D.new ()
fgLayer:setViewport ( viewport )
MOAISim.pushRenderPass ( fgLayer )

--MOAIGfxDevice.setClearColor(0.58, 0.81, 0.98, 1)

--[[function onDraw()
    MOAIGfxDevice.setPenColor ( 1, 0, 0, 1 )
    MOAIGfxDevice.setPenWidth ( 2 )
    MOAIDraw.fillRect(1,1,3,3)
end

scriptDeck = MOAIScriptDeck.new ()
scriptDeck:setRect ( -4, -4, 4, 4 )
scriptDeck:setDrawCallback ( onDraw )]]

resources = {}
resources[MOUSE] = 'gopher.png'
resources[CHEESE] = 'cheese.png'
resources[BANANA] = 'banana.png'
resources[ORANGE] = 'orange.png'
resources[GRAPE] = 'grape.png'
resources[EMPTY] = 'empty.png'

highlightGfx = getGfx('highlight.png')


gfx = {}
for id, fname in pairs(resources) do
    gfx[id] = getGfx(fname)
end

function setBackground()
    bgGfx = MOAIGfxQuad2D.new()
    bgGfx:setTexture('bg.jpg')
    bgGfx:setRect (-1, -1, COLS - 1, ROWS - 1)
    bgGfx:setUVRect ( 0, 0, 1, 1 )
    bgProp = MOAIProp2D.new ()
    bgProp:setDeck(bgGfx)
    bgLayer:insertProp (bgProp)
    bgProp:setLoc(1, 1)
end

setBackground()

--gfxQuad:setRect ( 0, 0, 1, 1 )
--gfxQuad:setUVRect ( 0, 1, 1, 0 ) -- landscape textures

--[[prop = MOAIProp2D.new ()
prop:setDeck ( gfxQuad )
prop:setLoc(1.7, 1.7)
layer:insertProp ( prop )
prop:moveRot ( 360, 1.5 )]]

mouseProp = nil
function drawBoard()
    tiles = {}
    tilesLayer:clear()
    highlightsLayer:clear()
    --setBackground()
    for y=1, ROWS do
        col = {}
        for x=1, COLS do
            local tileProp = MOAIProp2D.new ()
            local what = board[x][y]
            tileProp:setDeck ( gfx[what] )
            tileProp:setLoc(x, y)
            tilesLayer:insertProp (tileProp)
            table.insert(col, tileProp)
            
            if what == MOUSE then
                mouseProp = tileProp
            end
            if board:is_legal(x, y) then
                local highlightProp = MOAIProp2D.new ()
                highlightProp:setDeck(highlightGfx)
                highlightProp:setLoc(x, y)
                highlightsLayer:insertProp(highlightProp)
            end
        end
        table.insert(tiles, col)
    end
end

function initBoard()
    board = Board:new(COLS, ROWS)
    board:fill_random()
    board[1][1] = MOUSE
    board[COLS][ROWS] = CHEESE
    drawBoard()
end

hoverProp = MOAIProp2D.new ()
hoverProp:setDeck ( gfx[MOUSE] )
hoverProp:setVisible(false)
fgLayer:insertProp(hoverProp)

function mouseOver(sx, sy)
    if mouseProp == nil then
        return
    end
    x, y = tilesLayer:wndToWorld(sx, sy)
    x, y = math.ceil(x), math.ceil(y)
    if board:is_legal(x, y) then
        mouseProp:setVisible(false)
        hoverProp:setVisible(true)
        hoverProp:setLoc(x, y)
    else
        mouseProp:setVisible(true)
        hoverProp:setVisible(false)
    end
end

function click(sx, sy)
    x, y = tilesLayer:wndToWorld(sx, sy)
    x, y = math.ceil(x), math.ceil(y)
    hoverProp:setVisible(false)
    if board:is_legal(x, y) then
        board:eat(x, y)
        --particle:go(fgLayer, 2,2,3,3)
        drawBoard()
        if not board:has_cheese() then
            initBoard()
        end
    end
end


function setupControl()
    if MOAIInputMgr.device.touch ~= nil then
        MOAIInputMgr.device.touch:setCallback (
            function ( eventType, idx, sx, sy, tapCount )
                if eventType == MOAITouchSensor.TOUCH_UP then
                    --tilesLayer:removeProp(highlightProp)
                    click(sx, sy)
                end
                if eventType == MOAITouchSensor.TOUCH_DOWN or eventType == MOAITouchSensor.TOUCH_MOVE then
                    mouseOver(sx, sy)
                end
            end
        )
    end
    if MOAIInputMgr.device.pointer ~= nil then
        MOAIInputMgr.device.mouseLeft:setCallback (
            function(isMouseDown)
                if(isMouseDown) then
                    -- mouseDown
                else
                    -- mouseUp
                    click(MOAIInputMgr.device.pointer:getLoc())
                end
            end
        )
        MOAIInputMgr.device.pointer:setCallback (
            function(sx, sy)
                mouseOver(MOAIInputMgr.device.pointer:getLoc())
            end
        )
    end
end



initBoard()
setupControl()

