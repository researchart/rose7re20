library(caret)

scalar_metrics <- function(predictions, truth, outdir="output/scalar", outfile=output_file) {
print("scalr metrics")
print(output_file)

  if(!dir.exists(outdir))
    dir.create(outdir, showWarnings = FALSE, recursive = TRUE, mode = "0777")
  #output_file = paste(outdir, outfile, sep = "/")

  
  
  
  
  #create confusion matrix and compute metrics
  #https://blog.revolutionanalytics.com/2016/03/com_class_eval_metrics_r.html
    cm = as.matrix(table(Actual = truth, Predicted = predictions))
    print(cm)
    out <- capture.output(cm)
    cat("\nConfusion Matrix:\n", out, file=output_file, sep="\n", append= TRUE)
    
     
     n = sum(cm) # number of instances
     nc = nrow(cm) # number of classes
     diag = diag(cm) # number of correctly classified instances per class 
     rowsums = apply(cm, 1, sum) # number of instances per class
     colsums = apply(cm, 2, sum) # number of predictions per class
     p = rowsums / n # distribution of instances over the actual classes
     q = colsums / n # distribution of instances over the predicted classes
    
     accuracy = sum(diag) / n 
     precision = diag / colsums 
     recall = diag / rowsums 
     f1 = 2 * precision * recall / (precision + recall) 
    
     metrics <- data.frame(precision, recall, f1,accuracy) 
    
     out <- capture.output(metrics)
     cat("\nMetrics per class:\n", out, file=output_file, sep="\n", append=TRUE)
    
     macroPrecision = mean(precision)
     macroRecall = mean(recall)
     macroF1 = mean(f1)
    # BAC = mean(recall) #balanced accuracy is the average between the accuracy of the two class. It is the same of macro recall
    
     metrics_macro <- data.frame(macroPrecision, macroRecall, macroF1, accuracy)
     out <- capture.output(metrics_macro)
     cat("\nMetrics macro:\n", out, file=output_file, sep="\n", append=TRUE)
        
    
     oneVsAll = lapply(1 : nc,
                       function(i){
                         v = c(cm[i,i],
                               rowsums[i] - cm[i,i],
                               colsums[i] - cm[i,i],
                               n-rowsums[i] - colsums[i] + cm[i,i]);
                         return(matrix(v, nrow = 2, byrow = T))})
    
     s <- matrix(0, nrow = 2, ncol = 2)
     for(i in 1 : nc){s = s + oneVsAll[[i]]}
    
     micro_prf = (diag(s) / apply(s,1, sum))[1]; #the same
        
     out <- capture.output(micro_prf)
     cat("\n Overall (Micro-average):\n", out, file=output_file, sep="\n", append=TRUE)
     
    
   
  
}