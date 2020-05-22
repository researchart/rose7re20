## Overview

This package contains all the material used to conduct the study presented in the paper #88 "The Way it Makes you Feel. Predicting Users' Engagement during Interviews with Biofeedback and Supervised Learning" accepted at the Requirement Engineering Conference. During the study, users have been interviewed with questions concerning the Facebook platform. Meanwhile, they wore a wristband for collecting their biofeedback. After each question of the interview, users self-reported their level of engagement elicited by the question using a questionnaire.  

Specifically, the package includes the following files: 

- DemographicSurvey.pdf: the demographic survey used to collect information about participants

- Protocol.pdf: the protocol of the experiment, with a detailed description of each step

- ElicitationImages.pdf: the slideset of images used both to get participants acquainted with self 
  report and to collected their physiological baseline in absence of emotions (images from 1 to 12).
  The images have been selected from the Geneva Database [1].

- Interview.pdf: the list of questions asked

- Preprint.pdf: preprint version of the paper

- BiometricAnalysis: scripts used for the machine learning analysis. These script are an updated 
version of the scripts already used in a previous publication [2] and shared at: https://doi.org/10.6084/m9.figshare.9206474.v4 To run the scripts occur install several R libraries using the command 
  
  ```
  Rscript install.R
  ```
  
  

The script for extracting the features also leverages external libraries for preprocessing 
the raw signals acquired from the biometric sensor, as acknowledged in the paper.

More information is available in the publication "The Way it Makes you Feel. Predicting Users' Engagement during Interviews with Biofeedback and Supervised Learning", to appear in the proceedings of the 28th IEEE International Requirements Engineering Conference, 2020.

References:

[1] Dan-Glauser, E. S., & Scherer, K. R. (2011). The Geneva affective picture database (GAPED): a new 730-picture database focusing on valence and normative significance. Behavior research methods, 43(2), 468.

[2] Girardi, D., Novielli, N., Fucci, D., & Lanubile, F. (2020). Recognizing Developers' Emotions while Programming. 
To appear in ICSE'20, arXiv preprint arXiv:2001.09177.