SIGNALIFE Neuron Morphology Clustering
===
Author: **Nikita Lukianets**
Email: [nikita.lukianets@unice.fr](mailto:nikita.lukianets@unice.fr)

Supervision
---
 - Neuroscience: **Michele Studer**, http://ibv.unice.fr/EN/equipe/studer.php
 - Statistics: **Franck Grammont**, http://math.unice.fr/laboratoire/interactions/neurosciences

About
---
This set of MATLAB scripts has been developed to perform automatic neuron morphometric analysis using clustering approach, as well as a feature-by-feature comparison. Neurons are treated as objects in the multidimensional feature space. Cluster algorithm groups neuron according to similarities in their feature values. The script is based on K-means++ clustering, but unlike the original method, it doesn't require explicit specification of the cluster number as an input that makes it less biased.

Project content and use
---
Input should be organized as the datatable where objects (observations) are each placed in separate raws and features organized into a separate columns. Feature selection is done in the header of the scripts and stored as a *feature_range* variable. Next, *features_selected* matrix is transmitted as a clustering input.
- *clustering_CBBP.m*: 
	- clustering function for execution in the loop
- *clustering_CBBP_standalone.m*: 
	- standalone clustering function
- *crosscorrelated.m*: 
	- Cross-correlations of the morphology features
- *distinctivef_CBBP.m*: 
	- comparison of the populations by distinctive features
- *runtestcases_clustering_CBBP.m*: 
	- execution of the all possible test cases with selected sets of features
- *regression_CBBP_standalone.m*: 
	- machine learning using logistic regression for incomplete set of features to classification biocytin neurons based on a trained set from CBBP neurons

Additional scripts used
---
- plot.ly visualization https://plot.ly/matlab/
- export_fig.m https://github.com/altmany/export_fig
- combinator.m by Matt Fig http://fr.mathworks.com/matlabcentral/fileexchange/24325-combinator-combinations-and-permutations
- mwwtest.m by http://www.mathworks.com/matlabcentral/fileexchange/25830-mann-whitney-wilcoxon-test

Affiliation
---
The work became possible with the support of the [SIGNALIFE PhD](http://signalife.unice.fr/) within University of Nice Sophia-Antipolis. 
