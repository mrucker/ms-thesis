%Be careful, if states is too big, realizing the whole policy may overload memory.
%Also, this assumes that reward is not dependent on action. If it is this won't work.
function P = approx_policy_realization(states, actions, v_theta, v_basii, transition_post)
    
    P = zeros(size(states,2), 1);

    action_values = zeros(size(states,2),size(actions,2));
    
    for a_i = 1:size(actions,2)
        action_values(:,a_i) = v_theta' * v_basii(transition_post(states, actions(:,a_i)));
    end

    [~, P] = max(action_values, [], 2);
end