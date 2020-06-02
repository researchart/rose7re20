# NaPiRE trouble predictor:  Overview

Based on data from the 2014 and 2018 runs of the NaPiRE survey (http://www.napire.org), this machine-learning-based tool implements a RESTful service predicting problems, causes, and their effects as potentially occurring in software development projects. To this end, we use Bayesian networks which are easily configurable from a web interface and can reach reasonable prediction recall and precision.

# Compiling and running

* Run a reasonably unix-ish operating system (some Linux distribution, MacOS and Windows Subsystem for Linux might work, too).
* Install a recent version of julia (https://julialang.org/, at least 1.1.0) and make sure it's on your PATH
`sudo apt-get install julia`
* Install graphviz (https://www.graphviz.org/) and make sure it's on your PATH
`sudo apt-get install graphviz`
* If you want to work with the web interface used for the case study, you need to install a recent-ish version of npm to compile the Angular app.
`sudo apt-get install npm`
* Clone this repository, inspect the code and run `./run.sh`. By default, the web service will be available at `http://127.0.0.1:8888`, serving the evaluation interface at `/web` and the case study UI at `/userweb`.
* If you are only interested in looking at pre-computed results, run `./show.sh path/to/resultsfile.ser`.

It is most probably possible to run this on an average Windows as well, but will require some additional work. Please refer to `run.sh` for ideas on how to make this work.

# Contributing and extending

## Licencing

This work is licensed under the GNU General Public License, version 3. Parts of it may be subject to other license (the data, e.g., is under CC-BY 4.0). Please refer to the respective directories for more details.

## On GitLab

To contribute, please create a new branch, apply your changes and push it to this repository. Then, create a merge request. If the code passes the review, it will be merged into master.

## On GitHub

Please fork and create a pull request. Evidently, your contribution will be reviewed in this case, too.

# Citing

## NaPiRE trouble predictor

The approach has been published and presented at the 28th IEEE International Requirements Engineering Conference (RE'20) (www.re20.org). 

When citing the approach, please use:

Florian Wiesweg, Andreas Vogelsang, Daniel Mendez: "Data-driven Risk Management for Requirements Engineering: An Automated Approach based on Bayesian Networks". 28th IEEE International Requirements Engineering Conference (RE'20). 2020

## NaPiRE data set

The NaPiRE initiative (Naming the Pain in Requirements Engineering) is a community endeavour run by a multitude of researchers world-wide. When referring to the NaPiRE initiative, please always refer to the official initiative's website under http://napire.org. When referring to the data set, please respect the authors' attribution as described in the respective folders; These authors can be referred to as via "Daniel Mendez, Stefan Wagner, Marcos Kalinowski, Michael Felderer et al."

When citing the NaPiRE initiative, please therefore use:

D. Mendez, S. Wagner, M. Kalinowski, M. Felderer et al. NaPiRE: Naming the Pain in Requirements Engineering, http://napire.org.

Specific data sets can be cited by adding the dates from the respective NaPiRE runs to the citation (e.g. 2018 for the one primarily used in context of this repository).

Exemplary publications that describe the initiative and which can be also used to refer to the data set are:
* D. Mendez Fernandez, S. Wagner. Naming the Pain in Requirements Engineering: A Design for a Global Family of Surveys and First Results from Germany. In: Information and Software Technology, Elsevier, 2014
* D. Mendez Fernandez, S. Wagner, M. Kalinowski, M. Felderer, P. Mafra, A. Vetrò, T. Conte, M.-T. Christiansson, D. Greer, C. Lassenius, T. Männistö, M. Nayebi, M. Oivo, B. Penzenstadler, D. Pfahl, R. Prikladnicki, G. Ruhe, A. Schekelmann, S. Sen, R. Spinola, J.L. de la Vara, A. Tuzcu, R. Wieringa. Naming the Pain in Requirements Engineering: Contemporary Problems, Causes, and Effects in Practice. In: Empirical Software Engineering Journal, Springer, 2016
* S. Wagner, D. Mendez Fernandez, M. Kalinowski, M. Felderer, P. Mafra, A. Vetrò, T. Conte, M.-T. Christiansson, D. Greer, C. Lassenius, T. Männistö, M. Nayebi, M. Oivo, B. Penzenstadler, D. Pfahl, R. Prikladnicki, G. Ruhe, A. Schekelmann, S. Sen, R. Spinola, J.L. de la Vara, A. Tuzcu, R. Wieringa, and D. Winkler. Status Quo in Requirements Engineering: A Theory and a Global Family of Surveys. In: Transactions on Software Engineering and Methodology, 2019

The authors' preprint versions of the manuscripts can be found on the initiative's website.
