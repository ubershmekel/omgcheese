--[[
A flooding game where you need to navigate the mouse to the cheese by eating
fruit.
]]

require 'utils'

EMPTY = '_'
MOUSE = 'M'
CHEESE = 'C'
WALL = 'W'

GRAPE = 'g'
BANANA = 'b'
ORANGE = 'o'

FRUIT = {GRAPE, BANANA, ORANGE}

Board = {}
Board.mt = { __index = Board }

math.randomseed(os.time())

function Board:new(width, height)
    local object = {
        width = width,
        height = height
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

function Board:adjacent(x, y)
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

function Board:mouse_pos()
    for i=1, self.width do
        for j=1, self.height do
            if self[i][j] == MOUSE then
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

    if x < self.width then
        self:_eat_locs_recurse(x + 1, y, what, found)
    end
    if y < self.height then
        self:_eat_locs_recurse(x, y + 1, what, found)
    end
    if 1 < x then
        self:_eat_locs_recurse(x - 1, y, what, found)
    end
    if 1 < y then
        self:_eat_locs_recurse(x, y - 1, what, found)
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
    local mx, my = self:mouse_pos()
    self[mx][my] = EMPTY
    self[x][y] = MOUSE
end

function Board:eat2(x, y)
    assert(self:is_legal(x, y))
    what = self[x][y]
    local mx, my = self:mouse_pos()
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
end

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

function test()
    print "main"
    local board = Board:new(6, 4)
    print(board)

    board:fill_random()
    board[1][1] = MOUSE
    board[board.width][board.height] = CHEESE
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
end

if not package.loaded[...] then
    --main
    test()
    --console_play()
else --module require
end
