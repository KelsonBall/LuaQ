# LuaQ

## Inspired by Linq

LuaQ is a set of functions for manipulating iterators in a similar fashion to the popular System.Linq library in dotnet.

### Example

Include the library

    local query = require('query')

Using queries

    -- the identity property of queries
    local q = query{ 1, 2, 3, 4 }

    -- iterate through the query
    for item in q.list() do
        print(item)
    end
    -- prints [1, 2, 3, 4]

    -- shorthand for printing a query
    q:print() -- prints [1, 2, 3, 4]

    -- you can also create queries from other iterators
    local q = query(query.range(1, 5))

    q:print() -- [1, 2, 3, 4, 5]

Filtering

    -- to filter a query pass a predicate to the where method
    function isEven(value)
        return value % 2 == 0
    end

    local q = query{1, 2, 3, 4}:where(isEven)

    q:print() -- [2, 4]

    -- you may prefer to use anonymous functions
    local q = query{1, 2, 3, 4}:where(function (v) return v % 2 == 0 end)

    q:print() -- [2, 4]

    -- you can also pass lambda strings such as this
    local q = query{1, 2, 3, 4}:where('v -> v % 2 == 0')

    q:print() -- [2, 4]

Transforming

    -- to transform or select data from an item, use the select method
    local q = query{1, 2, 3, 4}:select('v -> v * v')

    q:print() -- [1, 4, 9, 16] 

    -- you can continue to chain together operations
    local q = query(query.range(1,10))
                    :select('v -> v * v')
                    :select('v -> tostring(v)')
                    :where('s -> string.len(s) ~= 2')
    
    q:print() -- [1, 4, 9, 100]                    

Enumeration

    -- For most operations, each operation is applied once to each peice of data
    local q = query{1, 2, 3, 4}
                    :where(function (v)
                        print("First operation, " .. v)
                        return v == 3
                    end)
                    :select(function (v)
                        print("Second operation, " .. v)
                        return "(" .. v .. ")"
                    end)

    q:print()
    -- output:
    First operation, 1
    First operation, 2
    First operation, 3
    Second operation, 3
    (3) 
    First operation, 4

Operations that return a new query execute only when they are enumerated.
Other operations that return specific values or have to look all of the data to return the next item execute immediately. 

Aggregate

    -- sum a list using aggregate
    local sum = query{1, 2, 3, 4}:aggregate('value, accumulator -> value + accumulator', 0)

    print(sum) -- 10

    local cat =  query{1, 2, 3, 4}:aggregate('value, accumulator -> value .. accumulator', '')

    print(cat) -- 4321

First, FirstOrDefault, Single, etc

    -- select first item
    local q = query{1, 2, 3, 4}:first() -- 1

    local q = query{1, 2, 3, 4}:first('v -> v > 10')
    Error: No item matched predicate

    local q = query{1, 2, 3, 4}:firstOrDefault('v -> v > 10') -- nil

    local q = query{1, 2, 3, 4}:single('v -> v == 1') -- 1

    local q = query{1, 2, 3, 4}:single()
    Error: More than 1 item matched predicate

    local q = query{1, 2, 3, 4}:single('v -> v < 2 or v > 3')
    Error: More than 1 item matched predicate

    local q = query{1, 2, 3, 4}:any() -- true

    local q = query{1, 2, 3, 4}:any('v -> v > 10') -- false    

    local q = query{1, 2, 3, 4}:contains(3) -- true

    local q = query{1, 2, 3, 4}:contains("3") -- false

Skip, Take

    local q = query{1, 2, 3, 4}:skip(1) -- [2, 3, 4]

    local q = query{1, 2, 3, 4}:take(1) -- [1]



