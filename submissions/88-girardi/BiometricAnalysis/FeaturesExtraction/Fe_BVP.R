#https://www.biofeedback-tech.com/articles/2016/3/24/the-blood-volume-pulse-biofeedback-basics
#use ampd package https://cran.r-project.org/web/packages/ampd/index.html

getFeatures_BVP<-function(baseline_values, interval_values){
  
  BVP_normalized <- normalizeDataByBaseline(baseline_values, interval_values)
  BVP_preprocessed <- BVP_preprocessing(interval_values)  
  baseline_preprocessed <- BVP_preprocessing(baseline_values)
  
  
  peaks_interval <- AMPD(BVP_preprocessed, extended = TRUE)
  peaks_normalized <- AMPD(BVP_normalized, extended = TRUE)
  
  difference_BVPpeaks_ampl <- 0
  #difference_BVPpeaks <- getDifferenceBVPPeaks(peaks_interval, peaks_baseline) 
  #difference_BVPpeaks_ampl <- getDifferenceMeanBVPPeakAmplitude(baseline_preprocessed, peaks_baseline, BVP_preprocessed, peaks_interval ) 
  mean_BVPpeaks_ampl <- getMeanBVPPeakAmplitude(BVP_normalized, peaks_normalized)
  min_BVPpeaks_ampl <- getMinBVPPeakAmplitude(BVP_normalized,peaks_normalized)
  max_BVPpeaks_ampl <- getMaxBVPPeakAmplitude(BVP_normalized,peaks_normalized)
  sum_peak_ampl <- getSumPeakAmplitude(BVP_normalized,peaks_normalized)
  
 
  
  BVP_features <-c(mean_BVPpeaks_ampl, min_BVPpeaks_ampl, max_BVPpeaks_ampl, sum_peak_ampl)
  return(BVP_features)
  
}

#returns the number of peaks in the BVP signal, normalised by a baseline
getDifferenceBVPPeaks <-function(peaks_interval, peaks_baseline){
  
  BVPPeaks <- length(peaks_interval$maximaLoc) - length(peaks_baseline$maximaLoc)
  

  return(BVPPeaks)
  
} 


#returns the difference between the mean peak amplitude in the BVP signal during interval and during baseline
getDifferenceMeanBVPPeakAmplitude <-function(baseline_preprocessed, peaks_baseline, BVP_preprocessed, peaks_interval ){
  
  
  BVPPeakAmplitude_baseline  <- getMeanBVPPeakAmplitude(baseline_preprocessed, peaks_baseline)
  BVPPeakAmplitude_interval <- getMeanBVPPeakAmplitude(BVP_preprocessed, peaks_interval)
  
  difference <-  BVPPeakAmplitude_baseline - BVPPeakAmplitude_interval 
  
  return(difference)
  
}

#returns the mean peak amplitude in the BVP signal, normalised by a baseline
getMeanBVPPeakAmplitude<-function(signal, peaks){
  
  sum <-0
  mean <- 0
  l <- length(peaks$maximaLoc)
  
  for(i in 1: l)
    sum <- sum + signal[peaks$maximaLoc[i]]
  
  
  meanBVPPeakAmplitude <- sum/l  
  
  return(meanBVPPeakAmplitude)
  
}



#returns MinBVPPeakAmplitude
getMinBVPPeakAmplitude <-function(signal, peaks){
  
 amplitudes <- c()
 l <- length(peaks$maximaLoc)
 
 for(i in 1: l)
   amplitudes <- c(amplitudes, signal[peaks$maximaLoc[i]] )
  
 minBVPAmplitudes <- min(amplitudes)
  
  return(minBVPAmplitudes)
}


#returns MaxBVPPeakAmplitude
getMaxBVPPeakAmplitude <-function(signal, peaks){
  
  amplitudes <- c()
  l <- length(peaks$maximaLoc)
  
  for(i in 1: l)
    amplitudes <- c(amplitudes, signal[peaks$maximaLoc[i]] )
  
  maxBVPAmplitudes <- max(amplitudes)
  
  return(maxBVPAmplitudes)
  
}


#returns SumPeakAmplitude
getSumPeakAmplitude <-function(signal, peaks){
  
  sum_ampl <-0
  l <- length(peaks$maximaLoc)
  
  for(i in 1: l)
    sum_ampl <- sum_ampl+ signal[peaks$maximaLoc[i]]
  
  return(sum_ampl)
  
  
}