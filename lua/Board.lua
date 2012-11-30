--[[
The logic for a flooding game where you need to navigate the mouse to the
cheese by eating fruit.
]]

require 'mylua'

EMPTY = '_'
MOUSE = 'M'
CHEESE = 'C'
WALL = 'W'

GRAPE = 'g'
BANANA = 'b'
ORANGE = 'o'
KIWI = 'k'
APPLE = 'a'

FRUIT = {GRAPE, BANANA, ORANGE, KIWI, APPLE}

Board = {}
Board.mt = { __index = Board }

math.randomseed(os.time())

function Board:new(width, height, isHex)
    assert(width ~= nil)
    assert(height ~= nil)
    if isHex == nil then
        isHex = false
    end
    local object = {
        width = width,
        height = height,
        isHex = isHex
        }
    setmetatable(object, Board.mt)
    for i=1, width do
        object[i] = {}
        for j=1, height do
            object[i][j] = EMPTY
        end
    end
    return object
end

function Board:load(text)
    local data = {}
    for line in text:gmatch("[^ \r\n]+") do
        row = {}
        for c in line:gmatch(".") do
            table.insert(row, c)
        end
        table.insert(data, row)
    end
    local obj = Board:new(#data[1], #data)
    for i=1, obj.width do
        for j=1, obj.height do
            obj[i][j] = data[j][i]
        end
    end
    return obj
end

function Board:load_many(text)
    local boards = {}
    local this_text = ''
    for line in text:gmatch("[^ \r\n]+") do
        if line == 'Board(' then
            -- pass
        elseif line == ')' then
            local loaded = Board:load(this_text)
            table.insert(boards, loaded)
            this_text = ''
        else
            this_text = this_text .. '\n' .. line
        end
    end
    return boards
end

function Board:copy()
    local board = Board:new(self.width, self.height)
    board.isHex = self.isHex
    for i=1, self.width do
        for j=1, self.height do
            board[i][j] = self[i][j]
        end
    end
    return board
end

local function save_boards(fname, group, isHex, boards)
    --[=[ Example record:

        lev = {}
        lev.name = '4'
        lev.group = 'normal'
        lev.data = [[
         Mkogbgbokgbk
         ookbggbobggg
         ogkkgggggokk
         bobokkbbkgbk
         ogobgoggkkko
         ogbgbogobkoC
         ]]
        table.insert(Levels, lev)

    ]=]
    local header = [[
Levels = {}

local lev = nil

]]
    local fmt = [=[
lev = {}
lev.name = '%s'
lev.group = '%s'
lev.isHex = %s
lev.minTurns = %s
lev.data = [[
 %s
 ]]
table.insert(Levels, lev)

]=]


    local file = io.open(fname, "w")
    file:write(header)
    for i, sp in ipairs(boards) do
        local minTurns, board = sp[1], sp[2]
        boardStr = string.sub(tostring(board), #'Board(\n   ', -4) -- remove "Board(" and ")"
        file:write(string.format(fmt, '' .. i, group, isHex, minTurns, boardStr))
        --file:write('\n')
    end
    file:close()
end

function Board.mt:__tostring()
    local str = 'Board(\n'
    for i=1, self.height do
        str = str .. ' '
        for j=1, self.width do
            str = str .. self[j][i]
        end
        str = str .. '\n'
    end
    str = str ..')'
    return str
end

function Board.mt:__eq(other)
    if self.width ~= other.width or self.height ~= other.height then
        return false
    end
    for i=1, self.width do
        for j=1, self.height do
            if self[i][j] ~= other[i][j] then
                return false
            end
        end
    end
    return true
end

function choose(array)
    return array[math.random(1, #array)]
end

function Board:fill_random()
    for i=1, self.width do
        for j=1, self.height do
            self[i][j] = choose(FRUIT)
        end
    end
end

function Board:standard_random()
    self:fill_random()
    self[1][1] = MOUSE
    self[self.width][self.height] = CHEESE
end

function Board:hexAdjacent(x, y)
    assert(x ~= nil)
    assert(y ~= nil)
    local adj = {}
    if x < self.width then
        adj[{x=x + 1, y=y}] = self[x + 1][y]
    end
    if 1 < x then
        adj[{x=x - 1, y=y}] = self[x - 1][y]
    end
    --[[
    hexmap:
    1,3  2,3  3,3  4,3
       1,2  2,2  3,2  4,2
    1,1  2,1  3,1  4,1
    
    ]]
    local offset = 1 - (y % 2) * 2 -- either -1 or +1
    -- check if border
    if offset == 1 and x + 1 >= self.width then
        offset = nil
    elseif offset == -1 and x <= 1 then
        offset = nil
    end
        
    if y < self.height then
        adj[{x=x, y=y + 1}] = self[x][y + 1]
        if offset ~= nil then
            adj[{x=x + offset, y=y + 1}] = self[x + offset][y + 1]
        end
    end
    if 1 < y then
        adj[{x=x, y=y - 1}] = self[x][y - 1]
        if offset ~= nil then
            adj[{x=x + offset, y=y - 1}] = self[x + offset][y - 1]
        end
    end
    return adj
end

function Board:adjacent(x, y)
    if self.isHex then
        return self:hexAdjacent(x, y)
    else
        return self:rectAdjacent(x, y)
    end
end

function Board:rectAdjacent(x, y)
    assert(x ~= nil)
    assert(y ~= nil)
    local adj = {}
    if x < self.width then
        adj[{x=x + 1, y=y}] = self[x + 1][y]
    end
    if y < self.height then
        adj[{x=x, y=y + 1}] = self[x][y + 1]
    end
    if 1 < x then
        adj[{x=x - 1, y=y}] = self[x - 1][y]
    end
    if 1 < y then
        adj[{x=x, y=y - 1}] = self[x][y - 1]
    end
    
    return adj
end

function Board:is_legal(x, y)
    assert(type(x) == "number")
    assert(type(y) == "number")
    if self[x][y] == MOUSE or self[x][y] == EMPTY then
        return false
    end
    local adj = self:adjacent(x, y)
    for pos, val in pairs(adj) do
        if val == MOUSE or val == EMPTY then
            return true
        end
    end
    return false
end

function Board:find_tile(what)
    for i=1, self.width do
        for j=1, self.height do
            if self[i][j] == what then
                return i, j
            end
        end
    end
end


function Board:_eat_locs_recurse(x, y, what, found)
    assert(x ~= nil)
    assert(y ~= nil)
    if found:contains({x=x, y=y}) then
        return
    end

    if self[x][y] == what or self[x][y] == CHEESE then
        found:add({x=x, y=y})
    else
        return
    end

    local adj = self:adjacent(x, y)
    for pos, val in pairs(adj) do
        self:_eat_locs_recurse(pos.x, pos.y, what, found)
    end
end

function Board:eat_locs(x, y)
    assert(self:is_legal(x, y))
    local what = self[x][y]
    local found = Set:new()
    for i, pos in ipairs(self:legal_moves()) do
        if self[pos.x][pos.y] == what then
            self:_eat_locs_recurse(pos.x, pos.y, what, found)
        end
    end
    return found
end

function Board:eat(x, y)
    for _, loc in pairs(self:eat_locs(x, y)) do
        self[loc.x][loc.y] = EMPTY
    end
    local mx, my = self:find_tile(MOUSE)
    self[mx][my] = EMPTY
    self[x][y] = MOUSE
end
--[[
function Board:eat2(x, y)
    assert(self:is_legal(x, y))
    what = self[x][y]
    local mx, my = self:find_tile(MOUSE)
    self[mx][my] = EMPTY
    for i, pos in ipairs(self:legal_moves()) do
        if self[pos.x][pos.y] == what then
            self:eat_recurse(pos.x, pos.y, what)
        end
    end
    self[x][y] = MOUSE
end

function Board:eat_recurse(x, y, what)
    assert(x ~= nil)
    assert(y ~= nil)

    if self[x][y] == what or self[x][y] == CHEESE then
        self[x][y] = EMPTY
    else
        return
    end

    if x < self.width then
        self:eat_recurse(x + 1, y, what)
    end
    if y < self.height then
        self:eat_recurse(x, y + 1, what)
    end
    if 1 < x then
        self:eat_recurse(x - 1, y, what)
    end
    if 1 < y then
        self:eat_recurse(x, y - 1, what)
    end
end]]

function Board:has_cheese()
    for i=1, self.width do
        for j=1, self.height do
            if self[i][j] == CHEESE then
                return true
            end
        end
    end
    return false
end

function Board:legal_moves()
    local legals = {}
    for i=1, self.width do
        for j=1, self.height do
            if self:is_legal(i, j) then
                table.insert(legals, {x=i, y=j})
            end
        end
    end
    return legals
end

function Board:solve()
    --local cheese_loc = self:find_tile(CHEESE)
    --local mouse_loc = self:find_tile(MOUSE)
    steps = {}
    
    --[[for i=1, self.width do
        steps[i] = {}
        for j=1, self.height do
            steps[i][j] = -1
        end
    end]]

    --steps[cheese_loc.x][cheese_loc.y] = 0
    i = 0
    while self:has_cheese() do
        --print(self)
        local current_eat_locs = {}
        for i, pos in ipairs(self:legal_moves()) do
            local eat_locs = self:eat_locs(pos.x, pos.y)
            for _, loc in pairs(eat_locs) do
                table.insert(current_eat_locs, loc)
                --steps[loc.x][loc.y] = i
            end
            -- manually, simaltaneously remove tiles to avoid convoluting eat steps
        end
        for _, loc in pairs(current_eat_locs) do
            self[loc.x][loc.y] = EMPTY
        end

        i = i + 1
    end

    --print('solved in', i, 'steps')
    return i
end

--[[MOAI is on lua5.1 that doesn't have `goto`
function console_play()
    local board = Board:new(8, 6)
    board:fill_random()
    board[1][1] = MOUSE
    board[board.width][board.height] = CHEESE
    print('Type the x,y of the fruit you want to eat')
    local turns = 0
    print(board)
    while board:has_cheese() do
        line = io.read()
        coords = {}
        for num in string.gmatch(line, "%d+") do
            table.insert(coords, tonumber(num))
        end
        if #coords ~= 2 then
            print("! - Bad coords, I don't get it")
            goto continue
        end
        if board:is_legal(coords[1], coords[2]) then
            board:eat(coords[1], coords[2])
            print(board)
        else
            print('! - illegal move')
            goto continue
        end
        turns = turns + 1
        ::continue::
    end
    print(string.format('Game over in %d turns', turns))
end]]

function generate_levels(width, height, fname, group, isHex)
    local results = {}
    local boards = {}
    local board = Board:new(width, height)
    print('generating')
    for i=1, 100 do
        board:standard_random()
        board.isHex = isHex
        local copy = board:copy()
        local steps = board:solve()
        table.insert(results, steps)
        table.insert(boards, {steps, copy})
    end
    function compare(a,b)
        return a[1] < b[1]
    end
    print 'sorting'
    table.sort(boards, compare)

    require('stats')
    stats.print(results)
    save_boards(fname, group, isHex, boards)

end

function test()
    print "main"
    local board = Board:new(6, 4)
    print(board)

    board:standard_random()
    print(board)

    assert(board:is_legal(2,1))
    assert(board:is_legal(1,2))
    
    board:eat(2, 1)
    print(board)
    
    local board_s = [[
    M___b
    gg_gb
    bbbgb
    ggggb
    Coobb
    ]]
    local expected_s = [[
    ____b
    M___b
    bbb_b
    ____b
    _oobb
    ]]
    board = Board:load(board_s)
    expected = Board:load(expected_s)

    assert(not board:is_legal(1, 1))
    assert(not board:is_legal(2, 5))

    board:eat(1, 2)
    print(expected)
    print(board)
    assert(board == expected)
    
    board = Board:load(board_s)
    local legal = board:legal_moves()
    local expected_legal = {{x=1,y=2},{x=2,y=2},{x=3,y=3},{x=4,y=2}, {x=5,y=1}}
    print(table.tostring(legal))
    assert(recursive_compare(legal, expected_legal))
    
    board:eat_locs(2,2)
    -- make sure eat_locs doesn't affect the board, a sad old bug
    -- moved the mouse :/
    assert(Board:load(board_s) == board)

    assert(board:solve() == 1)
    
end

if not package.loaded[...] then
    --main
    test()
    --console_play()
    --generate_levels()
else --module require
end
