

#returns data normalized by baseline
normalizeDataByBaseline <- function(baseline, interruption){
  
  baseline <- unlist(baseline)
  interruption <- unlist(interruption)
   
  
  meanB <- mean(baseline)
  sdB <- sd(baseline)
  
  #print(paste("mean: ",meanB))
  #print(paste("sd: ",sdB))
  
  for( i in 1:length(interruption)){
      interruption[i] <- (interruption[i] - meanB)/sdB
    
  }
  
  return(interruption)
}


preprocessing <- function(signal, values){
  
  switch(signal, 
         EEG={
           
           values_preprocessed <- EEG_preprocessing(values);
           
         },
         
         EEG_ATT={
           
           values_preprocessed <-EEG_ATT_preprocessing(values);   
         },
         
         EEG_MED={
           
           values_preprocessed <-EEG_MED_preprocessing(values);
         },
         
         EDA={
           
           values_preprocessed <- EDA_preprocessing(values); 
         },
         
         TEMP={
           
           values_preprocessed <-TEMP_preprocessing(values);
         },
         
         HR={
           values_preprocessed <- HR_preprocessing(values);
         },
         
         BVP={
           values_preprocessed <-BVP_preprocessing(values);
         }
         
  )
  
  return(values_preprocessed)
  
}

EEG_preprocessing <-function(values){
  
  # Draw original signal
  #plot(values, type="l", xlab = "Time", yLab ="Original" )
  
  # Construct a band-pass filter using a butterworth filter design.
  # (alpha: 8-12hz, beta 12-30 hz, gamma 30-80hz, delta 0-4 hz, theta 4-8 hz)
  bf_alpha <- butter(2, c(8/1000,12/1000), type="pass")
  bf_beta <- butter(2, c(12/1000,30/1000), type="pass")
  bf_gamma <- butter(2, c(30/1000,80/1000), type="pass")
  bf_delta <- butter(2, c(0,4/1000), type="pass")
  bf_theta <- butter(2, c(4/1000,8/1000), type="pass")
  
  alpha <- signal:::filter(bf_alpha, values)
  beta  <- signal:::filter(bf_beta, values)
  gamma <- signal:::filter(bf_gamma, values)
  delta <- signal:::filter(bf_delta, values)
  theta <- signal:::filter(bf_theta, values)
  plot(alpha)
  
 
  waves <- data.frame("alpha" = alpha, "beta" = beta, "gamma" = gamma, "delta"= delta, "theta" = theta)
  
  return(waves)
  
  
  #plot(beta,xlab = "Time", yLab ="Beta")
  #plot(gamma,xlab = "Time", yLab ="Gamma")
  #plot(delta,xlab = "Time", yLab ="Delta")
  #plot(theta,xlab = "Time", yLab ="Theta")
  
  
  
}



  #use cvxEDA algorithm to separate tonic and phasic component: a Convex Optimization Approach to Electrodermal Activity Processing
  #Published in final edited form as: IEEE Trans Biomed Eng, Vol. 63, No. 4, pp. 797-  804, Apr. 2016. doi:10.1109/TBME.2015.2474131
  #github repository: https://github.com/lciti/cvxEDA
  EDA_preprocessing <-function(values){
    
    #print(values)
    
    Fs <-4
    df <-cvxEDA(values, 1./Fs)
    tonic <-df$tonic
    phasic <-df$phasic
    
    signal <-data.frame("phasic" = phasic, "tonic" = tonic)
    
    return(signal)
    
    }
 
 
  
  #signal preprocessed as in https://github.com/PIA-Group/BioSPPy/blob/master/biosppy/signals/bvp.py
  #reference paper: https://ieeexplore.ieee.org/document/6127029?tp=&arnumber=6127029
  
  BVP_preprocessing <-function(values){
    
    
    bf_bvp <- butter(2, c(1/1000,8/1000), type="pass")
    bvp_filtered <- signal:::filter(bf_bvp, values)
   
    return(bvp_filtered)
    }