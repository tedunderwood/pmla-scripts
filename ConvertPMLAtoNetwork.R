# Theta convert to correlation matrix

DummyVar <- readline("Ready to select Theta file (topic relations to documents)? ")
cat('\n')
file <- file.choose()
	
Theta <- as.matrix(read.table(file, sep = ","))
cat('Theta read in. Now processing document information; may take 5 min.\n\n')

topics = dim(Theta)[1]
cormatrix = array(data = 0, dim = c(topics,topics))
topicsizes = numeric(topics)

for (i in 1:topics) {
	topicsizes[i] = sum(Theta[i,])
	for (j in 1: topics) {
		cormatrix[i, j] = cor(Theta[i, ], Theta[j,], method = "pearson")
		}
	}
outputpath = readline(prompt="path for output, ending with a slash?")
outfile = paste(outputpath, "cormatrix.txt", sep ="")
print('Correlation matrix written as cormatrix.') 
write.table(cormatrix, outfile, row.names = FALSE, col.names = FALSE, sep = ',')

biggesttopic = max(topicsizes)

relativetopicsizes = topicsizes / biggesttopic

docidfilename = paste(outputpath, "DocIDs.txt", sep="")

DocIDs <- scan(file=docidfilename, what = character(10000))

# Load metadata.
DummyVar <- readline("Ready to select articledates.tsv? (you don't have to say 'y,' just hit return) ")
cat('\n')
file <- file.choose()

Metadata <- read.table(file, header = TRUE, stringsAsFactors=FALSE, sep = '\t', fill = TRUE, nrows = 10000, quote = '"')

Documents <- as.character(Metadata$articleID)
DocDates <- as.numeric(Metadata$date)
names(DocDates) <- Documents

DocDates <- DocDates[DocIDs]

meandates = numeric(topics)
# normalize Theta to a unit vector and use that vector to calculate mean date
for (i in 1: topics) {
	Theta[i, ] <- Theta[i ,] / topicsizes[i]
	meandates[i] <- sum(DocDates * Theta[i,])
	}
	
DummyVar <- readline("Ready to select topic label file? ")
cat('\n')
file <- file.choose()
topiclabels <- scan(file, what = character(topics), sep = '\n')

topicmetadata = data.frame(size = relativetopicsizes, meandate = meandates, labels = topiclabels)

outfile = paste(outputpath, "topicmetadata.txt", sep = "")
write.table(topicmetadata, outfile, row.names=FALSE, col.names = FALSE, sep = '\t', quote=FALSE)
print('Metadata written as topicmetadata.')
	