filepath = input('Path to folder where topicmetadata and cormatrix are stored?')

metadata = filepath + "topicmetadata.txt"
with open(metadata, mode = 'r', encoding = 'utf-8') as file:
    filelines = file.readlines()

counter = 0
topiccount = len(filelines)

nodefile = filepath + "nodes.csv"
with open(nodefile, mode='w', encoding = 'utf=8') as file:
    file.write('Id;Label;Size;Age\n')
    for line in filelines:
        line = line.rstrip()
        fields = line.split('\t')
        node = str(counter)
        size = fields[0]
        age = fields[1]
        label = fields[2]
        counter = counter + 1
        outline = node + ";" + label + ";" + size + ";" + age + '\n'
        file.write(outline)

corpath = filepath + "cormatrix.txt"
with open(corpath, encoding = 'utf=8') as file:
    filelines = file.readlines()

counter = 0
edgelist = list()
for line in filelines:
    node = str(counter)
    parts = line.split(',')
    first = 0
    second = 0
    if counter == 0:
        first = 10
        second = 10
    weights = [0.0 for x in range(0, topiccount)]
    for i in range(0, topiccount):
        weights[i] = float(parts[i])
    for i in range(0, topiccount):                          
        thisweight = weights[i]
        if thisweight > weights[first] and i != counter:
            second = first
            first = i
        elif thisweight > weights[second] and i != counter:
            second = i
    numedges = 0
    for i in range(0, topiccount):
        weight = weights[i]
        if weight > 0.35 and i != counter:
            edge = node + ";" + str(i) + ";Undirected;" + parts[i]
            edgelist.append(edge)
            numedges += 1
    if numedges < 2 and weights[second] > .175 :
        topedge = node + ";" + str(second) + ";Undirected;" + parts[second]
        edgelist.append(topedge)
    if numedges < 1:
        topedge = node + ";" + str(first) + ";Undirected;" + parts[first]
        edgelist.append(topedge)
    
 
    counter = counter + 1

edgepath = filepath + "edges.csv"
with open(edgepath, mode = 'w', encoding = 'utf=8') as file:
    file.write("Source;Target;Type;Weight;\n")
    for line in edgelist:
        file.write(line + '\n')

print('Done')
    
                           
        
    
    
    
