# Load metadata.
DummyVar <- readline("Ready to select DocIDs? (you don't have to say 'y,' just hit return) ")
cat('\n')
file <- file.choose()

DocIndices <- as.character(scan(file))

DummyVar <- readline("Ready to select merged metadata? (you don't have to say 'y,' just hit return) ")
cat('\n')
file <- file.choose()

NewMeta <- read.table(file, header = FALSE, stringsAsFactors=FALSE, sep = '\t', fill = TRUE, nrows = 10000, quote = '"')

articleIDs <- as.character(NewMeta$V1)
authors <- NewMeta$V3
titles <- NewMeta$V4
names(authors) <- articleIDs
names(titles) <- articleIDs

DummyVar <- readline("Ready to select article dates file? (you don't have to say 'y,' just hit return) ")
cat('\n')
file <- file.choose()

Metadata <- read.table(file, header = TRUE, stringsAsFactors=FALSE, sep = '\t', fill = TRUE, nrows = 10000, quote = '"')

Documents <- as.character(Metadata$articleID)
DocDates <- as.numeric(Metadata$date)
names(DocDates) <- Documents
Documents <- Documents[Documents %in% DocIndices]
DocDates <- DocDates[DocIndices]
authors <- authors[DocIndices]
titles <- titles[DocIndices]

doccount <- length(DocIndices)

DummyVar <- readline("Ready to select Phi (topic distributions over words)? ")
cat('\n')
file <- file.choose()

FileLines <- readLines(con = file, n = -1, encoding = "UTF-8")
TopicCount <- as.integer(FileLines[1])
FileLines <- FileLines[-1]

Topic = 1
Phi <- vector("list", TopicCount)
for (Line in FileLines) {
	Prefix <- substr(Line, 1, 5)
	if (Prefix == "Topic") next
	if (Prefix == "-----") {
		Topic = Topic + 1
		next
		}
	Phi[[Topic]] <- c(Phi[[Topic]], Line)
	}

AllWords <- character(0)
for (i in 1: TopicCount) {
	AllWords <- union(AllWords, Phi[[i]])
	}

DummyVar <- readline("Ready to select Theta file (topic relations to documents)? ")
cat('\n')
file <- file.choose()
	
Theta <- as.matrix(read.table(file, sep = ","))
cat('Theta read in. Now processing document information; may take 5 min.\n\n')

KL <- vector("list", TopicCount)
for (i in 1: TopicCount) {
	Correlations <- numeric(TopicCount)
	for (j in 1: TopicCount) {
		Correlations[j] = cor(Theta[i, ], Theta[j, ], method = "pearson")
		if (i == j) Correlations[j] = -1
		}
	names(Correlations) <- 1:TopicCount
	Correlations <- sort(Correlations, decreasing = TRUE)
	KL[[i]] <- as.integer(names(Correlations[1:5]))
	}
	
# Create topic sizes.
TopicSize <- integer(TopicCount)
for (i in 1: TopicCount) {
	TopicSize[i] <- sum(Theta[i, ])
	}

# Create document sizes.
DocSize <- integer(doccount)
for (i in 1: doccount) {
	DocSize[i] <- sum(Theta[ , i])
	}

# Rank topics
TopicBulk <- TopicSize
TopicRanks <- integer(TopicCount)
names(TopicSize) <- 1:TopicCount
TopicSize <- sort(TopicSize, decreasing = TRUE)
for (i in 1: TopicCount) {
	TopicRanks[i] <- which(names(TopicSize) == as.character(i))
	}

NumDocs <- length(Documents)

MinDate = min(DocDates)
MaxDate = max(DocDates)
Timespan = (MaxDate - MinDate) + 1
TotalsPerYear <- integer(Timespan)

ThetaSum <- array(data=0, dim = c(TopicCount, Timespan))
for (i in 1: NumDocs) {
	DateIndex = (DocDates[i] - MinDate) + 1
	ThetaSum[ , DateIndex] = ThetaSum[ , DateIndex] + Theta[ , i]
	}

for (i in 1: Timespan) {
	TotalsPerYear[i] = sum(ThetaSum[ , i])
	}

for (i in 1: TopicCount) {
	HoldVector = ThetaSum[i ,] / TotalsPerYear
	ThetaSum[i ,] <- HoldVector
	}
	
par(mar = c(4,4,4,20))
par(adj = 0)
repeat {
	Proceed = FALSE
	while (!Proceed) {
		Word <- readline('Enter a word or a topic#: ')
		TopNum <- suppressWarnings(as.integer(Word))
		if (!is.na(TopNum) | Word %in% AllWords | Word %in% Documents) Proceed = TRUE
		else cat("That wasn't a valid entry, perhaps because we don't have that word.", '\n')
		}
	
	# The following section deals with the case where the user has
	# entered a word to look up.
	
	if (Word %in% AllWords) {
		Hits <- numeric(0)
		NumHits <- 0
		Indices <- numeric(0)
		for (i in 1: TopicCount) {
			if (Word %in% Phi[[i]]) {
				NumHits <- NumHits + 1
				Hits <- c(Hits, which(Phi[[i]] == Word))
				Indices <- c(Indices, i)
				}
			}
		names(Hits) <- Indices
		Hits <- sort(Hits, decreasing = FALSE)
		cat('\n')
		if (NumHits > 5) NumHits <- 5
		for (i in 1: NumHits) {
			Top <- as.integer(names(Hits[i]))
			cat("Topic", Top, ":", Phi[[Top]][1], Phi[[Top]][2], Phi[[Top]][3], Phi[[Top]][4], Phi[[Top]][5], Phi[[Top]][6], Phi[[Top]][7], '\n')
			}
		User <- readline('Which of these topics do you select? ')
		TopNum <- as.integer(User)
		if (is.na(TopNum)) TopNum <- 1
		}
				
	if (TopNum < 1) TopNum <- 1
	if (TopNum > TopicCount) TopNum <- TopicCount	
	# By this point we presumably have a valid TopNum.
	
	cat('\n')
	
	# Generate smoothed curve.
	Smoothed <- numeric(Timespan)
	for (i in 1: Timespan) {
		Smoothed[i] = ThetaSum[TopNum, i]
		Smoothed[is.na(Smoothed)] <- 0
		}
	par(mar = c(4,4,4,20))	
	scatter.smooth(seq(MinDate, MaxDate), Smoothed*100, span = 0.33, col = "slateblue3", ylab = "% of words in the topic", xlab = "", main = paste('Topic', TopNum, ':', Phi[[TopNum]][1], Phi[[TopNum]][2], Phi[[TopNum]][3], Phi[[TopNum]][4], Phi[[TopNum]][5], Phi[[TopNum]][6], Phi[[TopNum]][7], Phi[[TopNum]][8]))
	
	cat('TOPIC', TopNum,':', Phi[[TopNum]][1:50], '\n')
	cat('OF', TopicCount, 'TOPICS this is #',TopicRanks[TopNum], 'in desc order, with', TopicBulk[TopNum], 'words. Related topics: \n')
	
	docsalience <- Theta[TopNum, ]/DocSize
	mostsalient <- order(docsalience, decreasing = TRUE)
	TopFour <- mostsalient[1:4]
	for (ordinal in TopFour) {
		cat(paste(authors[ordinal], titles[ordinal], as.character(DocDates[ordinal]), sep = ", "))
		cat('\n')
		}
	cat('\n')
	}
		
	