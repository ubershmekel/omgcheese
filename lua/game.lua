-- mouse
-- cheese
-- board
-- legal moves
-- make a move
-- update board
-- turns
-- win state/event

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
    for i=1, height do
        object[i] = {}
        for j=1, width do
            object[i][j] = EMPTY
        end
    end
    return object
end

function Board.mt:__tostring()
    local str = 'Board(\n'
    for i=1, self.height do
        str = str .. ' '
        for j=1, self.width do
            str = str .. self[i][j]
        end
        str = str .. '\n'
    end
    str = str ..')'
    return str
end

function choose(array)
    return array[math.random(1, #array)]
end

function Board:fill_random()
    for i=1, self.height do
        for j=1, self.width do
            self[i][j] = choose(FRUIT)
        end
    end
end

function Board:adjacent(x, y)
    local adj = {}
    if x < self.width then
        table.insert(adj, self[y][x + 1])
    end
    if y < self.height then
        table.insert(adj, self[y + 1][x])
    end
    if 1 < x then
        table.insert(adj, self[y][x - 1])
    end
    if 1 < y then
        table.insert(adj, self[y - 1][x])
    end
    
    return adj
end

function Board:is_legal(x, y)
    local adj = self:adjacent(x, y)
    if self[y][x] == MOUSE or self[y][x] == EMPTY then
        return false
    end
    for i, v in ipairs(adj) do
        if v == MOUSE or v == EMPTY then
            return true
        end
    end
    return false
end

function Board:mouse_position()
    for i=1, self.height do
        for j=1, self.width do
            if self[i][j] == MOUSE then
                return j, i
            end
        end
    end
end

-- Call eat() without "what", that's only used for the recursion
function Board:eat(x, y, what)
    local is_first = false
    if what == nil then
        assert(self:is_legal(x, y))
        what = self[y][x]
        local mx, my = self:mouse_position()
        self[my][mx] = EMPTY
        is_first = true
    end
    
    if self[y][x] ~= what then
        return
    end
    
    self[y][x] = EMPTY

    if x < self.width then
        self:eat(x + 1, y, what)
    end
    if y < self.height then
        self:eat(x, y + 1, what)
    end
    if 1 < x then
        self:eat(x - 1, y, what)
    end
    if 1 < y then
        self:eat(x, y - 1, what)
    end

    if is_first then
        self[y][x] = MOUSE
    end
end

function test()
    print "main"
    local board = Board:new(6, 4)
    print(board)

    board:fill_random()
    board[1][1] = MOUSE
    board[board.height][board.width] = CHEESE
    print(board)

    assert(board:is_legal(2,1))
    assert(board:is_legal(1,2))
    
    board:eat(2,1)
    print(board)
    
end


if not package.loaded[...] then
    --main case
    test()
else --module case
end
