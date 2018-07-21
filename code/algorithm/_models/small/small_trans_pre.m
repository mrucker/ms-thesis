function state_2 = small_trans_pre(state_1, action, states, actions, small_trans_matrix, state2index)
    a_i = find(all(actions == action),1);
    pmf = small_trans_matrix{a_i}(state2index(state_1), :);
    cdf = tril(ones(size(pmf,2))) * pmf';
        
    state_i = find(rand <= cdf, 1);
    
    if isempty(state_i)
        state_i = find(cdf,1,'last');
    end
    
    state_2 = states(:,state_i);
end