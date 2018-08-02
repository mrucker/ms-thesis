%time-independent value, finite horizon, discrete actions, post-decision,
%forwards-backwards, non-optimistic, recursive linear basis regression.
function [v_func, f_time, b_time, v_time] = approx_policy_iteration_2(s_1, actions, reward, value_basii, transition_post, transition_pre, gamma, N, M, T, true_V, state2index)

    f_time = 0;
    b_time = 0;
    v_time = 0;

    %the bigger N, the more policies we iterate through when trying to find the best policy
    %the bigger M, the better our estimate of v_theta for the given basis functions

    B = [];
    
    b_cnt = size(value_basii(s_1()),1);
    theta = ones(b_cnt, N) * 4;
    
    for n = 1:N 

        for m = 1:M 

            s_a = s_1();
            s_n = transition_pre(s_a, []);
            v_m = reward(s_n);
            
            t_start = tic;
            for t = 1:(T-1)

                action_matrix = actions(s_n);
                action_values = theta(:,n)' * value_basii(transition_post(s_n, action_matrix));

                [~, a_i] = max(action_values);

                s_n = transition_pre(s_n, action_matrix(:,a_i));
                v_m = v_m + gamma^(t) * reward(s_n);
            end
            f_time = f_time + toc(t_start);

            if m == 1
                % this is right, I think the idea is that 
                % since policy iteration only changes the policy a little
                % we should start from our previous observations and update from there
                % furthermore, if this is the approach we are taking then we shouldn't erase B
                theta(:,n+1) = theta(:,n);
            end

            x = value_basii(s_a)';
            y = v_m;

            t_start = tic;
                [B, theta(:,n+1)] = recursive_linear_regression(B, theta(:,n+1), x, y, 1);
            v_time = v_time + toc(t_start);

        end
    end

    v_func = @(s) value_basii(s)' * theta(:,N+1);
end