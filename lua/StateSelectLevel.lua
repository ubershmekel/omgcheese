require 'board'
require 'level'
require 'mymoai'

--MOAIDebugLines.setStyle ( MOAIDebugLines.TEXT_BOX, 1, 1, 1, 1, 1 )
--MOAIDebugLines.setStyle ( MOAIDebugLines.TEXT_BOX_LAYOUT, 1, 0, 0, 1, 1 )
--MOAIDebugLines.setStyle ( MOAIDebugLines.TEXT_BOX_BASELINES, 1, 1, 0, 0, 1 )

SelectLevel = {}

local layer = nil
local viewport = nil
local gridProp = nil
local grid = nil
local boards = nil


local wx, wy = 10, 10
local tileSize = 50

local function tileToIndex(i, j)
    return (j - 1) * wx + i
end

local function click(wix, wiy)
    local wox, woy = layer:wndToWorld ( wix, wiy ) 
    local mx, my = gridProp:worldToModel ( wox, woy ) 
    local x, y = grid:locToCoord ( mx, my ) 
    if x < 1 or x > wx or y < 1 or y > wy then
        return
    end
    local index = tileToIndex(x, y)
    print('level ' .. index)
    print(boards[index])
    
    states[#states + 1] = SelectLevel.init
    Level:init(boards[index])
    --print(x, y, mx, my, wox, woy)
    --print(tileToIndex(x, y), tileToIndex(mx, my))
end

local function mouseOver(wx, wy)
end

function SelectLevel:init()
    local ROWS = 480
    local COLS = 640
    viewport = setupViewport(COLS, ROWS, "world")
    layer = newLayer(viewport)
    
    if boards == nil then
        boards = SelectLevel:load()
    end
    
    --partition = MOAIPartition.new()
    --layer:setPartition(partition)
    
    staticImage('bg.jpg', layer, 0, 0, COLS, ROWS)
    
    SelectLevel:setupGrid()

    setupControl(mouseOver, click)
end


function SelectLevel:setupGrid()
    grid = MOAIGrid.new()
    local deck = MOAITileDeck2D.new()

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

    gridProp = MOAIProp2D.new()
    gridProp:setDeck(deck)
    gridProp:setGrid(grid)
    gridProp:setLoc(10, 10)

    layer:insertProp(gridProp)

    --textBox("123", layer, 20, 20, 30, 300)

    for i=1, wx do
        for j=1, wy do
            --local tx, ty = grid:cellAddrToCoord(i, j)
            local tx, ty = grid:getTileLoc(i, j)
            local x, y = gridProp:modelToWorld(tx, ty)
            --local x, y = layer:worldToWnd(mx, my)
            --print(mx, my)
            textBox("".. tileToIndex(i, j), layer, x , y, x + tileSize / 2, y + tileSize / 2)
        end
    end
end

function SelectLevel:load()
    local text = io.open('levelsNormal.txt'):read("*all")
    local boards = Board:load_many(text)
    print('loaded ' .. #boards .. ' boards from ' .. #text )
    return boards
end