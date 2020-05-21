
source("libraries.R")
source("./Preprocessing/IntervalExtraction.R")
source("./Preprocessing/SignalsPreprocessing.R")
source("./FeaturesExtraction/FeaturesExtraction.R")
source("./FeaturesExtraction/Fe_BVP.R")
source("./FeaturesExtraction/Fe_EDA.R")
source("./FeaturesExtraction/Fe_HR.R")


utils <-import_from_path("utils", path = "./inst/", convert = TRUE)
tools <-import_from_path("tools", path = "./inst/", convert = TRUE)

source_python("./inst/cvxEDA.py")
source_python("./inst/kbk_scr.py")


# enable commandline arguments from script launched using Rscript
args<-commandArgs(TRUE)


getFiles <-function(E4_path ){
  
  EDA_file <- paste(E4_path, "EDA.csv", sep = "/")
  #TEMP_file <- paste(E4_path, "TEMP.csv", sep = "/")
  HR_file <- paste(E4_path, "HR.csv", sep = "/")
  BVP_file <- paste(E4_path, "BVP.csv", sep = "/")
  HRV_file <- paste(E4_path, "IBI.csv", sep = "/")
  
  files <- c(EDA_file, HR_file, BVP_file)
  
  return(files)
  
  
}


replaceNullValues <-function(features_vec, n_features){
 
  features_sep <-c()
  features_completed <-c()
  names <-c()
  features <-c()
  
  names <-c(as.character(seq(1:n_features)))
  features <- data.frame(features_vec)
  features <-separate(features,1,c(names), sep = ',') 
  #print(ncol(features))
  #print(nrow(features))
  features_adj<-c()
  
  #replace null valueof a feature with the median of the same subject calculated for that feature
  for(y in 1:ncol(features)){
    if(" NA" %in% features[,y]){
        m <-median(as.numeric(features[,y]), na.rm = TRUE)
      
      for(x in 1:length(features[,y]))
        if(features[x,y] == " NA")
          features[x,y]<-m
    }
    
  }
  
  for(z in 1:nrow(features))
    features_adj<-c(features_adj, toString(features[z,]))
  
  #print(features_adj)
  
  return(features_adj)
}



#START MAIN

data_path <- paste(getwd(), "DataSubjects", sep = "/" )
dirs <-list.dirs(path = data_path, full.names = TRUE, recursive = FALSE)
dirs <- mixedsort(sort(dirs))
dirs<-as.character(dirs)
print(dirs)


output_dir <- paste(getwd(), "Dataset", sep = "/")
if(!dir.exists(output_dir))
  dir.create(output_dir, showWarnings = FALSE, recursive = TRUE, mode = "0777")


signals <- c("EDA", "HR", "BVP")
output_files <- c(paste(output_dir,"EDA_dataset.csv", sep="/"),
                  paste(output_dir,"TEMP_dataset.csv", sep="/"), 
                  paste(output_dir,"HR_dataset.csv", sep="/"),
                  paste(output_dir,"BVP_dataset.csv", sep="/"))
                  #paste(output_dir,"HRV_dataset.csv", sep="/"))

EDA_header <- "id,mean_SCL, AUC_Phasic, min_peak_amplitude, max_peak_amplitude, mean_phasic_peak, sum_phasic_peak_amplitude,valence, arousal"
TEMP_header <- "id,mean_temp, mean_temp_difference, max_temp, max_temp_difference, min_temp, min_temp_difference,valence, arousal"
HR_header <- "id,HR_mean_difference, HR_variance_difference,valence, arousal"
BVP_header <- "id, mean_BVPpeaks_ampl, min_BVPpeaks_ampl, max_BVPpeaks_ampl, sum_peak_ampl,valence, arousal"
#HRV_header <- "id,sdnn, rmssd, valence, arousal"


write(EDA_header, paste(output_dir,"EDA_dataset.csv", sep="/"), append=FALSE)
write(TEMP_header, paste(output_dir,"TEMP_dataset.csv", sep="/"), append=FALSE)
write(HR_header, paste(output_dir,"HR_dataset.csv", sep="/"), append=FALSE)
write(BVP_header, paste(output_dir,"BVP_dataset.csv", sep="/"), append=FALSE)
#write(HRV_header, paste(output_dir,"HRV_dataset.csv", sep="/"), append= FALSE)

#cycle on each subject
#n<-1
#print(length(dirs))
for(n in 1: length(dirs)){
  
  print(paste("Analyzing data: ", dirs[n]))
  
  E4_path <- paste(dirs[n], "E4", sep = "/") #E4 generates files from E4 Empatica (EDA, Temp, HR, BVP)
  
  files <-getFiles(E4_path)
  
  intervals_file <- list.files(path = dirs[n], pattern = "*.csv")
  intervals_file <- paste(dirs[n], intervals_file, sep = "/")
  #baseline_values<- read.csv(intervals_file, header=FALSE, sep="")
   
  #For each signal
  #Extract the baseline
  
  #For each interruption
    #Extract the data of the interval that have to be processed
    #Extract features
    
  #Save all the features of the signal on file (one instance per task)
  
  i<-1
   for(i in 1: length(signals)){
     print(paste("Analyzing signal: ", signals[i]))
     baseline_values<- getBaselineData(intervals_file, files[i], signals[i])
     all_signal_features <- c()
     n_features <- 0
     #get all timestamps of interruption and extract the features related to signals during working task
     interruptions <- getTimestamps(intervals_file, "*question")
     l <- nrow(interruptions)
     for(k in 1:l){
        print(paste("interruption: ",k))
        interval_values <- getSignalValues(signals[i], files[i], interruptions$Timestamp[k], interruptions$Seconds[k])
        features <- extractFeatures(signals[i], baseline_values, interval_values)
        n_features <-length(features) + 3
        features <-toString(features)
        labels <- c(as.character(interruptions$Valence[k]), as.character(interruptions$Arousal[k]))
        labels <-toString(labels)
        #print(paste("labels", labels))
        id <- paste(paste(as.character(n),".", sep=""), k, sep="")
        instance <- paste(id, features,labels, sep = ", ")
        all_signal_features[k] <- instance
        
     }
     
    
     
    #check for null values
    features_replaced <- replaceNullValues(all_signal_features, n_features)
    
    #write on file the features of all the interruptions of one participant 
    write(features_replaced, file= output_files[i], append=TRUE)
    
    gc()
    rm()
  }
  
  print(paste("DONE:", dirs[n]))
  
  
}
rm(list=ls()) #remove all variables in the workspace



