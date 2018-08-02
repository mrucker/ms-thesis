%time-independent value, finite horizon, discrete actions, post-decision,
%forwards-backwards, non-optimistic, recursive linear basis regression.
function [v_func, f_time, b_time, v_time] = approx_policy_iteration_6(s_1, actions, reward, value_basii, transition_post, transition_pre, gamma, N, M, T)

    w_size = min(10,T);
    lambda = .01;
    sigma  = 3.5;

    g_row = [gamma.^(0:w_size-1), zeros(1,T-w_size)];
    g_mat = [];
    
    for t = 0:T-w_size
        g_mat = [g_mat;circshift(g_row,t)];
    end
    
    f_time = 0;
    b_time = 0;
    v_time = 0;

    %the bigger N, the more policies we iterate through when trying to find the best policy
    %the bigger M, the better our estimate of v_theta for the given basis functions
    
    V     = cell (1, N+1);
    X     = [];
    Y     = [];
    
    V{1} = @(xi) 4*ones(1,size(xi,1));
    
    for n = 1:N 

        for m = 1:M 

            s_a = s_1();
            s_t = transition_pre(s_a, []);

            X_post(:,1) = value_basii(s_a);
            X_rew (:,1) = reward(s_t);

            t_start = tic;
            for t = 1:(T-1)
            
                action_matrix = actions(s_t);
                post_states   = transition_post(s_t, action_matrix);
                post_basii    = value_basii(post_states);

                post_values = V{n}(post_basii');

                a_m = max(post_values);
                a_i = find(post_values == a_m);
                a_i = a_i(randi(length(a_i)));

                s_a = post_states(:,a_i);
                s_t = transition_pre(s_a, []);
                X_post(:,t+1) = post_basii(:,a_i);
                X_rew (:,t+1) = reward(s_t);

            end
            f_time = f_time + toc(t_start);

            t_start = tic;
                X = [X, X_post(:,1:T-w_size+1)];
                Y = [Y, X_rew * g_mat'];
            b_time = b_time + toc(t_start);
        end

        t_start = tic;
            [~,i,g]=unique(X', 'rows');

            X = X(:,i);
            Y = grpstats(Y,g)';
            k = fitrsvm(X',Y','KernelFunction','gaussian');
            
            V{n+1} = @(x) predict(k, x);
        v_time = v_time + toc(t_start);
    end

    v_func = @(s) V{N+1}(value_basii(s)');
end