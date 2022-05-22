function [featVals] = runSimulations(featVals,ngen,featVar,mating,saveDir,genGap,progress,maxHybridViability,nGenAllopatric,consppEncounterFreq)
%Runs evolutionary simulations of face pattern evolution based on feature values

%% set defaults
nind = size(featVals,2);
npop = size(featVals,3);

if isfolder(saveDir)==0
    mkdir(saveDir) 
end
if isfolder([saveDir '/generations'])==0
    mkdir([saveDir '/generations'])
end

%% run simulations
gen = 0; 
save([saveDir '/generations/gen0.mat'],'featVals')

if progress==1
    disp('Running simulations')
    disp('0%')
end

while gen <= ngen
    %create next generation
    if gen<=nGenAllopatric
        %each population reproduces separately under allopatry
        featValsNew = NaN(size(featVals));
        parents = nan([3,nind,npop]);
        for p = 1:size(featVals,3) 
            [featValsNew(:,:,p),parents(:,:,p)] = reproduce(featVals(:,:,p),'random_mating',maxHybridViability,1);
            parents(3,:,p) = p;
        end
    else 
        [featValsNew,parents] = reproduce(featVals,mating,maxHybridViability,consppEncounterFreq);
    end
        
    %add mutations
    featValsMut = featValsNew;
    mutInd = rand(size(featValsNew))<0.01;
    mutChange = (-0.5+rand(size(featValsNew))).*repmat(featVar,[1,nind,npop]); 
    featValsMut(mutInd) = featValsMut(mutInd)+mutChange(mutInd);
    featValsMut(end-1,featValsMut(end-1,:)<0) = 0; %don't allow mating bias to mutate below zero or above 1
    featValsMut(end-1,featValsMut(end-1,:)>1) = 1; %don't allow mating bias to mutate below zero or above 1
    featValsMut(end,featValsMut(end,:)<0) = 0; %don't allow quality to mutate below 0
    
%     if gen <= nGenAllopatric
%         featValsMut(end-1,:) = 0; %don't allow mating bias to evolve in allopatry
%     end
    
    %replace population
    featVals = featValsMut;
    
    %save
    if mod(gen,genGap)==0
        save([saveDir '/generations/gen' num2str(gen) '.mat'],'featVals','parents')
    end
    
    %increment generation counter
    gen=gen+1; 
        
    %progress
    if progress==1
        if mod(gen,ngen/10)==0
            disp([num2str(gen/ngen*100) '%'])
        end
    end
end





%%
%     offspring = [];
%     minOffspring = 0;
%     while minOffspring<nind %to make sure there are enough offspring...
%         %evaluate fitness of current individuals
%         [off,fatherPop] = reproduce(featVals,mating,nmales);
%         offspring = cat(2,offspring,off);
%         nOffEach = 20; %HACKY...
% 
%         %kill hybrids
%         hybrids = reshape(repelem(1:npop,nmales*nOffEach),[1,nmales*nOffEach,npop])~=fatherPop;
%         hybrids = repmat(hybrids,[nfeat,1,1]);
%         offspring(hybrids) = NaN;
%         minOffspring = min(sum(~isnan(offspring(1,:,:))));
%     end

