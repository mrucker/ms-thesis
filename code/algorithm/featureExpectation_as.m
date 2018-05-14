function [bestPath,bestFeatures] = featureExpectation_as(firstLocation, targetData, actions, reward, gamma, feat)

    e_depth     = [];
    e_location  = [];
    e_feature   = [];
    e_potential = [];

    visitCount  = 0;
    finalDepth  = size(targetData,1)-1;
    actionCount = size(actions,2);
    
    visitTime   = 0;
    featureTime = [0,0,0,0,0];
    pruneTime   = 0;
    growTime    = 0;

    if finalDepth == 0
        bestFeatures = feat(firstLocation(1:2), firstLocation(3:8), targetData{1});
        bestPath     = firstLocation;
        bestReward   = bestFeatures' * reward;
    else
        e_depth     = [0];
        e_location  = reshape(firstLocation,[],1);
        e_feature   = feat(firstLocation(1:2), firstLocation(3:8), targetData{1});
        e_potential = potential(e_feature, 0, finalDepth, gamma, reward);
        
        bestPath     = [];
        bestFeatures = [];
        bestReward   = -inf;
    end
    
    while ~isempty(e_feature)
                
        myTic()
            [~,i] = max(e_potential);

            currentDepth    = e_depth(:,i);
            currentLocation = e_location(:,i);
            currentFeatures = e_feature(:,i);

            e_depth    (:,i) = [];
            e_location (:,i) = [];
            e_feature  (:,i) = [];
            e_potential(:,i) = [];

            visitCount = visitCount + 1;
        visitTime = visitTime + myToc();

        if currentDepth == finalDepth
            break;
        end
        
        myTic();
            nextDepth          = currentDepth+1;
            nextHistory        = reshape(currentLocation(1:6),[],3);
            nextLocations      = currentLocation(1:2) + actions;
        featureTime(1) = featureTime(1) + myToc();
        myTic();
            nextFeatures  = feat(nextLocations, nextHistory, targetData{nextDepth+1});
            assert(all((nextFeatures' * reward)< 1), 'my pruning bounds will not work if we can ever get more reward than 1 on any step');
        featureTime(2) = featureTime(2) + myToc();
        
        myTic();
            nextLocations = vertcat(nextLocations,repmat(currentLocation(1:6),1,actionCount));
            nextFeatures  = currentFeatures + gamma^nextDepth * nextFeatures;
            nextPotential = potential(nextFeatures, nextDepth, finalDepth, gamma, reward);            
        featureTime(3) = featureTime(3) + myToc();

        if nextDepth == finalDepth
            [v,i] = max(nextPotential);
            if  v > bestReward
                bestFeatures = nextFeatures(:,i);                    
                bestPath     = reshape(nextLocations(:,i),[],4);
                bestReward   = nextPotential(:,i);                
                
                e_depth    = [e_depth, nextDepth];
                e_location = [e_location, nextLocations(:,i)];
                e_feature  = [e_feature, nextFeatures(:,i)];
                e_potential= [e_potential, nextPotential(:,i)];
            end
        else
        
            myTic();
                keep = nextPotential > bestReward;
                
                nextDepth     = repmat(nextDepth,1,sum(keep));
                nextLocations = nextLocations(:,keep);
                nextFeatures  = nextFeatures(:,keep);
                nextPotential = nextPotential(:,keep);
                
                e_depth    = [e_depth, nextDepth];
                e_location = [e_location, nextLocations];
                e_feature  = [e_feature, nextFeatures];
                e_potential= [e_potential, nextPotential];
            pruneTime = pruneTime + myToc();
        end
        
    end
    
    visitCount
end

%[visitTime,featureTime,pruneTime,growTime] / sum([visitTime,featureTime,pruneTime,growTime])

function myTic()
    %tic
end

function t = myToc()
    t = 0;    
    %t = toc;
end

function p = potential(currentFeatures, currentDepth, finalDepth, gamma, reward)

    %Assumes that R \in [-inf,1]; This is a heuristic
    potentialRemainingReward = (gamma^(currentDepth+1)-gamma^(finalDepth+1))/(1-gamma);
    rewardGainedOnPathSoFar  = reward' * currentFeatures;
    
    % notPossibleToBeatBest
    p = rewardGainedOnPathSoFar + potentialRemainingReward;
        
end