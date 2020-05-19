# Artifact description
This submission contains four artifacts:

1. The source code of our extension to INCEpTION, implementing the recommender described in the paper
2. The instrumentation used in the experiment, i.e. the compiled version of INCEpTION, the decompounder, and instructions on how to run them.
3. The raw (stored in INCEpTION's database) and processed (stored in spreadsheets) data collected during the experiment
4. The R scripts (in markdown) used to analyze the data that produce the statistics/graphs presented in the paper.

Note that the natural language processing pipeline was developed for the Swedish language, and that the classification system and the requirements used in our experiment are written in Swedish.

However, as we use DKPro, the NLP components and models can be easily replaced to support other languages. The SECOS decompounder supports also other languages, see [SECOS](https://github.com/riedlma/SECOS) on github.
