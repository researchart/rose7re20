# enable commandline arguments from script launched using Rscript
args<-commandArgs(TRUE)

#input_dir <- args[1]
#labels_file <- args[2]

labels_file <- "Labels_final.csv"

#read Empatica dataset

EDA_dataset_file<- paste(input_dir,"EDA_dataset.csv", sep = "/")
BVP_dataset_file <- paste(input_dir, "BVP_dataset.csv", sep = "/")
HR_dataset_file <- paste(input_dir, "HR_dataset.csv", sep = "/")

EDA<- read.csv2(EDA_dataset_file, sep = ",")
BVP<- read.csv2(BVP_dataset_file, sep = ",")
HR<- read.csv2(HR_dataset_file, sep = ",")
#HRV<- read.csv2(HRV_dataset_file, sep = ",")

l_EDA <- ncol(EDA) - 2
l_BVP <- ncol(BVP) - 2
l_HR <- ncol(HR) - 2
Empatica_dataset <- data.frame(EDA[1:l_EDA],BVP[2:l_BVP], HR[2:l_HR] )

#write.csv(Empatica_dataset, "Empatica.csv", row.names = FALSE, quote = FALSE)

labels<- read.csv2(labels_file, sep = ",")
valence <- labels$Valence
arousal <- labels$Arousal

Empatica <- cbind(Empatica_dataset,valence)
Empatica <- cbind(Empatica,arousal)

write.csv(Empatica, "Empatica_3labels.csv", row.names = FALSE, quote = FALSE)

#create dataset with two labels for valence
Empatica_valence <- cbind(Empatica_dataset,valence)
Empatica_valence <- Empatica_valence[!Empatica_valence$valence == "neutral", ]

write.csv(Empatica_valence, "Empatica_2labels_valence.csv", row.names = FALSE, quote = FALSE)

#create dataset with two labels for arousal
Empatica_arousal <- cbind(Empatica_dataset,arousal)
Empatica_arousal <- Empatica_arousal[!Empatica_arousal$arousal == "neutral", ]

write.csv(Empatica_arousal, "Empatica_2labels_arousal.csv", row.names = FALSE, quote = FALSE)


