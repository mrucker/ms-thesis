function expectedFeatures = featureExpectation(root, actions, reward, targets, gamma)

    finalDepth   = size(targets,2);
    bestFeatures = [0,0,0,0];
    stack        = {struct('depth',0, 'locations',root, 'features',features(root, targets{0}),  'parentFeatures',[0,0,0,0])};
    
    while ~isempty(stack)
    
        current = stack{end};
        stack(end) = [];        
        
        if(current.depth == finalDepth)
            %determine total reward, if better than best update best.            
            pathFeatures = current.parentFeatures + gamma^current.depth * current.features;
            pathReward   = reward * pathFeatures;
            
            if (isempty(bestFeatures) || pathReward > bestFeatures*reward)
                bestFeatures = pathFeatures;
            end
            
            continue;
        end
        
        if prunable(current.parentFeatures, bestFeatures, current.features, current.depth, finalDepth, gamma, reward)
            continue;
        end        
                
        for a = actions            
            next = struct('depth',0, 'locations',current.locations, 'features',[],  'parentFeatures',[]);
            
            next.depth = current.depth+1;
            next.locations(2:end,:) = next.locations(1:end-1,:);
            next.locations(1,:)     = next.current(1,:) + a';            
            next.features           = features(next.locations, targets{next.depth});            
            next.parentFeatures     = current.parentFeatures + gamma^current.depth * current.features;
            
            stack{end+1} = next;
        end        
    end
    
    expectedFeatures = bestFeatures;
end

function f = features(cursorLocations, targets)

    f = [0,0,0,0];

    for t = targets
        %the distances of all my cursorLocations from target t
        f = f + diag((t' - cursorLocations)*(t' - cursorLocations)');
    end

    f = f/size(targets,2);
end

function p = prunable(bestFeatures, parentFeatures, currentFeatures, currentDepth, finalDepth, gamma, reward)
    
    % R(best)-R(parents)-\sum_{i=depth+1}_{finalDepth}gamma^i >= gamma^depth*R(current)
    
    p = ((bestFeatures - parentFeatures) * reward - ((1-gamma^finalDepth)/(1-gamma) - (1-gamma^currentDepth)/(1-gamma))) >= gamma^currentDepth*currentFeatures*reward;
        
end