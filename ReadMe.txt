ReadMe for PMLA workflow

I wish I could make this more plug-and-play than it is. Right now, this may be a useful guide for you -- if you can code, and if you know Gephi or are willing to spend 3 hours learning it. But it's nowhere near plug-and-play.

Some of the files here are simply data structures for my 1924-2006 model. These include

MergedMetadata.csv
articledates.tsv
pmlaPHI.txt (top words for each topic)
pmlaTHETA.txt (a document-topic matrix where each cell indicates number of words in that topic in that document)
topiclabels.txt
topicmetadata.txt (size, age, label)
topicsummary.txt (key words for each topic)
nodes.csv
edges.csv ("spreadsheet" files that can be imported into Gephi)

The other files are scripts I used to transform my topic model into a network graph.

If you're still transforming the raw downloads from JSTOR into collated metadata, it's probably better to start with Andrew Goldstone's scripts, I haven't included all of that here. It was a messy process for us because JSTOR didn't at first give us article titles. We had to ask a second time. So, there were multiple versions.

But, say you've selected a subset of the corpus and run it through some LDA process (mine or more likely MALLET.) MetdataMerger.R is designed to select a subset of the overall collection metadata, using a list of document IDs (i.e., article IDs) produced by the topic modeler itself. Mine produces such a list automatically.

My modeling algorithm also produces a file called "PHI" that lists words in order of salience for each topic. translatePHI.py converts that file into a more standard MALLET-like list of "keys."

The next stage is to run ConvertTopicModel.R; this produces a correlation matrix and topic metadata (i.e., information like relative size and mean date for each topic).

Then run MakeGephi.py to turn the correlation matrix into a model, by selecting top edges for each node. The algorithm selects at least one edge for each node, and includes more edges if the correlations are strong enough, with a bias to having at least two edges per node.
