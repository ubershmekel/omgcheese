require 'mymoai'
require 'board'
require 'particle'

Level = {}

local ROWS = 6
local COLS = 12

local bgLayer = nil
local targetsLayer = nil
local tilesLayer = nil
local fgLayer = nil

local function getGfx(fname)
    local quad = MOAIGfxQuad2D.new()
    quad:setTexture (fname)
    quad:setRect (-1, -1, 0, 0)
    quad:setUVRect ( 0, 0, 1, 1 ) -- landscape textures
    return quad
end

--MOAIGfxDevice.setClearColor(0.58, 0.81, 0.98, 1)

--[[function onDraw()
    MOAIGfxDevice.setPenColor ( 1, 0, 0, 1 )
    MOAIGfxDevice.setPenWidth ( 2 )
    MOAIDraw.fillRect(1,1,3,3)
end

scriptDeck = MOAIScriptDeck.new ()
scriptDeck:setRect ( -4, -4, 4, 4 )
scriptDeck:setDrawCallback ( onDraw )]]

local resources = {}
resources[MOUSE] = 'gopher.png'
resources[CHEESE] = 'cake.png'
resources[BANANA] = 'banana.png'
resources[ORANGE] = 'orange.png'
resources[GRAPE] = 'grape.png'
resources[KIWI] = 'kiwi.png'
resources[EMPTY] = 'empty.png'

local highlightGfx = getGfx('highlight.png')
local targetGfx = getGfx('target.png')


local gfx = {}
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

--gfxQuad:setRect ( 0, 0, 1, 1 )
--gfxQuad:setUVRect ( 0, 1, 1, 0 ) -- landscape textures

--[[prop = MOAIProp2D.new ()
prop:setDeck ( gfxQuad )
prop:setLoc(1.7, 1.7)
layer:insertProp ( prop )
prop:moveRot ( 360, 1.5 )]]

local board = nil
local mouseProp = nil
local tiles = nil
function drawBoard()
    tiles = {}
    tilesLayer:clear()
    highlightsLayer:clear()
    targetsLayer:clear()
    --setBackground()
    for x=1, COLS do
        col = {}
        table.insert(tiles, col)
        for y=1, ROWS do
            local tileProp = MOAIProp2D.new ()
            local what = board[x][y]
            tileProp:setDeck ( gfx[what] )
            tileProp:setLoc(x, y)
            tilesLayer:insertProp (tileProp)
            tiles[x][y] = tileProp
            
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
    end
end

function initBoard(map)
    if map == nil then
        board = Board:new(COLS, ROWS)
        board:fill_random()
        board[1][1] = MOUSE
        board[COLS][ROWS] = CHEESE
    else
        board = map:copy()
    end
    drawBoard()
end

local hoverProp = nil

local recentHighlightX = nil
local recentHighlightY = nil
local function highlightTargets(x, y)
    if recentHighlightX == x and recentHighlightY == y then
        return
    end
    targetsLayer:clear()
    for _, pos in pairs(board:eat_locs(x, y)) do
        local targetProp = MOAIProp2D.new ()
        targetProp:setDeck(targetGfx)
        targetProp:setLoc(pos.x, pos.y)
        targetsLayer:insertProp(targetProp)
    end
    recentHighlightX = x
    recentHighlightY = y
end

local function endGame()
    mouseProp:seekLoc(COLS / 2, ROWS / 2, 1)
    mouseProp:moveRot(360, 2)
    wait(mouseProp:seekScl(3, 3, 3))
    initBoard()
end


local function animateEat(x, y)
    targetsLayer:clear()
    highlightsLayer:clear()
    mouseProp:setVisible(true)
    hoverProp:setVisible(false)
    local function threadAnim()
        for _, pos in pairs(board:eat_locs(x, y)) do
            wait ( mouseProp:seekLoc ( pos.x, pos.y, 0.1))
            tiles[pos.x][pos.y]:setDeck(gfx[EMPTY])
        end
        board:eat(x, y)
        drawBoard()

        if not board:has_cheese() then
            endGame()
        end
    end
    
    local thread = MOAIThread.new ()
    thread:run ( threadAnim )
end

local function mouseOver(sx, sy)
    if mouseProp == nil then
        return
    end
    local x, y = tilesLayer:wndToWorld(sx, sy)
    x, y = math.ceil(x), math.ceil(y)
    if board:is_legal(x, y) then
        mouseProp:setVisible(false)
        hoverProp:setVisible(true)
        hoverProp:setLoc(x, y)
        highlightTargets(x, y)
    else
        mouseProp:setVisible(true)
        hoverProp:setVisible(false)
        targetsLayer:clear()
        recentHighlightX = nil
    end
end

local function click(sx, sy)
    x, y = tilesLayer:wndToWorld(sx, sy)
    x, y = math.ceil(x), math.ceil(y)
    hoverProp:setVisible(false)
    if board:is_legal(x, y) then
        --board:eat(x, y)
        --particle:go(fgLayer, 2,2,3,3)
        --drawBoard()
        animateEat(x, y)
    end
end


function Level:init(map)
    --MOAISim.openWindow ( "test", WIDTH, HEIGHT )
    --moai.logger:debug("" .. MOAIEnvironment.screenWidth .. " " .. MOAIEnvironment.screenHeight)
    --[[MOAISim.openWindow ("test", screenWidth, screenHeight)

    viewport = MOAIViewport.new ()
    viewport:setSize ( screenWidth, screenHeight )
    viewport:setScale ( COLS, -ROWS )]]

    clearLayers()
    viewport = setupViewport(COLS, -ROWS, "test")
    --viewport:setOffset(-math.floor(COLS / 2), -math.floor(ROWS / 2))
    viewport:setOffset(-1, 1) -- origin at top left

    bgLayer = newLayer(viewport)

    highlightsLayer = newLayer(viewport)

    targetsLayer = newLayer(viewport)

    tilesLayer = newLayer(viewport)

    fgLayer = newLayer(viewport)
    
    hoverProp = MOAIProp2D.new ()
    hoverProp:setDeck ( gfx[MOUSE] )
    hoverProp:setVisible(false)
    fgLayer:insertProp(hoverProp)

    setBackground()
    initBoard(map)
    setupControl(mouseOver, click)
end

