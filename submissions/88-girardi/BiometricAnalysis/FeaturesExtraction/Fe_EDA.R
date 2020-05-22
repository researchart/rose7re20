#returns a vector with all EDA features

getFeatures_EDA<-function(baseline_values, interval_values){
  
  
  EDA_normalized <- normalizeDataByBaseline(baseline_values, interval_values)
  
 
  EDA_preprocessed <- EDA_preprocessing(EDA_normalized)
  
  
  
  SkinConductivityResponse <- kbk_scr(signal=EDA_preprocessed$phasic,
                    sampling_rate=4,
                    min_amplitude=0.1)
  
  
  mean_SCL <-getMeanSCL(EDA_preprocessed$tonic)
  AUC_Phasic <-getAUCPhasic(EDA_preprocessed$phasic)
  min_peak_amplitude <- getMinPeakAmplitude(SkinConductivityResponse$amplitudes)
  max_peak_amplitude <- getMaxPeakAmplitude(SkinConductivityResponse$amplitudes)
  #num_phasic_peaks <- getNumOfPhasicPeak(SkinConductivityResponse$peaks)
  mean_phasic_peak <- getMeanOfPhasicPeaks(SkinConductivityResponse$amplitudes)
  sum_phasic_peak_amplitude <- getSumOfPhasicPeakAmplitude(SkinConductivityResponse$amplitudes)
  
  EDA_features <- c(mean_SCL, AUC_Phasic, min_peak_amplitude, max_peak_amplitude, mean_phasic_peak, sum_phasic_peak_amplitude )
  
  
  return(EDA_features)
  
}


#returns the mean tonic signal, normalised with a baseline
#tonic component represents the skin conductance level(SCL)
getMeanSCL <- function(values){
  
  meanSCL <- mean(values)
  
  return(meanSCL)
}

#returns the area under the curve (AUC) of the phasic signal, normalised with a baseline
getAUCPhasic <- function(values){
  
  Fs <-4
  tm <- seq(from = 0, length.out = length(values) , by = 1/Fs)
  AUCPhasic <- auc(tm, values)
  
  return(AUCPhasic)
}

#returns the minimum peak amplitude of the phasic signal

getMinPeakAmplitude <- function(amplitudes){
  
 
  if(length(amplitudes >0))
    min <- min(amplitudes)
  else
    min <-0
  
   return(min)
  
}

#returns the maximum peak amplitude of the phasic signal
getMaxPeakAmplitude <-function(amplitudes){
  
 
  if(length(amplitudes >0))
    max <- max(amplitudes)
  else
    max <-0
 
  return(max)
  
}

#returns the number of peaks in the phasic signal
getNumOfPhasicPeak <-function(peaks){
  
  n <- length(peaks)
  
  return(n)
}

#returns the mean phasic peak amplitude of the phasic signal
getMeanOfPhasicPeaks <-function(amplitudes){
  
  sum <-0
  mean <- 0
  
  
  if(length(amplitudes)>0){
    for(i in 1:length(amplitudes))
      sum <-sum + amplitudes[i]
    
    mean <- sum/length(amplitudes)
  }
  else 
    mean <- 0
    
  
  return(mean)
}

#returns the sum of phasic peak amplitudes of the phasic signal
getSumOfPhasicPeakAmplitude <- function(amplitudes){
  
  sum <-0
 
  if(length(amplitudes)>0){
    for(i in 1:length(amplitudes))
      sum <-sum + amplitudes[i]
  }
  else 
      sum <-0
      
     
  return(sum)
}


