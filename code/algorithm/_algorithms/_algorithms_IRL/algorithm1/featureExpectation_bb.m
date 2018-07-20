function [bestFeatures] = featureExpectation_bb(startingState, finalDepth, actions, reward, gamma, feat)

    depths   = [];
    states   = [];
    features = [];

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
        bestFeatures = feat(startingState);
        %bestPath    = reshape(firstLocation,[],4);
    else
        depths   = 0;
        states   = startingState;
        features = feat(startingState);

        %bestPath    = [];
        bestFeatures = [];
    end
    
    while ~isempty(features)
    
        myTic();
            currentDepth   = depths  (  end);
            currentState   = states  (:,end);
            currentFeature = features(:,end);

            depths  (  end) = [];
            states  (:,end) = [];
            features(:,end) = [];

            visitCount = visitCount + 1;
        visitTime = visitTime + myToc();

        myTic();
            nextDepth  = currentDepth+1;
        featureTime(1) = featureTime(1) + myToc();

        myTic();
            nextStates = huge_trans_post(currentState, actions, false);
        featureTime(2) = featureTime(2) + myToc();

        myTic();
            nextFeatures = feat(nextStates);
            assert(all((nextFeatures' * reward)< 1), 'my pruning bounds will not work if we can ever get more reward than 1 on any step');
        featureTime(3) = featureTime(3) + myToc();

        myTic();
            nextFeatures = currentFeature + gamma^nextDepth * nextFeatures;
        featureTime(4) = featureTime(4) + myToc();

        myTic();
            isPrunable    = prunable(bestFeatures, nextFeatures, nextDepth, finalDepth, gamma, reward);

            if finalDepth ~= nextDepth
                pruneCount    = pruneCount + sum(isPrunable)*actionCount^(finalDepth-nextDepth);
            end

            processCount  = processCount + actionCount;

            nextFeatures = nextFeatures(:,~isPrunable);
            nextStates   = nextStates  (:,~isPrunable);

            if nextDepth == finalDepth
                [val,index] = max(nextFeatures' * reward);

                if ~isempty(nextFeatures) && (isempty(bestFeatures) || (val > bestFeatures'*reward))
                    bestFeatures = nextFeatures(:,index);
                end

                continue;
            end
        pruneTime = pruneTime + myToc();

        myTic();
            depths   = [depths  , repmat(nextDepth, 1, sum(~isPrunable))];
            states   = horzcat(states  , nextStates);
            features = [features, nextFeatures];
        growTime = growTime + myToc();
    end

    %visitCount
    %processCount
    %pruneCount
end

%[visitTime,featureTime,pruneTime,growTime] / sum([visitTime,featureTime,pruneTime,growTime])

function myTic()
    tic
end

function t = myToc()
    t = 0;    
    t = toc;
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