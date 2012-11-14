--[[
General lua tools.

]]

function table.key_to_str ( k )
    if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" ) then
        return k
    else
        return "[" .. table.val_to_str( k ) .. "]"
    end
end

function table.val_to_str ( v )
    if "string" == type( v ) then
        v = string.gsub( v, "\n", "\\n" )
        if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
            return "'" .. v .. "'"
        end
        return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
    else
        if "table" == type( v ) then
            return table.tostring( v )
        else
            return tostring(v)
        end
    end
end

function table.tostring(tbl)
    --Wtf lua, how am I supposed to debug stuff without this?
    local result, done = {}, {}
    for k, v in ipairs(tbl) do
        table.insert( result, table.val_to_str( v ) )
        done[k] = true
    end
    for k, v in pairs(tbl) do
        if not done[ k ] then
            table.insert( result,
            table.key_to_str( k ) .. "=" .. table.val_to_str( v ) )
        end
    end
    return "{" .. table.concat( result, "," ) .. "}"
end



-- Thanks to: http://stackoverflow.com/questions/8722620/lua-comparing-two-index-tables-by-index-value
-- This is not clever enough to find matching table keys
-- i.e. this will return false
--   recursive_compare( { [{}]:1 }, { [{}]:1 } )
-- but this is unusual enough for me not to care ;)
-- It can also get stuck in infinite loops if you use it on 
-- an evil table like this:
--     t = {}
--     t[1] = t

function recursive_compare(t1,t2)
  -- Use usual comparison first.
  if t1==t2 then return true end
  -- We only support non-default behavior for tables
  if (type(t1)~="table") then return false end
  -- They better have the same metatables
  local mt1 = getmetatable(t1)
  local mt2 = getmetatable(t2)
  if( not recursive_compare(mt1,mt2) ) then return false end

  -- Check each key-value pair
  -- We have to do this both ways in case we miss some.
  -- TODO: Could probably be smarter and not check those we've 
  -- already checked though!
  for k1,v1 in pairs(t1) do
    local v2 = t2[k1]
    if( not recursive_compare(v1,v2) ) then return false end
  end
  for k2,v2 in pairs(t2) do
    local v1 = t1[k2]
    if( not recursive_compare(v1,v2) ) then return false end
  end

  return true  
end

Set = {}
Set.mt = { __index = Set }

function Set:new()
    local object = {}
    setmetatable(object, Set.mt)
    return object
end

function Set:add(item)
    -- hash as key
    assert(item ~= nil)
    local hash = table.tostring(item)
    self[hash] = item
end

function Set:contains(item)
    assert(item ~= nil)
    local hash = table.tostring(item)
    if self[hash] == nil then
        return false
    else
        return true
    end
end

function Set.mt:__tostring()
    local result = {}
    for hash, val in pairs(self) do
        table.insert(result, table.tostring(val))
    end
    return "{" .. table.concat(result, ",") .. "}"
end

function Set.mt:__eq(other)
    return recursive_compare(self, other)
end

function test()
    assert(    recursive_compare( {1,2,3,{1,2,1}}, {1,2,3,{1,2,1}} ) )
    assert(not recursive_compare( {1,2,3,{1,2,1}}, {1,2,3,{2,1,1}} ) )
    assert(not recursive_compare( {1,2,3,{1,2,1}}, {2,2,3,{1,2,1}} ) )
    
    local s = Set:new()
    s:add({x=1, y=2})
    s:add({x=2, y=3})

    -- check if a new point is equally hashed to the first one
    assert(s:contains({x=1, y=2}))
    print(s)
end


if not package.loaded[...] then
    --main
    test()
else --module require
end
