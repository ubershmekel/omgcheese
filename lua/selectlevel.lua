require 'board'
require 'level'
require 'mymoai'

--MOAIDebugLines.setStyle ( MOAIDebugLines.TEXT_BOX, 1, 1, 1, 1, 1 )
--MOAIDebugLines.setStyle ( MOAIDebugLines.TEXT_BOX_LAYOUT, 1, 0, 0, 1, 1 )
--MOAIDebugLines.setStyle ( MOAIDebugLines.TEXT_BOX_BASELINES, 1, 1, 0, 0, 1 )

SelectLevel = {}

local layer = nil
local viewport = nil

local function click(wx, wy)
end

local function mouseOver(wx, wy)
end

function SelectLevel:init()
    local ROWS = 480
    local COLS = 640
    viewport, layer = setupViewport(COLS, ROWS, "world")
    
    --partition = MOAIPartition.new()
    --layer:setPartition(partition)
    
    staticImage('bg.jpg', layer, 0, 0, COLS, ROWS)
    
    SelectLevel:setupGrid()

    setupControl(mouseOver, click)
end

function SelectLevel:setupGrid()
    local grid = MOAIGrid.new()
    local deck = MOAITileDeck2D.new()

    local wx, wy = 10, 10
    local tileSize = 40
    grid:initRectGrid(wx, wy, tileSize, tileSize)
    deck:setTexture("button.png")
    deck:setSize(1, 1)
    --[[grid:initHexGrid ( wx, wy, tileSize )
    deck:setTexture ( "hex-tiles.png" )
    deck:setSize ( 4, 4, 0.25, 0.216796875 )]]
    
    for i=1, wx do
        for j=1, wy do
            grid:setTile(i, j, (j % 4) + 1)
        end
    end

    prop = MOAIProp2D.new()
    prop:setDeck(deck)
    prop:setGrid(grid)
    prop:setLoc(10, 10)

    layer:insertProp(prop)

    --textBox("123", layer, 20, 20, 30, 300)

    for i=1, wx do
        for j=1, wy do
            --local tx, ty = grid:cellAddrToCoord(i, j)
            local tx, ty = grid:getTileLoc(i, j)
            local x, y = prop:modelToWorld(tx, ty)
            --local x, y = layer:worldToWnd(mx, my)
            --print(mx, my)
            textBox("".. (i - 1) * wx + j, layer, x , y, x + tileSize / 2, y + tileSize / 2)
        end
    end
    
    local boards = SelectLevel:load()
end

function SelectLevel:load()
    local text = io.open('levelsNormal.txt'):read()
    
    return Board:load_many(text)
end
