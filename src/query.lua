local mt = {}
local query = {}

function mt.__call(self, source)
    print("ctor call")
    return (query:new(source)) 
end
setmetatable(query, mt)

function tableIter(t)
    local i = 0
    return function()
        i = i + 1
        if i > #t then
            return nil
        else
            return t[i]
        end
    end
end

function query:new(source)
    if type(source) == "table" then
        local tab = source
        source = function() 
            return tableIter(tab) 
        end
    end

    local t = {}    
    t.list = source
    
    setmetatable(t, query)
    self.__index = self    
    t.__index = t
    t.__call = function() return t.source() end
    return t  
end

function query:print()
    for i in self.list() do
      print(i)
    end
end



local typeoffunc = type(function() end)
local typeoftable = type({})
local typeofstring = type("")

function interpret(lambda)
    lambtype = type(lambda)
    if lambtype == typeoffunc then
        return lambda
    elseif lambtype == typeofstring then
        local argsEnd, expStart = string.find(lambda, "->")
        return loadstring("return function("..string.sub(lambda, 1, argsEnd - 1)..") return "..string.sub(lambda, expStart + 1).." end")()
    end
    error("Invalid lambda type")
end


function query:where(predicate)    
    local predicate = interpret(predicate)    
    local parent = self.list
    return query:new(function ()
        local iter = parent()
        return function()
            local value
            repeat
                value = iter()
                if value == nil then
                    return nil
                end
            until predicate(value)
            return value
        end
    end)
end


function query:select(func)
    local func = interpret(func)    
    local parent = self.list
    return query:new(function ()
        local iter = parent()
        return function()
            local value = iter()
            if value == nil then
                return nil
            end
            return func(value)        
        end
    end)
end

-- if the results of iter are iterators or tables, select from their items
function query:selectMany(func)
    error("not implemented")
end

function query:first(predicate)        
    local iter = self.list()
    local value = iter()
    if value == nil then
        error("Iterator was empty")        
    end
    if predicate then
        while not predicate(value) do
            value = iter()
            if value == nil then
                error("Iterator was empty")                
            end
        end
    end    
    return value    
end

function query:firstOrDefault(predicate)    
    local iter = self.list()
    local value = iter()
    if value == nil then        
        return nil
    end
    if predicate then
        while not predicate(value) do
            value = iter()
            if value == nil then                
                return nil
            end
        end
    end    
    return value            
end

function query:single(predicate)
    local iter = self:list()
    local value = iter()
    if value == nil then
        error("Iterator was empty")
        return nil
    else
        if iter() ~= nil then
            error("Iterator contained more than 1 item")
        end            
    end
    return value    
end

function query:orderBy(ranker)
    error("not implemented")
end

function query:orderByDescending(ranker)
    error("not implemented")
end

function query:skip(num)
    local parent = self.list
    return query:new(function ()
        local iter = parent()
        local completedEarly = false
        local count = 0
        return function()
            while count < num do
                count = count + 1
                if iter() == nil then
                    return nil
                end
            end
            return iter()
        end
    end)
end

function query:take(num)
    local parent = self.list
    return query:new(function ()
        local iter = parent()
        local count = 0
        return function()
            if count < num then
                count = count + 1
                return iter()
            else
                return nil
            end
        end
    end)
end

function query:aggregate(merge, init)  
    merge = interpret(merge)
    local iter = self.list()    
    local result = iter()
    while result ~= nil do
        init = merge(result, init)
        result = iter()
    end
    return init    
end

function query:toDictionary(keySelector, valueSelector)
    local valueSelector = valueSelector or (function(v) return v end)
    local dict = {}
    local iter = self.list()
    local result = iter()
    while result ~= nil do
        dict[keySelector(result)] = valueSelector(result)
        result = iter()
    end
    return dict
end

function query:toTable()
    local resultTable = {}
    local iter = self.list()
    local result = iter()
    while result ~= nil do
        resultTable[#resultTable + 1] = result
        result = iter()
    end
    return resultTable
end

function query.range(from, to)
    return function()
        local n = from - 1
        return function()
            n = n + 1
            if n <= to then
                return n
            end
            return nil
        end
    end
end

return query