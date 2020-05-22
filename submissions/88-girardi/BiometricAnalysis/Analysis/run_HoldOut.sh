#!/bin/bash

# read and trim params
csv_file=$(echo $1 | xargs)
models_file=$(echo $2 | xargs)
output_folder=$(echo $3 | xargs)
signal=$(echo $4 | xargs)
label=$(echo $5 | xargs)


printf output_folder 

if [[ -n "$models_file" && -n "$csv_file" ]]; then
    printf " === Starting the tuning of classifiers' params (this may take a while...)\n"
    start_time=$(date +"%Y-%m-%d_%H.%M")
    for i in `seq 1 10`;
    do
        now=$(date +"%Y-%m-%d %H.%M")
        echo " :: Run $i -- started at $now"
        time Rscript tuning_2labels.R $i $csv_file $models_file $output_folder $signal $label
    done   

    echo " Done"
else
    echo "Argument error: models and/or input file not given."
fi