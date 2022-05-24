# guenon_evolutionary_simulations

MATLAB code implementing evolutionary simulations of face pattern diversification in guenons

Written by Sandra Winters, sandra.winters@nyu.edu

Please cite:  
Winters S & Higham JP. 2022. Simulated evolution of mating signal diversification in a primate radiation. Proceedings of the Royal Society B: Biological Sciences. 

Usage:  
guenonEvSim({type of mate choice}, {number of coevolving populations}, {proportion of evolution in allopatry}, {max hybrid fitness}, {conspecific encounter frequency})

Example:  
The following runs simulations with random mating, 4 coevolving populations, 10% of evolution in allopatry, 2% max hybrid fitness, and 50% conspecific encounter frequency:  
guenonEvSim('random_mating', 4, 0.1, 0.02, 0.5)

Results will be saved to the current directory, in a folder named based on the combination of parameters. Results contain the following:  
* .tar file that contains folders of simulation results for each iteration; each iteration has a .mat file for each saved generation, which contains the following variables:   
(1) featVals: the features of each offspring from that generation, encoded as individual features (15 face space features, male quality, female mating bias) x number of individuals per population x number of populations  
(2) parents: the parents of each offspring, encoded as parental data [mother, father, father's population] x number of individuals per population x number of populations. 
* .mat file that contains the following variables:  
(1) faceEvMean: the average value of each feature (15 face space features, male quality, female mating bias) for all populations across generations (features x [number of populations * number of saved generations])  
(2) faceEvSD: the standard deviation of each feature (15 face space features, male quality, female mating bias) for all populations across generations (features x [number of populations * number of saved generations])  
(3) faceEvGen: the generation associated with each column in faceEvMean and faceEvSD (1 x [number of populations * number of saved generations])  
(4) faceEvPop: the population associated with each column in faceEvMean and faceEvSD (1 x [number of populations * number of saved generations])  
(5) meanDistCon: mean pairwise distance between faces in the population (number of saved generations x number of populations)  
(6) meanDistHetero: mean pairwise distance between faces in the population and faces from other populations (number of saved generations x number of populations)    
(7) sdDistCon: standard deviation of pairwise distances between faces in the population (number of saved generations x number of populations)  
(8) sdDistHetero: standard deviation of pairwise distances between faces in the population and faces from other populations (number of saved generations x number of populations)  
(9) parents: parents of each offspring across all saved generations (parental data [mother, father, father's population] x number of individuals per population x number of populations x number of saved generations) 
  
For more details and descriptions of each parameter, see the Supplementary Methods of the paper above. 
