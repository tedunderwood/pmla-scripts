# Merge Metadata. This loads all metadata, and then a list
# of DocIDs produced by LDA, and outputs a list of only 
# the metadata for those DocIDs in the right order.

# Load metadata.
DummyVar <- readline("Ready to select AllMetadata.txt? ")
cat('\n')
file <- file.choose()

Metadata <- read.table(file, stringsAsFactors=FALSE, sep = '\t', fill = TRUE, nrows = 6400, quote = '"', encoding = "UTF-8")

# Load metadata.
DummyVar <- readline("Ready to select DocIDs.txt? ")
cat('\n')
file <- file.choose()

Docs <- readLines(con = file, n = -1, encoding = "UTF-8")


row.names(Metadata) <- Metadata$V1
OutTable <- Metadata[Docs, ]
filepath = readline(prompt = 'Provide path and filename for metadata: ')
write.table(OutTable, file = filepath, quote = FALSE, sep = "\t", row.names = FALSE)
