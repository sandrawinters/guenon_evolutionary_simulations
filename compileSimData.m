function [faceEvPop,faceEvGen,faceEvMean,faceEvSD,meanDistCon,sdDistCon,meanDistHetero,sdDistHetero,parents] = compileSimData(genGap,saveDir)
%Extracts simulation results & summarizes (mean, SD, distances)

%% set defaults
if nargin<2
    saveDir = uigetdir(cd,'Select directory of simulation results');
end

if isfolder(saveDir)==0
    error('Error in compileSimData: directory does not exit')
end

%% load params
load([saveDir '/generations/gen0.mat'],'featVals')
nfeatAll = size(featVals,1);
nfeat = nfeatAll-2;
nind = size(featVals,2);
npop = size(featVals,3);

tmp = dir([saveDir '/generations/*.mat']);
tmp = str2double(strrep(strrep({tmp.name},'gen',''),'.mat',''));
ngen = max(tmp);

genPts = ngen/genGap+1;

%% compile face evolution across generations
faceEv = NaN(nfeatAll,nind,npop,genPts);
faceEvMean = NaN(nfeatAll,npop,genPts);
faceEvSD = NaN(nfeatAll,npop,genPts);
compGen = 0;
allParents = NaN(3,nind,npop,genPts);
for i = 1:genPts
    load([saveDir '/generations/gen' num2str(compGen) '.mat'],'featVals','parents')
    faceEv(:,:,:,i) = featVals(:,:,:);
    faceEvMean(:,:,i) = mean(featVals(:,:,:),2);
    faceEvSD(:,:,i) = std(featVals(:,:,:),0,2);
    allParents(1:3,:,:,i) = parents;
    compGen = compGen+genGap;
end

parents = allParents;

faceEvPop = repmat(1:npop,[1,genPts]);
faceEvGen = repelem(0:genGap:ngen,npop);
faceEvMean = reshape(faceEvMean,[nfeatAll,npop*genPts]);
faceEvSD = reshape(faceEvSD,[nfeatAll,npop*genPts]);

%% calculate distance metrics
meanDistCon = NaN(genPts,npop);
sdDistCon = NaN(genPts,npop);
for i = 1:genPts
    for j = 1:npop
        dist = pdist(faceEv(1:nfeat,:,j,i)');
        meanDistCon(i,j) = mean(dist);
        sdDistCon(i,j) = std(dist);
    end
end

meanDistHetero = NaN(genPts,npop);
sdDistHetero = NaN(genPts,npop);
for i = 1:genPts
    for j = 1:npop
        mat = faceEv(1:nfeat,:,j,i);
        for k = 1:npop
            if j~=k
                mat = [mat,faceEv(1:nfeat,:,k,i)];
            end
        end
        dist = squareform(pdist(mat'));
        dist = dist(1:nind,1+nind:end);
        meanDistHetero(i,j) = mean(dist(:));
        sdDistHetero(i,j) = std(dist(:));
    end
end

%% save
save([saveDir '/simulation_data.mat'],'faceEvPop','faceEvGen','faceEvMean','faceEvSD', ...
    'meanDistCon','sdDistCon', 'meanDistHetero','sdDistHetero','parents')

%% convert output data to tarball
tar([saveDir '/generations.tar'],'*.mat',[saveDir '/generations'])
rmdir([saveDir '/generations'],'s')
