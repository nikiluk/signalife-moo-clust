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
This set of MATLAB scripts have been developed to perform automatic neuron classification using clustering approach. Neurons are treated as objects in the multidimensional feature space. Cluster algorithm groups neuron according to similarities in their feature values. The script is based on K-means++ clustering, but unlike the original method, it doesn't require explicit specification of the cluster number as an input that makes it less biased.

Content
---
- *clusering_CBBP.m*: 
	- clustering function for execution in the loop
- *clusering_CBBP_standalone.m*: 
	- standalone clustering function
- *crosscorrelated.m*: 
	- Cross-correlations of the morphology features
- *dendrites_destinctive_CBBP.m*: 
	- comparison of the populations by distinctive features
- *runtestcases_clusering_CBBP.m*: 
	- execution of the all possible test cases with selected sets of features

Additional scripts used
---
- plot.ly visualization https://plot.ly/matlab/
- export_fig.m https://github.com/altmany/export_fig
- combinator.m by Matt Fig http://fr.mathworks.com/matlabcentral/fileexchange/24325-combinator-combinations-and-permutations
- mwwtest.m by http://www.mathworks.com/matlabcentral/fileexchange/25830-mann-whitney-wilcoxon-test

Affiliation
---
The work became possible with the support of the [SIGNALIFE PhD](http://signalife.unice.fr/) within University of Nice Sophia-Antipolis. 
