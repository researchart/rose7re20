## Overview

This package contains all the material used to conduct the study presented in the paper #88 "The Way it Makes you Feel. Predicting Users' Engagement during Interviews with Biofeedback and Supervised Learning" accepted at the Requirement Engineering Conference. 

 During the study, users have been interviewed with questions concerning the Facebook platform. Meanwhile, they wore a wristband for collecting their biofeedback. After each question of the interview, users self-reported their level of engagement elicited by the question using a questionnaire.  

Specifically, the package includes the following files: 

- DemographicSurvey.pdf: the demographic survey used to collect information about participants

- Protocol.pdf: the protocol of the experiment, with a detailed description of each step

- ElicitationImages.pdf: the slideset of images used both to get participants acquainted with self 
  report and to collected their physiological baseline in absence of emotions (images from 1 to 12).
  The images have been selected from the Geneva Database [1].

- Calibration-Questionnaire.pdf: questionnaire used for calibration based on the images

- Interview.pdf: the list of questions asked

- Self-Assessment-Questionnaire.pdf: questionnaire used for self-assessment based on the questions

- Preprint.pdf: preprint version of the paper

- BiometricAnalysis: scripts used for the machine learning analysis. These script are an updated version of the scripts already used in a previous publication [2] and shared at: https://doi.org/10.6084/m9.figshare.9206474.v5. A detailed descriptions of the scripts with instructions about how to run them can be found in the INSTALL.md file

  

The whole study, including the data sharing policy, was approved by the Institutional Review Board of Kennesaw State  University, study # 16-068

More information is available in the publication "The Way it Makes you Feel. Predicting Users' Engagement during Interviews with Biofeedback and Supervised Learning", to appear in the proceedings of the 28th IEEE International Requirements Engineering Conference, 2020.

The package is also available on Figshare at https://doi.org/10.6084/m9.figshare.11864994


## Known Issues:

when running the script Emotions.R on some MAC OS versions, you may encounter memory problems,
as the process is killed (the output is "Killed: 9"). We recommend using Windows or Linux machines. 


## References:

[1] Dan-Glauser, E. S., & Scherer, K. R. (2011). The Geneva affective picture database (GAPED): a new 730-picture database focusing on valence and normative significance. Behavior research methods, 43(2), 468.

[2] Daniela Girardi, Nicole Novielli, Davide Fucci, and Filippo Lanubile. 2020. 
“Recognizing Developers’ Emotions while Programming”. In Proceedings of 42nd International Conference on Software Engineering, Seoul, Republic of Korea, May 23–29, 2020 (ICSE ’20), 12 pages. DOI: https://doi.org/10.1145/3377811.3380374 