%Be careful, if states is too big, realizing the whole policy may overload memory.
%Also, this assumes that reward is not dependent on action. If it is this won't work.
function P = approx_policy_realization(states, actions, v_theta, v_basii, transition_post)
    
    P = zeros(size(states,2), 1);
    
    for s_i = 1:size(states,2)
        
        s = states(:,s_i);
        
        action_matrix = actions(s);
        action_values = v_theta' * v_basii(transition_post(s, action_matrix));

        [~, P(s_i)] = max(action_values);
    end
end