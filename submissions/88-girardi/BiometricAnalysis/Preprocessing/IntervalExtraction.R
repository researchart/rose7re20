


#return a vector containing the timestamps of the interruptions 
getTimestamps <- function (intervals_file, pattern){
  
  interruptions_timestamps <- c()
  interruptions_seconds <- c()
  interruptions_valence <- c()
  interruptions_arousal <- c()
  
    conn <- file(intervals_file,open="r")
    lines <- readLines(conn)
    
    for (i in 1:length(lines)){
      
      if(grepl(pattern = pattern, lines[i]) == TRUE){
        s <- strsplit(lines[i], ",")
        s <- unlist(s)
        interruptions_timestamps <- c(interruptions_timestamps, s[1])
        interruptions_seconds <- c(interruptions_seconds, s[3])
        interruptions_valence  <- c(interruptions_valence, s[4])
        interruptions_arousal  <- c(interruptions_arousal, s[5])
        }
    }
    
    close(conn)
     
    df_questions <-data.frame(interruptions_timestamps,interruptions_seconds, interruptions_valence, interruptions_arousal )
    colnames(df_questions) <- c("Timestamp", "Seconds", "Valence", "Arousal")
    return(df_questions)
    

}


getBaselineData <- function(intervals_file, data_file, signal){
  
 
   conn <- file(intervals_file,open="r")
   lines <- readLines(conn)
   close(conn)
   
   s <- strsplit(lines[3], ",") #in line 3 is contained the timestamp of end_baseline
   s <- unlist(s)
   
     
   if(as.character(s[1]) == "N/A"){
     start <- "all_EmpaticaData"
     
   }
   else
   {
     start <- as.numeric(as.character(s[1]))
   }
   
   # when timestamp is not specified ( part of emotion elicitation not recorded), use the data from the entire file
   if(start == "all_EmpaticaData"){
     values <- read.csv(data_file, sep = ",")
     values <- values[3: nrow(values),] 
   }
   else
     values <- getSignalValues(signal, data_file, start, "undefined")
   
  
}


  
#returns the the values between the timestamp and the successive seconds
getSignalValues <- function(signal, file, timestamp, seconds ){
  
  all_values <- read.csv(file, header=FALSE, sep="")
  #print(typeof(all_values[1,1]))
  start_recording_timestamp <- as.numeric(all_values[1,1])
    
  #convert in Date type the UNIX timestamp saved when the application started to record signals data
  start_recording_timestamp <- anytime(start_recording_timestamp)
  start_recording_timestamp <- strftime(start_recording_timestamp, format="%H:%M:%S")
  start_recording_timestamp <- hms(start_recording_timestamp)
   #convert in Date type the Unix timestamp of the interruption
  interruption <- as.numeric(as.character(timestamp))
  interruption <- anytime(interruption)
  interruption <- strftime(interruption, format="%H:%M:%S")
  
  #se i secondi non sono specificati, end_interval coincide con l'ultima riga del file
  if(seconds == "undefined"){
    
    start_interval <- hms(interruption) 
    start_recording_timestamp_seconds <- as.numeric(start_recording_timestamp) 
    start_interval_seconds <- as.numeric(start_interval)
    elapsedSeconds_FromRecording_ToStartInterval <- start_interval_seconds - start_recording_timestamp_seconds
    sample_frequency <- all_values[2,1] #sample frequency is stored in the second row of the file
    start_index <- (elapsedSeconds_FromRecording_ToStartInterval*sample_frequency) + 3
    end_index <- nrow(all_values)
    
    
    values <- c()
    values <- all_values[start_index:end_index,1] #E4 saves values in the first column of the file
    
  }
  else{
  start_interval <- hms(interruption) 
  seconds <- as.numeric(as.character(seconds))
  end_interval <- start_interval + seconds #determine the lower bound of interval based on how many seconds have to be analyzed
  #convert timestamps in number of seconds
  start_recording_timestamp_seconds <- as.numeric(start_recording_timestamp) 
  start_interval_seconds <- as.numeric(start_interval)
  end_interval_seconds <- as.numeric(end_interval)
  
  
  #determine how many seconds have elapsed between the start of recording data and the interval
  elapsedSeconds_FromRecording_ToStartInterval <- start_interval_seconds - start_recording_timestamp_seconds
  elapsedSeconds_FromRecording_ToEndInterval <- end_interval_seconds - start_recording_timestamp_seconds
  #print(paste("number of seconds between start recording and start interval: ", elapsedSeconds_FromRecording_ToStartInterval ))
  #print(paste("number of seconds between start recording and end interval: ", elapsedSeconds_FromRecording_ToEndInterval ))
  

  sample_frequency <- all_values[2,1] #sample frequency is stored in the second row of the file
    
  #print(paste("signal:", signal) )
  #print(paste("sample_frequency:", sample_frequency))
  
  
    #start_index + 3: 
    #+2 because start_recording relies on the seconds line of the file
    #+1 because the first of the seconds to included relies on the next line of start interval calculated  #(otherwise we'll analyze n+1 seconds)
    #end_index + 2 because start_recording relies on the seconds line of the file
  
    start_index <- (elapsedSeconds_FromRecording_ToStartInterval*sample_frequency) + 3
    end_index <- (elapsedSeconds_FromRecording_ToEndInterval*sample_frequency) + 2
  
    values <- c()
    
    #save in values only data related to the interval of interest
  
  values <- all_values[start_index:end_index,1] #E4 saves values in the first column of the file
  }
    
  
  return(values)
  
}


  

