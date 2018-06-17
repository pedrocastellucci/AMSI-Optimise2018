
import os, sys
import pandas
import networkx as nx
import matplotlib.pyplot as plt
import random

def readInstance(filename):
    
    with open(filename, 'r') as csvfile:
        inputData = pandas.read_csv(filename, header=None).as_matrix()
    
#     print(inputData)
    nSuppliers, nConsumers = int(inputData[0][0]), int(inputData[0][1])

    suppliers = range(1, nSuppliers + 1)
    consumers = range(nSuppliers + 1, nSuppliers + nConsumers + 1)
    cd = nSuppliers + nConsumers + 1
    
    inputData = inputData[2:]
    
    positions = {}

    for row in inputData:
        a, b, c = [int(r) for r in row[0:3]]
        positions[a] = b, c
        print(a, b, c)

    return suppliers, consumers, cd, positions
        


def readResult(filename):
    objValue = None
    suppliersRoute = {}
    
    with open(filename) as fd:
        for line in fd:
            words = line.split()
            if len(words) > 1:  # We only want the edges
                a, b, c = [int(x) for x in words]
                route = suppliersRoute.get(a, [])
                route.append((b, c))
                suppliersRoute[a] = route

    return suppliersRoute


filename = r"../data/data1.csv"
resultFile = sys.argv[1]

print(filename, resultFile)

suppliers, consumers, cd, positions = readInstance(filename)

costs = {}
for (i, (xi, yi)) in positions.items():
    for (j, (xj, yj)) in positions.items():
        costs[i, j] = ( (xi - xj)**2 + (yi -yj)**2 )**0.5
        
suppliersRoute = readResult(resultFile)

nodes = list(suppliers) + list(consumers) + [cd]

print(nodes, "nodes")
# print(positions)

graph = nx.DiGraph()
graph.add_nodes_from(nodes)

nx.draw_networkx_labels(graph, pos=positions, labels={a : a for a in nodes}, fontsize="x-large")
nx.draw(graph, pos=positions, nodelist=suppliers, node_size=600, node_color='r', label="Supplier")
nx.draw(graph, pos=positions, nodelist=consumers, node_size=600, node_color='g', label="Consumer")
nx.draw(graph, pos=positions, nodelist=[cd], node_size=600, node_color='b', alpha=0.7, label="Cross-dock")

totalCost = 0

colors = ['k', 'k']
styles = ['solid', 'dashed']
for (i, edges) in enumerate(suppliersRoute.values()):
    
    for (a, b) in edges:
#         print(a, b)
        totalCost += costs[a, b]
    
    graph.add_edges_from(edges)
    print(edges)
    nx.draw_networkx_edges(graph, pos=positions, edges_list=edges, edge_color=colors[i],
                           style=styles[i], width=2, alpha=0.6)

print("Total cost = ", totalCost)
  
plt.axis("on")
plt.grid()
plt.legend(loc='best', fontsize='xx-large')

plt.show()  

