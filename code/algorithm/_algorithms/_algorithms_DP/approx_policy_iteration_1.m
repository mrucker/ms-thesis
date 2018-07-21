%time dependent value, finite horizon, discrete actions, post-decision,
%forwards-backwards, non-optimistic, recursive linear basis regression.
function v_thetas = approx_policy_iteration_1(s_1, actions, reward, value_basii, transition_post, transition_pre, gamma, N, M, T)

    %the bigger N, the more policies we iterate through when trying to find the best policy
    %the bigger M, the better our estimate of v_theta for the given basis functions

    B = cell(1,T);
    S = cell(1,T);

    b_cnt = size(value_basii(s_1()),1);
    theta = mat2cell(ones([T*b_cnt N])*400, ones(1,T)*b_cnt, ones(1,N));
    
    for n = 1:N 
        
        for m = 1:M 

            S{1} = s_1();
            
            for t = 1:T

                action_matrix = actions(S{t});
                action_values = reward(S{t}) + gamma * theta{1,n}' * value_basii(transition_post(S{t}, action_matrix));

                [~, a] = max(action_values);

                if(t ~= T)
                    S{t+1} = transition_pre(S{t}, action_matrix(:,a));
                end
            end

            V = zeros(1,T+1);
            
            for t = T:-1:1
                V(t) = reward(S{t}) + gamma * V(t+1);
            end
            
            if m == 1
                % this is right, I think the idea is that 
                % since policy iteration only changes the policy a little
                % we should start from our previous observations and update from there
                % furthermore, if this is the approach we are taking then we shouldn't erase B
                theta(:,n+1) = theta(:,n);                
            end
            
            X = value_basii(cell2mat(S))';
            Y = V;
            
            for t = 1:1
                [B{t}, theta{t,n+1}] = recursive_linear_regression(B{t}, theta{t,n+1}, X(t,:), Y(t));
            end

        end    
    end
    
    v_thetas = theta{1,N+1};
end