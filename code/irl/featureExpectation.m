function [bestPath,bestFeatures] = featureExpectation(firstLocation, targetData, actions, reward, gamma)

    depth    = [];    
    location = [];
    feature  = [];
    
    pruneCount  = 0;
    visitCount  = 0;
    finalDepth  = size(targetData,1)-1;
    actionCount = size(actions,2);        

    visitTime   = 0;    
    featureTime = [0,0,0,0,0];
    pruneTime   = 0;
    growTime    = 0;
        
    if finalDepth == 0
        bestFeatures = features(firstLocation, targetData{1});
        bestPath     = firstLocation;
    else
        depth    = [0];
        location = reshape(firstLocation,[],1);
        feature  = features(firstLocation, targetData{1});
        
        bestPath     = horzcat(zeros(2,finalDepth),firstLocation);
        bestFeatures = zeros(6,1);
    end
    
    while ~isempty(feature)
    
        myTic();            
            currentDepth    = depth(:,end);
            currentLocation = location(:,end);
            currentFeatures = feature(:,end);
            
            depth   (:,end) = [];
            location(:,end) = [];
            feature (:,end) = [];

            visitCount = visitCount + 1;
        visitTime = visitTime + myToc();

        myTic();
            nextDepth          = currentDepth+1;
            nextHistory        = reshape(currentLocation(1:6),[],3);
            nextLocations      = currentLocation(1:2) + actions;
        featureTime(1) = featureTime(1) + myToc();
        myTic();
            nextFeatures       = features(horzcat(nextLocations,nextHistory),targetData{nextDepth+1});
        featureTime(2) = featureTime(2) + myToc();
        
        myTic();
            nextFeatures       = vertcat(nextFeatures(1:actionCount)', repmat(nextFeatures(end-4:end),1,actionCount));
        featureTime(3) = featureTime(3) + myToc();
        myTic();
            nextFeatures       = currentFeatures + gamma^nextDepth * nextFeatures;
        featureTime(4) = featureTime(4) + myToc();

        myTic();
            isPrunable    = prunable(bestFeatures, nextFeatures, nextDepth, finalDepth, gamma, reward);            
            pruneCount    = pruneCount + sum(isPrunable) * (1+actionCount^(nextDepth-finalDepth));
            
            pruneIndexes = find(~isPrunable);
            allFeatures  = nextFeatures(:,pruneIndexes);
            allLocations = vertcat(nextLocations(:,pruneIndexes),repmat(currentLocation(1:6),1,sum(~isPrunable)));        
        
            if nextDepth == finalDepth
                [val,index] = max(allFeatures' * reward);
                if val > bestFeatures'*reward
                    bestFeatures = allFeatures(:,index);
                    bestPath     = allLocations(:,index);
                end
                continue;
            end
        pruneTime = pruneTime + myToc();
        
        myTic();
            count = sum(~isPrunable);
            depth    = [depth   , ones(1, count)*nextDepth];
            location = [location, reshape(allLocations,[],count)];
            feature  = [feature, allFeatures];
        growTime = growTime + myToc();                
    end
end

%[visitTime,featureTime,pruneTime,growTime] / sum([visitTime,featureTime,pruneTime,growTime])

function myTic()
    %tic
end

function t = myToc()
    t = 0;    
    %t = toc;   
end

function p = prunable(bestFeatures, currentFeatures, currentDepth, finalDepth, gamma, reward)

    %Assumes that R \in [0,1]; This is a heuristic
    potentialRemainingReward = gamma^(finalDepth-currentDepth)/(1-gamma);
    rewardGainedOnPathSoFar  = currentFeatures' * reward;        
    rewardFromBestPathEver   = bestFeatures' * reward;
    notPossibleToBeatBest    = rewardFromBestPathEver - (rewardGainedOnPathSoFar + potentialRemainingReward) > 0;
    
    p = notPossibleToBeatBest;
        
end