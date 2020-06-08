# INSTALL

The folder "BiometricAnalysis" contains the scripts to replicate the machine learning analysis described in the paper. 

To install all the libraries needed to run the scripts use the command: 

```
Rscript install.R
```
and

```
pip install cvxopt`
```



### Dependencies

The machine learning analysis is based on the [caret](https://cran.r-project.org/web/packages/caret/index.html) package. 

The features extraction scripts are based and reuse part of: 

1.  the [cvxEDA](https://github.com/lciti/cvxEDA) algorithm described in A Greco, G Valenza, A Lanata, EP Scilingo, and L Citi "cvxEDA: a Convex Optimization Approach to Electrodermal Activity Processing"
   IEEE Transactions on Biomedical Engineering, 2015 DOI: 10.1109/TBME.2015.2474131. 
2. the Biosppy package developed by Carreiras C, Alves AP, Lourenço A, Canento F, Silva H, Fred A, *et al.*
   BioSPPy - Biosignal Processing in Python, 2015-, https://github.com/PIA-Group/BioSPPy/ 

### How to use the scripts

In particular, the scripts can be used to:

- to create clusters based on self-report normalized scores for valence and arousal and, consequently, derive the labels to train the classifier.  As input file we used the file "Discretization.xlsx". The command to run the script is:

  ```
  Rscript Discretization.R <input_file> <output_file>
  ```

  As output of this script we obtained the file "Cluster_labels.xlsx", where we manually derived the labels using excel formulas starting from the column "Category"

- extract features from data collected using the Empatica E4 wristband. The file "Emotions.R" reads the biometric data of the subjects from the folder "DataSubjects". In this folder we provide an example to show how subject data must be formatted. The command to run the script is:

  ```
  Rscript Emotions.R
  ```

  As output, one dataset for each physiological measures is created with the features extracted. The dataset can be find in the folder "Dataset"

- concatenate the features of EDA, BVP, HR in one single dataset and add the columns with the valence and arousal labels, contained in the file "Label_final.csv". Two datasets will be created: 

  - Empatica_2labels_valence, with all the instances having "positive" or "negative" as label
  - Empatica_2labels_arousal, with all the instances having "high or "low" as label

  ```
  Rscript concatenateDataset. R <input_dir> <labels_file>
  ```

  

- train the classification models for arousal and valence and compute the classification performance, using the Hold-out validation setting. The script for this analysis are included in the subfolder "Analysis". The input dataset used in this paper are: Empatica_2labels_arousal.csv and Empatica_2labels_valence.csv. <label> can assume "valence" or "arousal" as values, depending on the dataset chosen.

  ```
  nohup ./run_HoldOut.sh <input_dataset> models/models_all.txt <output_dir> E4 <label> &>log.txt &
  
  ```

  



