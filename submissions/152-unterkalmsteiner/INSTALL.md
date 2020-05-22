# Installation instructions
The artifacts can be downloaded from [Zenodo](http://doi.org/10.5281/zenodo.3827169).

The repository contains two archives: `instrumentation.tar.gz` and `analysis.tar.gz`.

## Instrumentation
The source code of INCEpTION and our extension can be found in `inception-src.tar.gz`. The recommender is implemented in the module `inception-coclass-linking`. This archive is a snapshot of the code at the time of the experiment. The current version is available on our [github repository](https://github.com/munterkalmsteiner/inception), currently in the branch `CoClassRecommeder`.

### Replicating the experimental environment
1. execute `./run.sh` in the folder `SECOS`. This starts the decompounder service used by our recommender. 
2. execute `./run.sh` in the folder `inception`. This starts the INCEpTION server.
3. point your browser to `http://localhost:18080/inception-app-webapp/`. 
4. login with username `admin` and password `ccr2020`. 

#### Software requirements
We have compiled INCEpTION with the following:
```
java version "1.8.0_251"
Java(TM) SE Runtime Environment (build 1.8.0_251-b08)
Java HotSpot(TM) 64-Bit Server VM (build 25.251-b08, mixed mode)
```

For best compatibility, we suggest to use a similar version when running INCEpTION.

## Analysis
This archive contains the data collected during the experiment, stored in spreadsheets, and the R scripts to analyze the data. If you open the R markdown (*.Rmd) files with Rstudio, the environment should offer the possibility to install the required statistical packages automatically.
