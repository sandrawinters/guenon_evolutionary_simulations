function [] = guenonEvSim(mating,populations,propAllopatric,maxHybridViability,encounterFreq)
%Runs simulations based on given parameters
%   mating: type of mate choice 
%       'random_mating' - no mate choice
%       'mate_choice' - mate choice for average population face
%       'mate_choice_PAM' - positive assortative mate choice
%   populations: number of coevolving populations
%   propAllopatric: proportion of evolution in allopatry
%   maxHybridViability: max likelihood of hybrids being retained in the next generation
%   encounterFreq: likelihood of encountering conspecifics

%% run simulations
disp('RUNNING EVOLUTIONARY SIMULATIONS: ')
disp(['mating = ' mating])
disp(['populations = ' num2str(populations)])
disp(['propAllopatric = ' num2str(propAllopatric)])
disp(['maxHybridViability = ' num2str(maxHybridViability)])
disp(['encounterFreq = ' num2str(encounterFreq)])

parpool(feature('numcores'));

rng(randi([1 1000],1),'twister')
disp('Random number generator:')
disp(rng)
for npop = populations
    parfor itt = 1:28
        %set params
        nind = 1000;
        ngen = 20000;
        genGap = 100;
        x = load('extant_features.mat');
        featSD = x.featSD;
        nfeat = x.nfeat;

        nGenAllopatric = ngen*propAllopatric;

        %set directory
        saveDir = [mating '_' num2str(propAllopatric*100) 'pAllo_' num2str(maxHybridViability*100) 'hybridVia_' num2str(encounterFreq*100) 'encFreq_' num2str(npop) 'populations/iteration' num2str(itt)];

        if isfolder(saveDir)==0
            mkdir(saveDir)
        end

        %initialize populations & display initial faces
        featValsInit = initializePopulations(npop,nind,nfeat,featSD/2); %use half SD as max amount of variation to add

        %run simulations & display final faces
        runSimulations(featValsInit,ngen,[featSD/2;0.2;0.2],mating,saveDir,genGap,0,maxHybridViability,nGenAllopatric,encounterFreq);
        
        %compile data
        compileSimData(genGap,saveDir);
    end
end

delete(gcp('nocreate'))
