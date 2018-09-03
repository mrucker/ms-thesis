function [Pf, Vf, Xs, Ys, Ks, As, f_time, b_time, m_time, a_time] = approx_policy_iteration_13k(s_1, actions, reward, value_basii, trans_post, trans_pre, gamma, N, M, T, W)

    a_start = tic;

    [v_i, v_p, v_b, v_l] = value_basii();

    v_p = v_p();
    v_n = size(v_p,2);
    v_v = 3*ones(1,v_n);

    g_row = [gamma.^(0:T-1), zeros(1,W-1)];
    g_mat = zeros(W,size(g_row,2));

    for w = 1:W
        g_mat(w, :) = circshift(g_row,w-1);
    end

    f_time = 0;
    b_time = 0;
    m_time = 0;

    Pf = cell(1, N+1);
    
    Y = NaN  (1, v_n); %observed value
    K = zeros(1, v_n); %visitation count
    A = NaN  (1, v_n); %step size
    S = NaN  (1, v_n); %error variance
    J = NaN  (1, v_n); %iteration visit    

    %one for every value_basii updated for entire life of program
    epsilon = NaN(1, v_n);
    beta    = NaN(1, v_n);
    nu      = NaN(1, v_n);
    sig_sq  = NaN(1, v_n);
    alpha   = NaN(1, v_n);
    eta     = NaN(1, v_n);
    lambda  = NaN(1, v_n);

    for n = 1:N

        if mod(n-1,4) == 0
            init_states = arrayfun(@(m) s_1(), 1:M, 'UniformOutput', false);
        end

        init = init_states(randperm(numel(init_states), M)); 
        stdY = std(Y(~isnan(Y)));

        X_b_m = arrayfun(@(i) zeros(1,T+W-1), 1:M, 'UniformOutput', false);
        X_s_m = arrayfun(@(i) cell (1,T+W-1), 1:M, 'UniformOutput', false);

        temp_SE                 = sqrt(S);
        temp_SE(isnan(temp_SE)) = stdY;

        init_se = cellfun(@(s_t) temp_SE(v_i(v_l(trans_post(s_t, actions(s_t))))), init, 'UniformOutput', false);

        t_start = tic;
        for m = 1:M

            s_t = init{m};

            for t = 1:T+W-1

                post_states = trans_post(s_t, actions(s_t));
                post_v_is   = v_i(v_l(post_states));
                post_values = v_v(post_v_is);

                if(t == 1)
                    post_values = post_values + 1.5*init_se{m};
                end

                [~,m_i] = max(post_values);
                a_i = m_i(randi(numel(m_i)));

                s_t = trans_pre(post_states(:,a_i), []);

                X_s_m{m}{t} = s_t;
                X_b_m{m}(t) = post_v_is(a_i);

            end
        end
        f_time = f_time + toc(t_start);

        %grows by M*(T+W-1) each n then resets at (n-1)%4==0
        init_states = horzcat(init_states, horzcat(X_s_m{:}));

        t_start = tic;
        for m = 1:M
            X_rewd = cellfun(reward, X_s_m{m});

                for w = 1:W
                    i = X_b_m{m}(w);
                    y = g_mat(w,:) * X_rewd';
                    k = K(i);

                    if ~isnan(Y(i))
                        %these step size calculations taken from Pg. 446-447 in
                        %Approximate Dynamic Programming by Powell in 2011
                        e = Y(i) - y;

                        if(e == 0 && k > 2)
                            %for some reason I keep getting 0 error in my
                            %estimate, even after four iterations. This in turn
                            %causes my estimate of my estimators bias (b)
                            %and the estimate of its variance (v) to become
                            %zero in some cases making my stepsize (a) NaN.
                            %to combat this I'll add a small perturbation
                            %with zero mean. That way the bias will be
                            %small but still existant
                            e = .5*(.5 - rand);
                        end

                        b = (1-eta(i))*beta(i) + eta(i)*e;
                        v = (1-eta(i))*nu(i) + eta(i)*(e^2);
                        s = (v - b^2)/(1+lambda(i));

                        if(k > 2)
                            assert(~( (s/v) > 10000 || any(isnan([e, b, v, s, s/v])) || any(isinf([e, b, v, s, s/v])) ))
                        end

                        epsilon(i) = e;
                        beta   (i) = b;
                        nu     (i) = v;
                        sig_sq (i) = s;

                        Y(i) = (1-alpha(i))*Y(i) + alpha(i)*y;
                        K(i) = k + 1;
                        A(i) = alpha(i);
                        S(i) = sig_sq(i);
                        J(i) = 1/3*J(i) + 2/3*n;

                        l = ((1-alpha(i))^2)*lambda(i) + alpha(i)^2;

                        %the book suggests k <= 2... but it just seems to take longer
                        %for my particlar setup to get an estimate of the bias
                        if (k <= 2)
                            a = 1/(k+1);
                        else
                            a = 1 - (s/v);
                        end

                        if(k == 1)
                            e = 1;
                        else
                            e = eta(i)/(1+eta(i)-.05);
                        end

                        %while it seems incorrect... I think it is ok for
                        %alpha to be less than one... I think... any([a,e] < 0)
                        assert(~( any(1.0001 < [a,e]) || any(isnan([a, e, l])) || any(isinf([a, e, l]))));

                        alpha (i) = a;
                        eta   (i) = e;
                        lambda(i) = l;

                    else
                        Y(i) = y;
                        K(i) = 1;
                        A(i) = 1;
                        S(i) = 2;
                        J(i) = n;

                        %this is the "initialization" step from the algorithm
                        epsilon(i) = 0; % we don't use for a few iterations
                        beta   (i) = 0; % we don't use for a few iterations
                        nu     (i) = 0; % we don't use for a few iterations
                        alpha  (i) = 1;
                        eta    (i) = 1;
                        lambda (i) = 0; % we don't use for a few iterations
                    end
                end
        end
        b_time = b_time + toc(t_start);

        t_start = tic;

            %https://www.mathworks.com/help/stats/fitrsvm.html#busljl4-BoxConstraint
            if iqr(Y) < .0001
                box_constraint = 1;
            else
                box_constraint = iqr(Y)/1.349;
            end

            X = vertcat(v_p(:,~isnan(Y)), J(~isnan(Y)));

            model = fitrsvm(X',Y(~isnan(Y))','KernelFunction','rbf', 'BoxConstraint', box_constraint, 'Solver', 'SMO', 'Standardize',true);

            X = vertcat(v_p, n*ones(1,v_n));

            v_v = predict(model, X')';

            if(n == N)
                Pf{n+1} = policy_function(actions, @(ss) v_v(v_i(v_l(ss))), trans_post);
            else
                Pf{n+1} = policy_function(actions, @(ss) predict(model, vertcat(v_b(v_l(ss)), n*ones(1,size(ss,2)))'), trans_post);
            end

        m_time = m_time + toc(t_start);
    end

    %here for backwards compatibility
    Vf = []; Xs = []; Ys = []; Ks = []; As = [];
    
    a_time = toc(a_start);
end