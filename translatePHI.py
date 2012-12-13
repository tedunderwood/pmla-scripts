filepath = input('Path and filename for the model/phi file for the topic you are converting: ')

with open(filepath, encoding='utf-8') as file:
    filelines = file.readlines()

counter = 0
wordcount = 0
outline = ""
outlist = list()
firstwords = list()
labeledyet = False

for line in filelines:
    if line.startswith("-"):
        counter = counter + 1
        wordcount = 0
        outlist.append(outline)
        outline = ""
        continue
    if "Topic" in line or "150" in line:
        continue
    if wordcount < 1:
        outline = str(counter) + ": "
    if wordcount < 13:
        thisword = line.strip()
        outline = outline + thisword + " "
        if not labeledyet and thisword not in firstwords:
            firstwords.append(thisword)
            labeledyet = True
        wordcount = wordcount + 1
    elif wordcount == 13:
        outline = outline + '\n'
        wordcount = wordcount + 1
        labeledyet = False

filepath = input('Just path for output, should end with slash: ')
outfile = filepath + 'topicsummary.txt'

with open(outfile, mode='w', encoding='utf-8') as file:
    for line in outlist:
        file.write(line)

outfile = filepath + 'topiclabels.txt'
with open(outfile, mode='w', encoding='utf-8') as file:
    for word in firstwords:
        file.write(word + '\n')
print('Done.')
