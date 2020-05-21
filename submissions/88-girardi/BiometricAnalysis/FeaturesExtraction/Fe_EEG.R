
#returns all EEG features
getFeatures_EEG <-function(baseline_values, interval_values ){
  
  EEG_normalized <- normalizeDataByBaseline(baseline_values, interval_values)
  
  interval_preprocessed <- EEG_preprocessing(EEG_normalized) 
  
  alpha_bin <- getFrequencyBin(interval_preprocessed$alpha)
  beta_bin <-  getFrequencyBin(interval_preprocessed$beta)
  gamma_bin <- getFrequencyBin(interval_preprocessed$gamma)
  delta_bin <- getFrequencyBin(interval_preprocessed$delta)
  theta_bin <- getFrequencyBin(interval_preprocessed$theta)
  
  alpha_beta <-getWavesRatio(alpha_bin, beta_bin)
  alpha_gamma <-getWavesRatio(alpha_bin, gamma_bin)
  alpha_delta <-getWavesRatio(alpha_bin, delta_bin)
  alpha_theta <-getWavesRatio(alpha_bin, theta_bin)
  
  beta_alpha <-getWavesRatio(beta_bin, alpha_bin)
  beta_gamma <-getWavesRatio(beta_bin, gamma_bin)
  beta_delta <-getWavesRatio(beta_bin, delta_bin)
  beta_theta <-getWavesRatio(beta_bin,theta_bin)
  
  gamma_alpha <-getWavesRatio(gamma_bin, alpha_bin)
  gamma_beta <-getWavesRatio(gamma_bin, beta_bin)
  gamma_delta <-getWavesRatio(gamma_bin, delta_bin)
  gamma_theta <-getWavesRatio(gamma_bin, theta_bin)
  
  delta_alpha <-getWavesRatio(delta_bin, alpha_bin)
  delta_beta <-getWavesRatio(delta_bin, beta_bin)
  delta_gamma <-getWavesRatio(delta_bin, gamma_bin)
  delta_theta <-getWavesRatio(delta_bin, theta_bin)
  
  theta_alpha <-getWavesRatio(theta_bin, alpha_bin)
  theta_beta <-getWavesRatio(theta_bin, beta_bin)
  theta_gamma <-getWavesRatio(theta_bin, gamma_bin)
  theta_delta <-getWavesRatio(theta_bin, delta_bin)
  
  
  EEG_features <-c( alpha_bin,beta_bin, gamma_bin, delta_bin, theta_bin, 
                    alpha_beta,alpha_gamma,alpha_delta,alpha_theta,beta_alpha,beta_gamma,beta_delta,beta_theta,
                    gamma_alpha, gamma_beta,gamma_delta,gamma_theta,delta_alpha,delta_beta, delta_gamma, delta_theta,theta_alpha, theta_beta,theta_gamma,theta_delta)
    
 
  return(EEG_features)
  
}


#returns the values frequency bin, normalised by a baseline
getFrequencyBin <-function(values){
  
    #create the bin(group of frequencies) using histogram of the input values 
  h <-hist(values, freq= TRUE, breaks=c(min(values), max(values)))
  
  #density corresponds to relative frequencies because we have only one bin
  frequencyBin <- h$density
  
    return(frequencyBin)
}

#returns the ratio between the x and y frequency bin, normalised by a baseline
getWavesRatio <-function(x,y){
  
  ratio <- x/y
  
  return(ratio)
  
}


#returns features related to attention or meditation based on input parameter:
#min_level: the minimun attention(meditation) value
#max_level: the maximum attention(meditation) value
#mean_level_difference: The difference between the mean attention(meditation) during the baseline and during the task
#sd_level_difference: The difference between the standard deviation of the attention(meditation) values during the baseline and during the task

getFeatures_EEG_ATT_MED <- function(baseline_values, interval_values){
  
 
  min_level <- min(interval_values)
  max_level <- max(interval_values)
  mean_level_difference <- mean(baseline_values) - mean(interval_values) 
  sd_level_difference <- sd(baseline_values) -  sd(interval_values)
  
  features_level <- c(min_level, max_level, mean_level_difference, sd_level_difference  )
  
  return(features_level)
  
}





