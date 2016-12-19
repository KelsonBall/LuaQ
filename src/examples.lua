local query = require('query')

function Example_PrintAQuery()
    local q = query{1, 2, 3, 4}

    q:print() -- 1, 2, 3, 4
end

function Example_EnumerateAQuery()
    local q = query{1, 2, 3, 4}

    for item in q.list() do
        print(item) -- 1, 2, 3, 4
    end
end

function Example_Where_LocalFunction()
    function even(value)
        return value % 2 == 0
    end

    local q = query{1, 2, 3, 4}:where(even)
    
    q:print() -- 2, 4
end

function Example_Where_AnonFunction()
    local q = query{1, 2, 3, 4}:where(function (v) return v % 2 == 0 end)

    q:print() -- 2, 4
end

function Example_Where_LambdaString()
    local q = query{1, 2, 3, 4}:where('v -> v % 2 == 0')

    q:print() -- 2, 4
end

function Example_IteratorSource()    
    function iterator()
        local count = 0 -- expose this value through getNext function (this is a clojure)
        function getNext() -- create a function that gets the next value
            count = count + 1
            if count <= 10 then
                return count 
            else
                return nil -- iterators return nil when they are complete
            end
        end
        return getNext -- return the function that iterates
    end

    local q = query(iterator)

    q:print() -- 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
end

function Example_WhereWithIterator_LambdaString()
    local q = query(query.range(1,10)):where('v -> v % 2 == 0')

    q:print() -- 2, 4, 6, 8, 10
end

function Example_TransformWithSelect_Double_LocalFunction()
    function double(value)
        return value * 2
    end

    local q = query{1, 2, 3, 4}:select(double)

    q:print() -- 2, 4, 6, 8
end

function Example_TransformWithSelect_Square_LocalFunction()
    function square(value)
        return value * value
    end

    local q = query{1, 2, 3, 4}:select(square)

    q:print() -- 1, 4, 9, 16
end

function Example_TransformToString_Square_LambdaString()
    local q = query(query.range(1, 10)):select('v -> v * v')
                                       :select('v -> tostring(v)')
                                       :where('s -> string.len(s) ~= 2')
    
    q:print() -- 1, 4, 9, 100
end

function Example_Aggregate_Sum()
    -- sums the values in the query 
    local q = query{1, 2, 3, 4}:aggregate('v,a -> v + a', 0)

    -- aggregate returns a single value, not a query
    print(q) -- 10
end

function Example_Aggregate_BuildString()
    -- lambda strings only support single statements, use anon functions for more complex behavior
    local q = query{"Bob", "Sally", "Anne"}
                :where('s -> string.len(s) > 3')
                :aggregate(function (s, a)
                  if a == nil then
                      return s
                  end
                  return a .. ", " .. s
                end)

    print(q) -- Sally, Anne
end

function Example_First()
    
end 
