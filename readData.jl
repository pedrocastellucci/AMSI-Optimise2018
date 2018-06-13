function readData(filename)
    data = readcsv(filename)

    nSuppliers, nConsumers = data[1,1:2]
    posMatrixAux = data[3:3+nSuppliers+nConsumers, 2:3]
    dMatrixAux = data[3+nSuppliers:3+nSuppliers+nConsumers-1, 4:4+nSuppliers-1]

    suppliers = 1:nSuppliers
    consumers = nSuppliers+1:nSuppliers + nConsumers
    warehouse = nSuppliers + nConsumers + 1: nSuppliers + nConsumers +1
    nodes = 1:warehouse[end]

    posX = Dict{Int, Float64}()
    posY = Dict{Int, Float64}()
    for i in nodes
        posX[i] = posMatrixAux[i,1]
        posY[i] = posMatrixAux[i,2]
    end

    cost = Dict{Tuple{Int, Int}, Float64}()
    for i in nodes, j in nodes
        cost[i, j] = sqrt((posX[i] - posX[j])^2 + (posY[i] - posY[j])^2)
    end

    demand = Dict{Tuple{Int, Int}, Int}()
    for (i, c) in enumerate(consumers), (j, s) in enumerate(suppliers)
        demand[c, s] = dMatrixAux[i, j]
    end

    suppliers, consumers, warehouse, nodes, posX, posY, cost, demand
end


function canTruckTraverseEdge(s, i, j, suppliers)
    if i == j
        return false
    end

    if i in suppliers
        return i == s
    end

    if j in suppliers
        return j == s
    end

    return true
end


function preprocessing(nodes, suppliers, consumers, demand)

    suppliers = collect(suppliers)
    consumers = collect(consumers)
    nodes = collect(nodes)

    # Filtering out consumers without demands
    toRemove = []
    for i in consumers
        if sum(demand[i, s] for s in suppliers) <= 0.1
            push!(toRemove, i)
        end
    end

    filter!(i -> !(i in toRemove), consumers)
    filter!(i -> !(i in toRemove), nodes)

    edgeExists = Dict{Any, Any}()
    for i in nodes, j in nodes, s in suppliers
        edgeExists[s, i, j] = canTruckTraverseEdge(s, i, j, suppliers)
    end

    nodes, consumers, suppliers, edgeExists
end


function printSolution(m, suppliers, nodes, edgeExists)

    x = m[:x]
    T = 1:length(nodes)
    toPrint = "$(getobjectivevalue(m))\n"

    
    for s in suppliers, t in T, i in nodes, j in nodes
        if edgeExists[s, i, j] && (getvalue(x[i, j, s, t]) > 0.9)
            toPrint *= "$s $i $j\n"
        end
    end


    println(toPrint)
end


function separateZerosOnes(m)
    x = m[:x]
    y = m[:y]
    z = m[:z]

    varOnes, varZeros = [], []
    
    for (a, b, c, d) in keys(x)
        if getvalue(x[a, b, c, d]) > 0.5
            push!(varOnes, x[a, b, c, d])
        else
            push!(varZeros, x[a, b, c, d])
        end
    end
    
    for (a, b) in keys(y)
        if getvalue(y[a, b]) > 0.5
            push!(varOnes, y[a, b])
        else
            push!(varZeros, y[a, b])
        end 
    end
    
    for (a, b, c) in keys(z)
        if getvalue(z[a, b, c]) > 0.5
            push!(varOnes, z[a, b, c])
        else
            push!(varZeros, z[a, b, c])
        end
    end
    
    varZeros, varOnes
end