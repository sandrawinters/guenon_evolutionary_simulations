function [featVals] = initializePopulations(npop,nind,nfeat,featVar)
%Creates populations of simulated individuals with randomly generated features

%% set defaults
if nargin<4
    featVar = ones([nfeat 1]);
end

%% generate populations
%create facial features
featVals = (-0.5+rand(nfeat,nind,npop)).*repmat(featVar,[1,nind,npop]);
    %creates random number between -0.5 and 0.5
    %multiplies by variation per feature

%assign male & female characteristics (if sexRatio provided)
% featVals(nfeat+1,:,:) = zeros(1,nind,npop); %mating bias (used for females) - all zero
% featVals(nfeat+1,:,:) = rand(1,nind,npop); %mating bias (used for females) - random (0-1)
featVals(nfeat+1,:,:) = rand(1,nind,npop)./10; %mating bias (used for females) - random (0-0.1)
featVals(nfeat+2,:,:) = rand(1,nind,npop); %trait quality (used for males) - random (0-1)
