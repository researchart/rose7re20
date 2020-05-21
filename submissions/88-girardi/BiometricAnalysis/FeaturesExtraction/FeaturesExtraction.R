

extractFeatures <-function(signal, baseline_values, interval_values){
  
  switch(signal, 
         
        
         
         EDA={
           
           features <- getFeatures_EDA(baseline_values, interval_values); 
         },
         
         
         HR={
           features <- getFeatures_HR(baseline_values, interval_values);
         },
         
         BVP={
           features <- getFeatures_BVP(baseline_values, interval_values);
         }
         
         
         
  )
  
}