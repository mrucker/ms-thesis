%time dependent value, finite horizon, discrete actions, post-decision,
%forwards-backwards, non-optimistic, recursive linear basis regression.
function [v_func, f_time, b_time, v_time] = approx_policy_iteration_1(s_1, actions, reward, value_basii, transition_post, transition_pre, gamma, N, M, T, true_V, state2index)

    f_time = 0;
    b_time = 0;
    v_time = 0;

    %the bigger N, the more policies we iterate through when trying to find the best policy
    %the bigger M, the better our estimate of v_theta for the given basis functions

    B  = cell(1,T);
    S  = cell(1,T);
    SA = cell(1,T-1);
    
    b_cnt = size(value_basii(s_1()),1);
    theta = mat2cell(ones([T*b_cnt N])*4  , ones(1,T)*b_cnt, ones(1,N));

    for n = 1:N 

        for m = 1:M 

            SA{1} = s_1();
            S {1} = transition_pre(SA{1},[]);

            t_start = tic;
            for t = 1:(T-1)

                action_matrix = actions(S{t}); 

                %this is right, I should be using the post decision state,
                %however, below I'm not learning a post decision value function
                action_values = reward(S{t}) + gamma * theta{t,n}' * value_basii(transition_post(S{t}, action_matrix));

                [~, a_i] = max(action_values);
                
                SA{t+1} = transition_post(S{t}, action_matrix(:,a_i)); 
                S {t+1} = transition_pre (S{t}, action_matrix(:,a_i));
            end
            f_time = f_time + toc(t_start);

            V = zeros(1,T+1);

            t_start = tic;
            for t = T:-1:1
                %this backwards pass gives us an unbiased estimate rather
                %than bootstrapping from previously estimated V (pg. 393)
                V(t)  = reward(S{t}) + gamma * V(t+1);
            end
            b_time = b_time + toc(t_start);
            
            if m == 1
                % this is right, I think the idea is that 
                % since policy iteration only changes the policy a little
                % we should start from our previous observations and update from there
                % furthermore, if this is the approach we are taking then we shouldn't erase B
                theta(:,n+1) = theta(:,n);
            end

            %this is wrong, X should be the predecision state v_b
            X = value_basii(cell2mat(SA))';
            Y = V(1:end-1);

            t_start = tic;
            for t = 1:T
                [B{t}, theta{t,n+1}] = recursive_linear_regression(B{t}, theta{t,n+1}, X(t,:), Y(t), .9);
            end
            v_time = v_time + toc(t_start);

        end    
    end
    
    v_func = @(s) value_basii(s)' * theta{1,N+1};
end