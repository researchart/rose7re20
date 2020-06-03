# Artifact Description
## 35 - The Lack of Shared Understanding of Non-Functional Requirements in ContinuousS oftware Engineering: Accidental or Essential?

### Study Information
We conducted a case study of three small organizations scaling up continuous software engineering to further understand and identify factors that contribute to lack of shared understanding of non-functional requirements (NFRs), and its relationship to rework. To conceptualize lack of shared understanding of NFRs we traced it to rework development tasks. Seeking to shed light on the complex relationship between shared understanding, rework, and CSE, our study examined forty-one NFR-related development tasks identified as rework and was driven by the following research questions:
1. What contributes to lack of shared understanding of NFRs?
1. Which NFRs are most associated with a lack of shared understanding?
1. What amount of a lack of shared understanding of NFRs is accidental versus essential?
To answer our research questions, we conducted a multi-case study using a mixed-methods approach in collaboration with three independent organizations using qualitative and immersive techniques. For this study our organizations are referred to as Alpha, Beta, and Gamma. We performed a preliminary study of each organization to build a context for each organization. We then collected data from project task management repositories and analyzed the tasks to uncover 41 NFR-related software development tasks as rework due to a lack of shared understanding of NFRs.

### Data Analysis
We performed qualitative analysis through focus groups at each organization. We used an open-coding [1] approach to develop a purely inductive codebook, which minimizes a coder's ability to force a bias of any particular hypothesis. In the initial coding phase, a transcript was independently coded by two coders, after which an agreement session was held to discuss the codes, consolidate the codebook, and to calculate Cohen's kappa coefficient (using sklearn.metrics cohen_kappa_score). We continued coding in pairs until our inter-rater reliability met substantial agreement. After which we individually coded the remaining transcripts followed by an expert rater reviewer.

This data represents two artifacts from our research in evaluating the complex relationship between shared understanding, non-functional requirements, continuous software engineering, and rework. It includes the resulting thematic synthesis codebook and inter-rater kappa values.

### Artifact descriptions
Our replication package contains two artifacts:
1. Codebook.csv: The codebook itself contains a row for each code used (48 in total), including the code name, a brief description of the code, which round of coding that code was introduced, the total number of tasks that code appeared in (at least once), the number of tasks that code appeared in for each organization (Alpha, Beta, and Gamma), the total number of occurrences across all tasks, the number of occurrences across across each organization (Alpha, Beta, and Gamma), and the number of occurrences for each task.

For example, the code 'BusinessContext' was used when 'Talking about information from the business side of the organization' and appeared in the first transcript we coded (1). The 'BusinessContext' code appeared in 19/41 tasks (10 at Alpha, 8 at Beta, and 1 at Gamma). Furthermore, the 'BusinessContext' code was used a total of 72 times (43 at Alpha, 22 at Beta, and 7 at Gamma). The remaining 41 columns represent the number of occurrences for each task, e.g. it appeared 3 times in task A-2 (Alpha's second task).

2. kappa-values.csv: Contains the interview rounds (in order of coding) and the associated kappa values calculated for our inter-rater coding agreement.

### Usefulness
While we recognize that the value and usefulness of our replication package is yet to-be-determined, in the interest of transparency of open science we published our artifacts. In light of this, we hope that these artifacts are useful to either replicate our findings or to further analyze to produce other enlightening results.

### References
1. J. M. Corbin and A. Strauss, “Grounded theory research: Procedures, canons, and evaluative criteria,”Qualitative sociology, vol. 13, no. 1,pp. 3–21, 1990.