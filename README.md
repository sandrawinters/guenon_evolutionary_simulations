# guenon_evolutionary_simulations

MATLAB code implementing evolutionary simulations of face pattern diversification in guenons

Written by Sandra Winters, sandra.winters@nyu.edu

Please cite:  
Winters S & Higham JP. 2022. Simulated evolution of mating signal diversification in a primate radiation. Proceedings of the Royal Society B: Biological Sciences. 

Usage:  
guenonEvSim({type of mate choice}, {number of coevolving populations}, {proportion of evolution in allopatry}, {max hybrid fitness}, {conspecific encounter frequency})

Results will be saved to the current directory, in a folder named based on the combination of parameters. Results are contained in matrices of the form: individual features (15 face space features, male quality, female mating bias) x number of individuals per population x number of populations

Example:  
The following runs simulations with random mating, 4 coevolving populations, 10% of evolution in allopatry, 2% max hybrid fitness, and 50% conspecific encounter frequency:  
guenonEvSim('random_mating', 4, 0.1, 0.02, 0.5)
  
For more details and descriptions of each parameter, see the Supplementary Methods of the paper above. 
