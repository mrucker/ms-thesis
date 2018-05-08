function [bestPath,bestFeatures] = featureExpectation(firstLocation, targetData, actions, reward, gamma)

    pruneCount  = 0;
    visitCount  = 0;
    finalDepth  = size(targetData,1)-1;
    actionCount = size(actions,2);
    
    bestPath     = horzcat(zeros(2,finalDepth),firstLocation);
    bestFeatures = zeros(6,1);    

    visitTime   = 0;
    makeTime    = 0;
    growTime    = 0;
    pruneTime   = 0;
    featureTime = 0;
    reshapeTime = 0;

    first = struct('depth',0, 'locations',[], 'features',[]);
    
    first.depth            = 0;
    first.locations        = firstLocation;
    first.features         = features(first.locations, targetData{first.depth+1});
    
    stack = {first};
    
    if first.depth == finalDepth
        bestFeatures = first.features;
        bestPath     = first.locations;
        return;
    end
    
    while ~isempty(stack)
    
        myTic();            
            current    = stack{end};
            stack(end) = [];
            visitCount = visitCount + 1;
        visitTime = visitTime + myToc();
        
        myTic();
            nextDepth          = current.depth+1;
            nextHistory        = current.locations(:,1:3);
            nextLocations      = current.locations(:,1) + actions; 
            nextFeatures       = features(horzcat(nextLocations,nextHistory),targetData{nextDepth+1});
            nextFeatures       = vertcat(nextFeatures(1:end-5)', repmat(nextFeatures(end-4:end),1,actionCount));
            nextFeatures       = current.features + gamma^nextDepth * nextFeatures;            
        featureTime = featureTime + myToc();
        
        myTic();
            isPrunable    = prunable(bestFeatures, nextFeatures, nextDepth, finalDepth, gamma, reward);
            prunableCount = sum(isPrunable);
            pruneCount    = pruneCount + (prunableCount) * (1+actionCount^(nextDepth-finalDepth));
        pruneTime = pruneTime + myToc();
        
        for a = find(~isPrunable)'
            
            myTic();            
                thisFeatures  = nextFeatures(:,a);
                thisLocations = horzcat(nextLocations(:,a), current.locations);
            reshapeTime = reshapeTime + myToc();
            
            %if we didn't prune above, and we're on the leaf node now, we know this path is better than the current best
            if nextDepth == finalDepth
                if (bestFeatures - thisFeatures)' * reward < 0
                    bestFeatures = thisFeatures;
                    bestPath     = thisLocations;
                end
                continue;
            end
            
            myTic();            
                next = struct('depth',nextDepth, 'locations',thisLocations, 'features',thisFeatures);
            makeTime = makeTime + myToc();
            
            myTic();
                stack{end+1} = next;
            growTime = growTime + myToc();
        end        
    end
end

function myTic()
    %tic
end

function t = myToc()
    t = 0;    
    %t = toc;   
end

function p = prunable(bestFeatures, currentFeatures, currentDepth, finalDepth, gamma, reward)

    %Assumes that R \in [0,1]; This is a heuristic
    potentialRemainingReward = ((1-gamma^finalDepth)/(1-gamma) - (1-gamma^currentDepth)/(1-gamma));    
    rewardGainedOnPathSoFar  = currentFeatures' * reward;        
    rewardFromBestPathEver   = bestFeatures' * reward;
    notPossibleToBeatBest    = rewardFromBestPathEver - (rewardGainedOnPathSoFar + potentialRemainingReward) > 0;
    
    p = notPossibleToBeatBest;
        
end