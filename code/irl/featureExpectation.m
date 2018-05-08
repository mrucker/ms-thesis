function expectedFeatures = featureExpectation(featureExpert, firstLocation, targetData, actions, reward, gamma)

    pruneCount   = 0;
    visitCount   = 0;
    finalDepth   = size(targetData,1)-1;
    bestFeatures = featureExpert;
    
    visitTime = 0;
    makeTime  = 0;
    growTime  = 0;
    pruneTime = 0;
    
    
    first = struct('depth',0, 'locations',[], 'features',[],  'parentFeatures',[]);
    
    first.depth            = 0;
    first.locations        = firstLocation;
    first.features         = features(first.locations, targetData{first.depth+1});
    first.parentFeatures   = [0,0,0,0,0,0]'; %[d1,d2,d3,d4,touched,age]
    
    stack = {first};
    
    while ~isempty(stack)
    
        tic
        visitCount = visitCount + 1;
        current = stack{end};
        stack(end) = [];
        visitTime = visitTime + toc;

        for a = actions
            
            tic

            next = struct('depth',0, 'locations',current.locations, 'features',[],  'parentFeatures',[]);            
            
            next.depth              = current.depth+1;
            next.locations(:,2:end) = next.locations(:,1:end-1);
            next.locations(:,1)     = next.locations(:,1) + a;            
            next.features           = features(next.locations, targetData{next.depth+1});
            next.parentFeatures     = current.parentFeatures + gamma^current.depth * current.features;
            makeTime = makeTime + toc;
            
            tic
            if prunable(bestFeatures, next.parentFeatures, next.features, next.depth, finalDepth, gamma, reward)
                pruneCount = pruneCount + 400^(next.depth-finalDepth);
                continue;
            end
            pruneTime = pruneTime + toc;
            
            %if we didn't prune above, and we're on the leaf node now, we know this path is better than the current best
            if next.depth == finalDepth
                bestFeatures = next.parentFeatures + gamma^next.depth * next.features;
                continue;
            end
            
            tic
            stack{end+1} = next;
            growTime = growTime + toc;
        end        
    end
    
    expectedFeatures = bestFeatures;
end

function p = prunable(bestFeatures, parentFeatures, currentFeatures, currentDepth, finalDepth, gamma, reward)
    
    % There may be an incorrect calculation here regarding the partial geometric series terminating at finalDepth
    % R(best)-R(parents)-\sum_{i=depth+1}_{finalDepth}gamma^i >= gamma^depth*R(current)    
    p = ((bestFeatures - parentFeatures)' * reward - ((1-gamma^finalDepth)/(1-gamma) - (1-gamma^currentDepth)/(1-gamma))) > gamma^currentDepth*currentFeatures'*reward;
        
end