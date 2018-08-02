%time-independent value, finite horizon, discrete actions, post-decision,
%forwards-backwards, non-optimistic, recursive linear basis regression.
function [v_func, f_time, b_time, v_time] = least_squares_temporal_difference(s_1, actions, reward, value_basii, transition_post, transition_pre, gamma, N, M, T)

    f_time = 0;
    b_time = 0;
    v_time = 0;

    %the bigger N, the more policies we iterate through when trying to find the best policy
    %the bigger M, the better our estimate of v_theta for the given basis functions
    
    step  = 2;
    b_cnt = size (value_basii(s_1()),1);
    V     = cell (1, N+1);
    X     = zeros(b_cnt + 1, M*N);
    Y     = zeros(1        , M*N);
    
    V{1} = @(xi) 4;
    
    for n = 1:N 

        for m = 1:M 

            s_a = s_1();
            s_t = transition_pre(s_a, []);
            v_m = reward(s_t);

            t_start = tic;
            for t = 1:(T-1)

                action_matrix = actions(s_t);
                action_basii  = [value_basii(transition_post(s_t, action_matrix))',step*(n-1)*ones(size(action_matrix,2), 1)];
                action_values = V{n}(action_basii);
                
                [~, a_i] = max(action_values);

                s_t = transition_pre(s_t, action_matrix(:,a_i));
                v_m = v_m + gamma^(t) * reward(s_t);
            end
            f_time = f_time + toc(t_start);
            
            X(:, M*(n-1)+m) = [value_basii(s_a); step*(n-1)];
            Y(1, M*(n-1)+m) = v_m;

        end
        
        lambda = .1;
        sigma  = 2;
        
        t_start = tic;
            V{n+1} = batch_ridge_regression(X',Y', lambda, k_gaussian(k_norm(),sigma));
        v_time = v_time + toc(t_start);

    end

    v_func = @(s) V{N+1}([value_basii(s)',step*N*ones(size(s,2), 1)]);
end