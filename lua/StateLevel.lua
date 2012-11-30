
StateLevel = {}

local ROWS = 6
local COLS = 12

local tilesNX, tilesNY = 4, 4

local bgLayer = nil
local targetsLayer = nil
local tilesLayer = nil
local fgLayer = nil

local board = nil
local grid = nil
local gridProp = nil

local tiles = nil

local barHeight = Env.wy / 10
local padding = 10

local function getGfx(fname, layer)
    local prop, quad = staticImage(fname, layer, -1, -1, 0, 0)
    quad:setRect (-1, -1, 0, 0)
    quad:setUVRect ( 0, 0, 1, 1 ) -- landscape textures
    return prop, quad
end

local tilemap = {}
tilemap[EMPTY] = 1
tilemap[MOUSE] = 2
tilemap[CHEESE] = 3
tilemap[BANANA] = 4
tilemap[KIWI] = 5
tilemap[ORANGE] = 6
tilemap[GRAPE] = 7
tilemap[APPLE] = 8

--highlightTile = 8
--targetTile = 9

--local highlightGfx = getGfx('highlight.png')
--local targetGfx = getGfx('target.png')


--local gfx = {}
--for id, fname in pairs(resources) do
--    gfx[id] = getGfx(fname)
--end

--gfxQuad:setRect ( 0, 0, 1, 1 )
--gfxQuad:setUVRect ( 0, 1, 1, 0 ) -- landscape textures

--[[prop = MOAIProp2D.new ()
prop:setDeck ( gfxQuad )
prop:setLoc(1.7, 1.7)
layer:insertProp ( prop )
prop:moveRot ( 360, 1.5 )]]

function StateLevel:initBoard()
    if self.map.data == nil then
        board = Board:new(COLS, ROWS)
        board:fill_random()
        board[1][ROWS] = MOUSE
        board[COLS][1] = CHEESE
    else
        board = Board:load(self.map.data):copy()
    end
    board.isHex = true
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

function StateLevel:gridToWorld(grx, gry)
    local tx, ty = grid:getTileLoc(grx, gry)
    local wox, woy = gridProp:modelToWorld(tx, ty)
    --print(grx, gry, tx, ty, wox, woy)
    return wox, woy
    --return padding + (grx - 0.5) * self.tileWidth, padding + (gry - 0.5) * self.tileHeight
end

function StateLevel:endGame()
    self.mouseProp:seekLoc(Env.wx / 2, Env.wy / 2, 3)
    self.mouseProp:moveRot(360, 2)
    wait(self.mouseProp:seekScl(3 * self.tileWidth, 3 * self.tileHeight, 3))
    if self.isArcade then
        self:initBoard()
        self:refreshGrid()
        self:refreshHUD()
        self:refreshHighlights()
    else
        local prog
        if self.turns == self.minTurns then
            prog = 3
        else
            prog = 2
        end
        Env.progress(self.map, prog)
        statemgr.pop()
    end
end

function StateLevel:refreshHighlights()
    highlightsLayer:clear()
    for i=1, board.width do
        for j=1, board.height do
            if board:is_legal(i, j) then
                local highlightProp = staticImage('highlight.png', highlightsLayer, -self.tileWidth, -self.tileHeight, self.tileWidth, self.tileHeight)
                highlightProp:setLoc(self:gridToWorld(i, j))
            end
        end
    end

end

function StateLevel:animateEat(x, y)
    targetsLayer:clear()
    highlightsLayer:clear()
    --mouseProp:setVisible(true)
    --hoverProp:setVisible(false)
    local stepTime = 0.08
    
    local function threadAnim()
        for _, pos in pairs(board:eat_locs(x, y)) do
            local wox, woy = self:gridToWorld(pos.x, pos.y)
            wait ( self.mouseProp:seekLoc ( wox, woy, stepTime, MOAIEaseType.LINEAR))
            self:setTile(pos.x, pos.y, EMPTY)
        end
        local wox, woy = self:gridToWorld(x, y)
        board:eat(x, y)
        --drawBoard()
        --refreshGrid()

        self:refreshHUD()
        if board:has_cheese() then
            self:refreshHighlights()
        else
            self:endGame()
            --wait(self.mouseProp:seekLoc ( wox, woy, stepTime))
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
        --mouseProp:setVisible(false)
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

function StateLevel:setTile(x, y, what)
    --tiles[pos.x][pos.y]:setDeck(getQuad(resources[EMPTY]), -1, -1, 0, 0)
    grid:setTile(x, y, tilemap[what])
end

function StateLevel:refreshHUD()
    if self.turnsText == nil then
        local width = Env.wx / 3
        self.turnsText = textBox("Turns", fgLayer, 0, Env.wy - barHeight, width, Env.wy)
        self.turnsText:setTextSize(30)
        self.levelText = textBox("Level", fgLayer, Env.wx - width, Env.wy - barHeight, Env.wx, Env.wy)
        self.levelText:setTextSize(30)
    end
    self.turnsText:setString(self.turns .. "/".. self.minTurns .. " turns")
    self.levelText:setString(self.title)
end

function StateLevel:refreshGrid()
    for i=1, board.width do
        for j=1, board.height do
            local what = board[i][j]

            if what == MOUSE then
                self:setTile(i, j, EMPTY)
                if self.mouseProp == nil then
                    self.mouseProp = MOAIProp2D.new()
                    --mouseProp:setDeck(getQuad('mouse.png', 0,0,100,100))
                    self.mouseProp:setDeck(self.tileDeck)
                    self.mouseProp:setIndex(tilemap[MOUSE])
                    fgLayer:insertProp(self.mouseProp)
                end
                self.mouseProp:setLoc(self:gridToWorld(board:find_tile(MOUSE)))
                self.mouseProp:setScl(self.tileWidth, self.tileHeight)
            else
                self:setTile(i, j, what)
            end
        end
    end
end

function StateLevel:setupGrid()
    grid = MOAIGrid.new()
    local deck = MOAITileDeck2D.new()
    self.tileDeck = deck

    local px, py = Env.wx - 2 * padding, Env.wy - padding - barHeight
    self.tileWidth = px / board.width
    self.tileHeight =  py / board.height
    
    deck:setTexture("tiles.png")
    if board.isHex then
        --self.tileWidth = pxx / (board.width * 2 / 3.0 + 1)
        --self.tileHeight = pxy / ((board.height / 2.0) + 1)
        self.tileWidth = px / (board.width + 0.5)
        grid:initRectGrid(board.width, board.height, self.tileWidth, self.tileHeight)
        grid:setShape(MOAIGridSpace.HEX_SHAPE)
        deck:setSize(tilesNX, tilesNY)
        --grid:initHexGrid ( board.width, board.height, 20, 0, 0 ) --blah! Can't set height vs width!
        --[[deck:setTexture ( "hex-tiles.png" )
        deck:setSize ( 4, 4, 0.25, 0.216796875 )]]
    else
        grid:initRectGrid(board.width, board.height, self.tileWidth, self.tileHeight)
        deck:setSize(tilesNX, tilesNY)

        --deck:setRect(0, 0, tileWidth, tileHeight)
        --deck:setRect(-0.5, -0.5, 0.5,0.5)
    end
    

    gridProp = MOAIProp2D.new()
    gridProp:setDeck(deck)
    gridProp:setGrid(grid)
    gridProp:setLoc(padding, padding)
    -- so that grid positioning (like highlights and mouse location)
    -- know the grid has been moved by 'padding' in this frame too.
    gridProp:forceUpdate()

    tilesLayer:insertProp(gridProp)

    --textBox("123", layer, 20, 20, 30, 300)

    --[[for i=1, board.width do
        for j=1, board.height do
            --local tx, ty = grid:cellAddrToCoord(i, j)
            local tx, ty = grid:getTileLoc(i, j)
            local x, y = gridProp:modelToWorld(tx, ty)
            --local x, y = layer:worldToWnd(mx, my)
            --print(mx, my)
            --textBox("".. tileToIndex(i, j), layer, x , y, x + tileSize / 2, y + tileSize / 2)
        end
    end]]
end

function StateLevel:click(wix, wiy)
    local wox, woy = tilesLayer:wndToWorld ( wix, wiy ) 
    local mx, my = gridProp:worldToModel ( wox, woy ) 
    local x, y = grid:locToCoord ( mx, my ) 

    if x < 1 or x > board.width or y < 1 or y > board.height then
        return
    end

    --hoverProp:setVisible(false)

    if board:is_legal(x, y) then
        self.turns = self.turns + 1
        --board:eat(x, y)
        --particle:go(fgLayer, 2,2,3,3)
        --drawBoard()
        StateLevel:animateEat(x, y)
        --self:refreshGrid()
        --if not board:has_cheese() then
        --    self:endGame()
        --end
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
    self.mouseProp = nil
    self.turnsText = nil

    bgLayer = newLayer(self)
    targetsLayer = newLayer(self)
    tilesLayer = newLayer(self)
    highlightsLayer = newLayer(self)
    fgLayer = newLayer(self)
    
    staticImage('bg.jpg', bgLayer, 0, 0, Env.wx, Env.wy)

    if map == nil then
        self.isArcade = true
        self.title = 'Arcade'
        self.map = {isHex=True}
    else
        self.isArcade = false
        self.title = 'Level ' .. map.name
        self.map = map
    end
    self:initBoard()
    self:setupGrid()
    self:refreshGrid()
    self:refreshHUD()
    self:refreshHighlights()
end

return StateLevel
