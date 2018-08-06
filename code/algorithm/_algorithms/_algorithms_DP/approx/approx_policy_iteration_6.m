function [Vf, Pf, Xs, Ys, Ks, As, f_time, b_time, v_time, a_time] = approx_policy_iteration_6(s_1, actions, reward, value_basii, trans_post, trans_pre, gamma, N, M, T, W)

    a_start = tic;

    g_row = [gamma.^(0:T-1), zeros(1,W-1)];
    g_mat = zeros(W,size(g_row,2));

    for w = 1:W
        g_mat(w, :) = circshift(g_row,w-1);
    end
    
    f_time = 0;
    b_time = 0;
    v_time = 0;

    Vf = cell(1, N+1);
    Xs = cell(1, N*M);
    Ys = cell(1, N*M);
    Ks = cell(1, N*M);
    As = cell(1, N*M);
    

    X = [];
    Y = [];
    K = [];
    A = [];

    Vf{1} = @(xi) 4*ones(1,size(xi,2));

    for n = 1:N 

        for m = 1:M 

            s_a = s_1();
            s_t = trans_pre(s_a, []);

            X_post(:,1) = value_basii(s_a);
            X_rewd (:,1) = reward(s_t);

            t_start = tic;
            for t = 1:((T-1)+(W-1))

                action_matrix = actions(s_t);

                post_states = trans_post(s_t, action_matrix);
                post_values = Vf{n}(post_states);

                a_m = max(post_values);
                a_i = find(post_values == a_m);
                a_i = a_i(randi(length(a_i)));

                s_a = post_states(:,a_i);
                s_t = trans_pre(s_a, []);

                X_post(:,t+1) = value_basii(s_a);
                X_rewd(:,t+1) = reward(s_t);
            end
            f_time = f_time + toc(t_start);

            t_start = tic;
%                 X = [X, X_post(:,1:W)];
%                 Y = [Y, X_rewd * g_mat'];
%                 S = [S, ones(1,W)];
                for w = 1:W
                    i = coalesce_if_true(~isempty(X), @() all(X == X_post(:,w)));
                    y = g_mat(w,:) * X_rewd';
                    k = coalesce_if_empty(K(i),0);

                    if any(i)
                        A(i) = 1/k;
                        Y(i) = (1-1/k)*Y(i) + (1/k) * y;
                        K(i) = k + 1;
                    else
                        Y = [Y, y];
                        X = [X, X_post(:,w)];
                        K = [K, 1];
                        A = [A, 1];
                    end
                end

                Xs{(n-1)*M + m} = X;
                Ys{(n-1)*M + m} = Y;
                Ks{(n-1)*M + m} = K;
                As{(n-1)*M + m} = A;

            b_time = b_time + toc(t_start);
        end

%         t_start = tic;
%             [~,is,gs]=unique(X', 'rows');
%             X = X(:,is);
%             Y = grpstats(1:numel(Y),gs, @(gi) sum(Y(gi).*S(gi))/sum(S(gi)) )';
%             S = grpstats(S,gs, @(ss) sum(ss))';
%             
%             Xs{n} = X;
%             Ys{n} = Y;
%         b_time = b_time + toc(t_start);

        t_start = tic;
            model = fitrsvm(X',Y','KernelFunction','gaussian');
            Vf{n+1} = @(s) predict(model, value_basii(s)');
        v_time = v_time + toc(t_start);
    end

    Pf = policy_function(actions, Vf{N+1}, trans_post);
    
    a_time = toc(a_start);
end