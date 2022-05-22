function [offspring,parents] = reproduce(featVals,mating,maxHybridViability,consppEncounterFreq,fMatingBiasEvol)
%Generates mating pairs and resulting offspring

%% check args & set defaults
if nargin<1
    error('Reproduction error: no features provided')
end
if nargin<2
    mating = 'random_mating';
end
if nargin<3
    maxHybridViability = 1;
end
if nargin<4
    consppEncounterFreq = 1; %allopatric (100% likelihood of encountering conspecific)
end
if nargin<5
    fMatingBiasEvol = 1;
end

npop = size(featVals,3);
nind = size(featVals,2);
nfeat = size(featVals,1)-2;

nmales = floor(nind/2);
nfemales = nind-nmales;
    
%% set variables
%get mean population locations & distances in face space
popMeanFaces = reshape(mean(featVals(1:nfeat,:,:),2),[nfeat,npop]);
popDist = squareform(pdist(popMeanFaces'));
maxDist = 51.3286; %based on max distance between mean faces of extant species in face space: max(pdist(features'))
hybridViability = 1-(popDist/maxDist); %0 = complete inviability (all hybrids die), 1 = complete viability (all hybrids survive)
hybridViability = min(hybridViability,maxHybridViability); %keep hybrid viability at or above given threshold

%separate male & female potential parents
females = featVals(:,1:nfemales,:);
males = featVals(:,nfemales+1:end,:);

%% determine male quality & generate father pool
males = reshape(males,[nfeat+2,nmales*npop]);
mPop = repelem(1:npop,nmales);

quality = round((males(end,:)+(rand([1,nmales*npop]).*max(males(end,:))).*50)); %half additive genetic variance, half additive environmental variance (randomly generated)

if strcmp(mating,'mate_choice')==1
    mFaceDist = nan(npop,nmales*npop);
    for i = 1:nmales*npop
        d = pdist([males(1:nfeat,i),popMeanFaces]');
        mFaceDist(:,i) = d(1:npop);
    end
end

if strcmp(mating,'mate_choice_PAM')==1
    femaleFaces = reshape(females(1:nfeat,:,:),[nfeat,nfemales*npop]);
    mfFaceDist = squareform(pdist([femaleFaces,males(1:nfeat,:)]'));
    mfFaceDist = mfFaceDist(1:nfemales*npop,nfemales*npop+1:end);
end

if strcmp(mating,'mate_choice_conHetero')==1
    mFaceDist = squareform(pdist([popMeanFaces,males(1:nfeat,:)]'));
    mFaceDist = mFaceDist(1:npop,npop+1:end);
    mFaceDistRel = nan(size(mFaceDist));
    p = 1:npop;
    for i = 1:npop
        hetero = mFaceDist(p(p~=i),:);
        hetero = mean(hetero);
        mFaceDistRel(i,:) = mFaceDist(i,:) + (1./hetero);
    end
end

%% generate offspring
offspring = nan(size(featVals));
fOrder = randperm(nfemales); %cycle through females in random order
parents = nan([3,nind,npop]);
% m = nfemales+1:nind;
for p = 1:npop
    fOrderN = 0;
    for i = 1:size(offspring,2)
        survive = 0;
        
        %set encounter frequency of males based on species (i.e. population)
        encounterFreq = ones(1,nmales*npop).*(1-consppEncounterFreq); %initialize all males to heterospecific encounter frequency
        encounterFreq(1,mPop==p) = consppEncounterFreq; %change conspecific males to conspecific encounter frequency
        
        %generate offspring, looping through females in random order until one survives
        while survive==0 %repeat until have surviving offspring
            %generate random female order
            fNum = fOrder(mod(fOrderN,nfemales)+1); 
            
            %generate sample of males (10%), with each male's likelihood of inclusion proportional to his quality * encounter frequency for the current female's population
            mOptions = datasample(1:nmales*npop,round(nmales*npop/10),'Replace',false,'Weights',quality.*encounterFreq);
            
            %mate choice always occurs when females have evolving preferences; otherwise it is probabilistic in association with the female's preference term
            if contains(mating,'mate_choice') && ( fMatingBiasEvol==0 || rand(1)<females(end-1,fNum,p) ) %when fMatingBiasEvol = 1, likelihood of mate choice is proportional to female bias term 
                %mate choice based on facial similarity
                if strcmp(mating,'mate_choice')==1 %mate choice based on similarity to conspecific average
                    [~,choice] = min(mFaceDist(p,mOptions)); 
                elseif strcmp(mating,'mate_choice_conHetero')==1 %mate choice based on maximum distinctiveness from heterospecifics
                    [~,choice] = min(mFaceDistRel(p,mOptions));
                elseif strcmp(mating,'mate_choice_PAM') %positive assortative mating
                    [~,choice] = min(mfFaceDist((p-1)*nfemales+fNum,mOptions)); 
                else
                    error('unknown mate choice')
                end
            else
                %random mating
                choice = randi(length(mOptions));
            end
            mNum = mOptions(choice);
            
            %determine if offspring survives
            if mPop(mNum)==p || rand(1)<hybridViability(p,mPop(mNum)) %always survive if parents from same population, if not then hybrid survival is proportional to current viability based on distinctiveness between parental populations
                survive = 1;
            end
            fOrderN = fOrderN+1;
        end
        parents(1,i,p) = fOrder(fNum); %mother number (in same population as offspring)
        parents(2,i,p) = mNum-((mPop(mNum)-1)*nmales)+nfemales;%father number original error --> m(mod(mNum-1,5)+1)
        parents(3,i,p) = mPop(mNum); %father population
        
        offspring(:,i,p) = females(:,fOrder(fNum),p); %offspring originally assigned mother's features
        parentFeat = [rand([nfeat,1]);0;1]; %randomly choose which features come from which parents, retain mother's mating bias, get father's trait quality
        offspring(parentFeat>0.5,i,p) = males(parentFeat>0.5,mNum);
    end
end

