library("readxl")
library(arules)
library(xlsx)

args<-commandArgs(TRUE)

print(args[1])
print(args[2])

inputFile <- args[1]
outputFile <- args[2]
my_data <- read_excel(inputFile)


print.default(my_data)

table(my_data$categoria <-discretize(as.numeric(my_data$valence), method = "cluster", breaks = 3, labels = FALSE))
table(my_data$range <-discretize(as.numeric(my_data$valence), method = "cluster", breaks = 3, labels = NULL))
write.xlsx(my_data, file = outputFile)
hist(my_data$valence, breaks=20, main="K-Means")
abline(v=discretize(my_data$valence, method="cluster", categories=3, onlycuts=TRUE), col="red")

