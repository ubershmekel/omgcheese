
StateSelectLevel = {}

local layer = nil
local gridProp = nil
local grid = nil
--local boards = nil
local padding = 10

local wx, wy = 10, 10
local tileSize = 80

function StateSelectLevel:tileToIndex(i, j)
    return (j - 1) * wx + i
end

function StateSelectLevel:click(wix, wiy)
    local wox, woy = layer:wndToWorld ( wix, wiy ) 
    local mx, my = gridProp:worldToModel ( wox, woy ) 
    local x, y = grid:locToCoord ( mx, my )
    if x < 1 or x > wx or y < 1 or y > wy then
        return
    end
    local index = self:tileToIndex(x, y)
    print('level ' .. index)
    --local board = boards[index]
    local board = Levels[index]
    print(board.data)
    
    statemgr.push('StateLevel.lua', board)
    --Level:init(boards[index])
    --print(x, y, mx, my, wox, woy)
    --print(tileToIndex(x, y), tileToIndex(mx, my))
    --self.lastTouch = nil
end


--DragClick.click = StateSelectLevel.click
local function drag(dx, dy)
    StateSelectLevel.camera:moveLoc(-dx, -dy)
end
local function click(wix, wiy)
    StateSelectLevel:click(wix, wiy)
end
local dragclick = DragClick:new(drag, click)

function StateSelectLevel:mouseDown(wix, wiy)
    dragclick.down(wix, wiy)
end

StateSelectLevel.onInput = function ( self )
	if inputmgr:up () then
		--self:click ( inputmgr:getTouch ())
        dragclick:up( inputmgr:getTouch () )
	elseif inputmgr:isDown () then
        dragclick:down( inputmgr:getTouch () )
		--self:mouseDown( inputmgr:getTouch ())
	end
end

function StateSelectLevel:setupGrid()
    grid = MOAIGrid.new()
    local deck = MOAITileDeck2D.new()

    grid:initRectGrid(wx, wy, tileSize, tileSize)
    deck:setTexture("buttons.png")
    deck:setSize(4, 1)
    --[[grid:initHexGrid ( wx, wy, tileSize )
    deck:setTexture ( "hex-tiles.png" )
    deck:setSize ( 4, 4, 0.25, 0.216796875 )]]
    
    gridProp = MOAIProp2D.new()
    gridProp:setDeck(deck)
    gridProp:setGrid(grid)
    gridProp:setLoc(padding, padding)

    layer:insertProp(gridProp)

    for i=1, wx do
        for j=1, wy do
            local tx, ty = grid:getTileLoc(i, j)
            local x, y = gridProp:modelToWorld(tx, ty)
            local mapIndex = self:tileToIndex(i, j)
            local map = Levels[mapIndex]
            local textProp = R:label({text="".. map.name,
                    layer=layer,
                    width=tileSize,
                    height=tileSize,
                    fontSize=tileSize/4})
            textProp:setAlignment ( MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY )
            textProp:setColor(0.5, 0.3, 0)
            textProp:setLoc(x + padding, y + padding)
        end
    end
end
function StateSelectLevel:refreshGrid()
    for i=1, wx do
        for j=1, wy do
            local mapIndex = self:tileToIndex(i, j)
            local map = Levels[mapIndex]
            local prog = Env.progress(map)
            grid:setTile(i, j, prog)
        end
    end
end

function StateSelectLevel:onFocus()
    self:refreshGrid()
end

function StateSelectLevel:onLoad()
	--[[viewport = MOAIViewport.new ()
	viewport:setSize ( screenWidth, screenHeight )
    viewport:setScale ( COLS, ROWS )
    viewport:setOffset(-1, -1) -- origin at top left]]
    --viewport = setupViewport(COLS, ROWS, "world")
    --if boards == nil then
    --    boards = self:loadLevels()
    --end
    
    --partition = MOAIPartition.new()
    --layer:setPartition(partition)
    
    local bgLayer = newLayer(self)
    staticImage('bg.jpg', bgLayer, 0, 0, Env.wx, Env.wy)
    
    layer = newLayer(self)
    self:setupGrid()
    self.camera = MOAICamera2D.new()
    --self.camera:setLoc(0,100,-10)
    layer:setCamera(self.camera)

    --setupControl(mouseOver, click)
end


return StateSelectLevel
