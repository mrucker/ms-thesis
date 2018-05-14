function [bestFeatures] = featureExpectation_bb(firstLocation, targetData, finalDepth, actions, reward, gamma, feat)

    depth    = [];    
    location = [];
    feature  = [];
    
    pruneCount   = 0;
    visitCount   = 0;
    processCount = 0;
    actionCount  = size(actions,2);
    
    %potentialReward = arrayfun(@(d)(1-gamma^d)/(1-gamma), [finalDepth:-1:1])

    visitTime   = 0;    
    featureTime = [0,0,0,0,0];
    pruneTime   = 0;
    growTime    = 0;
        
    if finalDepth == 0
        bestFeatures = feat(firstLocation(1:2), firstLocation(3:8), targetData{1});
        %bestPath     = reshape(firstLocation,[],4);
    else
        depth    = [0];
        location = firstLocation;
        feature  = feat(firstLocation(1:2), firstLocation(3:8), targetData{1});
        
        %bestPath     = [];
        bestFeatures = [];
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
            nextFeatures = feat(nextLocations, nextHistory, targetData{nextDepth+1});
            assert(all((nextFeatures' * reward)< 1), 'my pruning bounds will not work if we can ever get more reward than 1 on any step');
        featureTime(2) = featureTime(2) + myToc();
        
        myTic();
            nextFeatures = currentFeatures + gamma^nextDepth * nextFeatures;
        featureTime(4) = featureTime(4) + myToc();

        myTic();
            isPrunable    = prunable(bestFeatures, nextFeatures, nextDepth, finalDepth, gamma, reward);            
            
            if finalDepth ~= nextDepth
                pruneCount    = pruneCount + sum(isPrunable)*actionCount^(finalDepth-nextDepth);
            end
            
            processCount  = processCount + actionCount;
            
            pruneIndexes = find(~isPrunable);
            allFeatures  = nextFeatures(:,pruneIndexes);
            allLocations = vertcat(nextLocations(:,pruneIndexes),repmat(currentLocation(1:6),1,sum(~isPrunable)));        
        
            if nextDepth == finalDepth
                [val,index] = max(allFeatures' * reward);
                if ~isempty(allFeatures) && (isempty(bestFeatures) || (val > bestFeatures'*reward))
                    bestFeatures = allFeatures(:,index);
                    %bestPath     = reshape(allLocations(:,index),[],4);
                end
                continue;
            end
        pruneTime = pruneTime + myToc();
        
        myTic();            
            count        = sum(~isPrunable);
            depth        = [depth   , ones(1, count)*nextDepth];
            location     = [location, reshape(allLocations,[],count)];
            feature      = [feature, allFeatures];
        growTime = growTime + myToc();                
    end
    
    %visitCount
    %processCount
    %pruneCount
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

    if isempty(bestFeatures)
        p = false(size(currentFeatures,2),1);
        return;
    end

    %Assumes that R \in [-inf,1]; This is a heuristic
    potentialRemainingReward = (gamma^(currentDepth+1)-gamma^(finalDepth+1))/(1-gamma);
    rewardGainedOnPathSoFar  = currentFeatures' * reward;        
    rewardFromBestPathEver   = bestFeatures' * reward;
    
    % notPossibleToBeatBest
    p = rewardFromBestPathEver - (rewardGainedOnPathSoFar + potentialRemainingReward) > 0;
        
end