%unlike traditional VI, this method solves for only the start_state
function [best_basii, best_value] = exact_tree_search(start_state, actions, final_depth, gamma, reward_weights, reward_basii, model_trans)

    depths = [];
    states = [];
    basii  = [];

    prune_count  = 0;
    visit_count  = 0;
    eval_count   = 0;
    branch_count = size(actions,2);

    %potentialReward = arrayfun(@(d)(1-gamma^d)/(1-gamma), [finalDepth:-1:1])

    visit_time = 0;
    basii_time = [0,0,0,0,0];
    prune_time = 0;
    store_time = 0;

    if final_depth == 0
        best_basii = reward_basii(start_state);
    else
        depths = 0;
        states = start_state;
        basii  = reward_basii(start_state);

        best_basii = [];
    end
    
    while ~isempty(basii)
    
        myTic();
            curr_depth   = depths  (  end);
            curr_state   = states  (:,end);
            curr_feature = basii(:,end);

            depths(  end) = [];
            states(:,end) = [];
            basii (:,end) = [];

            visit_count = visit_count + 1;
        visit_time = visit_time + myToc();

        myTic();
            next_depth  = curr_depth+1;
        basii_time(1) = basii_time(1) + myToc();

        myTic();
            next_states = model_trans(curr_state, actions);
        basii_time(2) = basii_time(2) + myToc();

        myTic();
            next_basii = reward_basii(next_states);
            assert(all((next_basii' * reward_weights)< 1), 'my pruning bounds will not work if we can ever get more reward than 1 on any step');
        basii_time(3) = basii_time(3) + myToc();

        myTic();
            next_basii = curr_feature + gamma^next_depth * next_basii;
        basii_time(4) = basii_time(4) + myToc();

        myTic();
            is_prunable = prunable(best_basii, next_basii, next_depth, final_depth, gamma, reward_weights);

            if final_depth ~= next_depth
                prune_count = prune_count + sum(is_prunable)*branch_count^(final_depth-next_depth);
            end

            eval_count  = eval_count + branch_count;

            next_basii  = next_basii (:,~is_prunable);
            next_states = next_states(:,~is_prunable);

            if next_depth == final_depth
                [val,index] = max(next_basii' * reward_weights);

                if ~isempty(next_basii) && (isempty(best_basii) || (val > best_basii'*reward_weights))
                    best_basii = next_basii(:,index);
                    best_value = val;
                end

                continue;
            end
        prune_time = prune_time + myToc();

        myTic();
            depths = [depths  , repmat(next_depth, 1, sum(~is_prunable))];
            states = horzcat(states  , next_states);
            basii  = [basii, next_basii];
        store_time = store_time + myToc();
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