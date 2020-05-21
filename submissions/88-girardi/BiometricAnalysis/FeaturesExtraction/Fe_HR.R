
#returns all HR features

# HR_mean_difference: The difference between the mean heart rate during the baseline and during the task
# HR_variance_difference: The difference between the variance heart rate during the baseline and during the task

getFeatures_HR <-function(baseline_values, interval_values){
  
  HR_mean_difference <- getHRMeanDifference(baseline_values, interval_values)
  HR_variance_difference <- getHRVarianceDifference(baseline_values, interval_values) 
  
  
  HR_features <- c(HR_mean_difference, HR_variance_difference)
  
  return(HR_features)
}


getHRMeanDifference <- function(baseline_values, interval_values){
  
  HR_mean_difference <- mean(baseline_values) - mean(interval_values)
  
  return(HR_mean_difference)
  
}


getHRVarianceDifference <- function(baseline_values, interval_values){
  
  HR_variance_difference <- var(baseline_values) - var(interval_values)
  
  return(HR_variance_difference)
}