require 'mymoai'
require 'Board'
require 'particle'
require 'inputmgr'

StateLevel = {}

local ROWS = 6
local COLS = 12

local bgLayer = nil
local targetsLayer = nil
local tilesLayer = nil
local fgLayer = nil

local board = nil
local grid = nil
local gridProp = nil

local mouseProp = nil
local tiles = nil

local barHeight = Env.wy / 10

local function getGfx(fname, layer)
    local prop, quad = staticImage(fname, layer, -1, -1, 0, 0)
    quad:setRect (-1, -1, 0, 0)
    quad:setUVRect ( 0, 0, 1, 1 ) -- landscape textures
    return prop, quad
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

local tilemap = {}
tilemap[MOUSE] = 1
tilemap[CHEESE] = 2
tilemap[BANANA] = 3
tilemap[KIWI] = 4
tilemap[ORANGE] = 5
tilemap[GRAPE] = 6
tilemap[EMPTY] = 7

--local highlightGfx = getGfx('highlight.png')
--local targetGfx = getGfx('target.png')


--local gfx = {}
--for id, fname in pairs(resources) do
--    gfx[id] = getGfx(fname)
--end

function setBackground()
    --bgGfx = MOAIGfxQuad2D.new()
    --bgGfx:setTexture('bg.jpg')
    local bgProp, bgGfx = staticImage('bg.jpg', bgLayer, -1, -1, COLS - 1, ROWS - 1)
    --bgGfx:setRect (-1, -1, COLS - 1, ROWS - 1)
    bgGfx:setUVRect ( 0, 0, 1, 1 )
    --bgProp = MOAIProp2D.new ()
    --bgProp:setDeck(bgGfx)
    --bgLayer:insertProp (bgProp)
    bgProp:setLoc(1, 1)
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
    tilesLayer:clear()
    highlightsLayer:clear()
    targetsLayer:clear()
    --setBackground()
    for x=1, COLS do
        col = {}
        table.insert(tiles, col)
        for y=1, ROWS do
            --local tileProp = MOAIProp2D.new ()
            local what = board[x][y]
            --tileProp:setDeck ( gfx[what] )
            --tileProp:setLoc(x, y)
            --tilesLayer:insertProp (tileProp)
            --tiles[x][y] = tileProp
            local tileProp, quad = getGfx(resources[what], tilesLayer)
            tiles[x][y] = tileProp
            tileProp:setLoc(x, y)

            if what == MOUSE then
                mouseProp = tileProp
            end
            if board:is_legal(x, y) then
                --local highlightProp = MOAIProp2D.new ()
                --highlightProp:setDeck(highlightGfx)
                local highlightProp = getGfx('highlight.png', highlightsLayer)
                highlightProp:setLoc(x, y)
                --highlightsLayer:insertProp(highlightProp)
            end
        end
    end
end

function StateLevel:initBoard(map)
    if map == nil then
        board = Board:new(COLS, ROWS)
        board:fill_random()
        board[1][1] = MOUSE
        board[COLS][ROWS] = CHEESE
    else
        board = map:copy()
    end
    self.turns = 0
    self.minTurns = board:copy():solve()
    --drawBoard()
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
        --local targetProp = MOAIProp2D.new ()
        --targetProp:setDeck(targetGfx)
        local targetProp = getGfx('target.png', targetsLayer)
        targetProp:setLoc(pos.x, pos.y)
        --targetsLayer:insertProp(targetProp)
    end
    recentHighlightX = x
    recentHighlightY = y
end

function StateLevel:endGame()
    --mouseProp:seekLoc(COLS / 2, ROWS / 2, 1)
    --mouseProp:moveRot(360, 2)
    --wait(mouseProp:seekScl(3, 3, 3))
    if self.isArcade then
        self:initBoard()
        self:refreshGrid()
    else
        statemgr.pop()
    end
end


function StateLevel:animateEat(x, y)
    targetsLayer:clear()
    highlightsLayer:clear()
    mouseProp:setVisible(true)
    hoverProp:setVisible(false)
    local function threadAnim()
        for _, pos in pairs(board:eat_locs(x, y)) do
            wait ( mouseProp:seekLoc ( pos.x, pos.y, 0.1))
            tiles[pos.x][pos.y]:setDeck(getQuad(resources[EMPTY]), -1, -1, 0, 0)
        end
        board:eat(x, y)
        drawBoard()

        if not board:has_cheese() then
            self:endGame()
        end
    end
    local thread = MOAIThread.new ()
    thread:run ( threadAnim )
end

function StateLevel:mouseOver(sx, sy)
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

--local barSections = {"turns", "target", "back"}

function StateLevel:refreshHUD()
    self.turnsText:setString(self.turns .. "/".. self.minTurns .. " turns")
    --self.targetTurnsText:setString('' .. )
end

function StateLevel:refreshGrid()
    for i=1, board.width do
        for j=1, board.height do
            grid:setTile(i, j, tilemap[board[i][j]])
        end
    end
    self:refreshHUD()
end

function StateLevel:setupGrid()
    grid = MOAIGrid.new()
    local deck = MOAITileDeck2D.new()

    local padding = 10
    local tileHeight = (Env.wy - padding - barHeight) / board.height
    local tileWidth = (Env.wx - 2 * padding) / board.width
    grid:initRectGrid(board.width, board.height, tileWidth, tileHeight)
    deck:setTexture("tiles.png")
    deck:setSize(4, 2)
    --[[grid:initHexGrid ( wx, wy, tileSize )
    deck:setTexture ( "hex-tiles.png" )
    deck:setSize ( 4, 4, 0.25, 0.216796875 )]]
    
    self:refreshGrid()

    gridProp = MOAIProp2D.new()
    gridProp:setDeck(deck)
    gridProp:setGrid(grid)
    gridProp:setLoc(padding, padding)

    tilesLayer:insertProp(gridProp)

    --textBox("123", layer, 20, 20, 30, 300)

    for i=1, board.width do
        for j=1, board.height do
            --local tx, ty = grid:cellAddrToCoord(i, j)
            local tx, ty = grid:getTileLoc(i, j)
            local x, y = gridProp:modelToWorld(tx, ty)
            --local x, y = layer:worldToWnd(mx, my)
            --print(mx, my)
            --textBox("".. tileToIndex(i, j), layer, x , y, x + tileSize / 2, y + tileSize / 2)
        end
    end
end

function StateLevel:click(wix, wiy)
    local wox, woy = tilesLayer:wndToWorld ( wix, wiy ) 
    local mx, my = gridProp:worldToModel ( wox, woy ) 
    local x, y = grid:locToCoord ( mx, my ) 

    if x < 1 or x > board.width or y < 1 or y > board.height then
        return
    end

    hoverProp:setVisible(false)

    if board:is_legal(x, y) then
        self.turns = self.turns + 1
        board:eat(x, y)
        --particle:go(fgLayer, 2,2,3,3)
        --drawBoard()
        --StateLevel:animateEat(x, y)
        self:refreshGrid()
        if not board:has_cheese() then
            self:endGame()
        end
    end
end

StateLevel.onInput = function ( self )
	if inputmgr:up () then
		self:click ( inputmgr:getTouch ())		
	elseif inputmgr:down () then
		self:mouseOver( inputmgr:getTouch ())
	end
end

function StateLevel:onLoad(map)
    --MOAISim.openWindow ( "test", WIDTH, HEIGHT )
    --moai.logger:debug("" .. MOAIEnvironment.screenWidth .. " " .. MOAIEnvironment.screenHeight)
    --[[MOAISim.openWindow ("test", screenWidth, screenHeight)

    viewport = MOAIViewport.new ()
    viewport:setSize ( screenWidth, screenHeight )
    viewport:setScale ( COLS, -ROWS )]]

    --clearLayers()
    --viewport = setupViewport(COLS, -ROWS, "test")
    --viewport:setOffset(-math.floor(COLS / 2), -math.floor(ROWS / 2))
    --[[
    if self.viewport == nil then
	    self.viewport = MOAIViewport.new ()
	    self.viewport:setSize ( screenWidth, screenHeight )
        self.viewport:setScale ( COLS, -ROWS )
        self.viewport:setOffset(-1, 1) -- origin at top left
    end]]

    bgLayer = newLayer(self)
    highlightsLayer = newLayer(self)
    targetsLayer = newLayer(self)
    tilesLayer = newLayer(self)
    fgLayer = newLayer(self)
    
    hoverProp, quad = getGfx(resources[MOUSE], fgLayer)
    --hoverProp:setDeck ( gfx[MOUSE] )
    hoverProp:setVisible(false)
    --fgLayer:insertProp(hoverProp)

    --setBackground()
    staticImage('bg.jpg', bgLayer, 0, 0, Env.wx, Env.wy)

    local width = Env.wx / 3
    self.turnsText = textBox("Turns", fgLayer, 0, Env.wy - barHeight, width, Env.wy)
    self.turnsText:setTextSize(24)
    
    if map == nil then
        self.isArcade = true
    else
        self.isArcade = false
    end
    self:initBoard(map)
    self:setupGrid()
    --setupControl(mouseOver, click)
end

return StateLevel
