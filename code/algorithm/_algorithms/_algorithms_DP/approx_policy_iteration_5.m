%time-independent value, finite horizon, discrete actions, post-decision,
%forwards-backwards, non-optimistic, recursive linear basis regression.
function [Vs, Xs, Ys, f_time, b_time, v_time] = approx_policy_iteration_5(s_1, actions, reward, value_basii, transition_post, transition_pre, gamma, N, M, T)

    w_size = min(10,T);
    lambda = .01;
    sigma  = 3.5;

    g_row = [gamma.^(0:w_size-1), zeros(1,T-w_size)];
    g_mat = zeros(T-w_size+1,size(g_row,2));

    for t = 0:T-w_size
        g_mat(t+1,:) = circshift(g_row,t);
    end

    f_time = 0;
    b_time = 0;
    v_time = 0;

    Vs = cell(1, N+1);
    Xs = cell(1, N);
    Ys = cell(1, N);

    X = [];
    Y = [];
    S = [];

    Vs{1} = @(xi) 4*ones(1,size(xi,2));

    for n = 1:N 

        for m = 1:M 

            s_a = s_1();
            s_t = transition_pre(s_a, []);

            X_post(:,1) = value_basii(s_a);
            X_rewd (:,1) = reward(s_t);

            t_start = tic;
            for t = 1:(T-1)

                action_matrix = actions(s_t);

                post_states = transition_post(s_t, action_matrix);
                post_values = Vs{n}(post_states);

                a_m = max(post_values);
                a_i = find(post_values == a_m);
                a_i = a_i(randi(length(a_i)));

                s_a = post_states(:,a_i);
                s_t = transition_pre(s_a, []);

                X_post(:,t+1) = value_basii(s_a);
                X_rewd(:,t+1) = reward(s_t);
            end
            f_time = f_time + toc(t_start);

            t_start = tic;
                X = [X, X_post(:,1:T-w_size+1)];
                Y = [Y, X_rewd * g_mat'];
                S = [S, ones(1,T-w_size+1)];
            b_time = b_time + toc(t_start);
        end

        t_start = tic;
            [~,is,gs]=unique(X', 'rows');
            X = X(:,is);
            Y = grpstats(1:numel(Y),gs, @(gi) sum(Y(gi).*S(gi))/sum(S(gi)) )';
            S = grpstats(S,gs, @(ss) sum(ss))';

            Xs{(n-1)*M + m} = X;
            Ys{(n-1)*M + m} = Y;
        b_time = b_time + toc(t_start);

        
        t_start = tic;
            k = batch_ridge_regression(X',Y', lambda, k_gaussian(k_norm(),sigma));
            Vs{n+1} = @(s) k(value_basii(s)');
        v_time = v_time + toc(t_start);
    end
end