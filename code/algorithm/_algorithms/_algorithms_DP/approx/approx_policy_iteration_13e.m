function [Pf, Vf, Xs, Ys, Ks, As, f_time, b_time, m_time, a_time] = approx_policy_iteration_13e(s_1, actions, reward, value_basii, trans_post, trans_pre, gamma, N, M, T, W, production)

    if(nargin < 12)
        production = true;
    end

    a_start = tic;

    g_row = [gamma.^(0:T-1), zeros(1,W-1)];
    g_mat = zeros(W,size(g_row,2));

    for w = 1:W
        g_mat(w, :) = circshift(g_row,w-1);
    end

    f_time = 0;
    v_time = 0;
    b_time = 0;
    m_time = 0;

    Vf = cell(1, N+1);
    Pf = cell(1, N+1);
    
    if ~production    
        Xs = cell(1, N*M);
        Ys = cell(1, N*M);
        Ks = cell(1, N*M);
        As = cell(1, N*M);
    else
        Xs = {};
        Ys = {};
        Ks = {};
        As = {};
    end

    X = [];
    Y = [];
    K = [];
    A = [];
    S = [];

    %one for every value_basii
    %updated for entire life of program
    epsilon = [];
    beta    = [];
    nu      = [];
    sig_sq  = [];
    alpha   = [];
    eta     = [];
    lambda  = [];

    avb_p = all_value_basii_perms();
    avb_v(basii2indexes(avb_p)) = 3*ones(1,size(avb_p,2));

    for n = 1:N

        X_s_m = cell(1, M);
        X_b_m = cell(1, M);
        X_r_m = cell(1, M);

        if n == 1
            all_states = arrayfun(@(m) s_1(), 1:M, 'UniformOutput', false);
        end

        init_states = all_states(randi(numel(all_states),1,M));
 
        t_start = tic;
        parfor m = 1:M

            %0.28
            post_states = trans_post(init_states{m}, actions(init_states{m}));
            post_basii  = value_basii(post_states);
            post_values = avb_v(basii2indexes(post_basii));

            %.11
            a_m = max(post_values);
            a_i = find(post_values == a_m);
            a_i = a_i(randi(length(a_i)));
            s_a = post_states(:,a_i);
            s_t = trans_pre(s_a, []);
            X_b_m{m} = [];
            X_r_m{m} = [];
            X_s_m{m}      = {s_t};
            X_b_m{m}(:,1) = post_basii(:,a_i);
            X_r_m{m}(:,1) = reward(s_t);

            for t = 1:((T-1)+(W-1))

                %2.25
                %1.68
                    %.09
                    action_matrix = actions(s_t);

                    %0.29
                    post_states = trans_post(s_t, action_matrix);

                    %1.26
                    [post_basii, time]  = value_basii(post_states);
                    v_time = v_time + time;

                    %.05
                    post_values = avb_v(basii2indexes(post_basii));

                %.04
                a_m = max(post_values);
                a_i = find(post_values == a_m);
                a_i = a_i(randi(length(a_i)));
                s_a = post_states(:,a_i);

                %.47
                %.22
                s_t = trans_pre(s_a, []);

                %.15
                X_s_m{m}        = horzcat(X_s_m{m}, s_t);

                %.06
                X_b_m{m}(:,t+1) = post_basii(:,a_i);

                %.32
                X_r_m{m}(:,t+1) = reward(s_t);
            end
        end
        f_time = f_time + toc(t_start);

        new_states = horzcat(X_s_m{:});
        all_states = horzcat(all_states, new_states);

        if numel(all_states) > 2000
            rng_indexs = randi(numel(all_states), 1, 2000);
            all_states = all_states(rng_indexs); 
        end

        t_start = tic;
        for m = 1:M
            X_base = X_b_m{m};
            X_rewd = X_r_m{m};

                for w = 1:W
                    i = coalesce_if_true(~isempty(X), @() all(X == X_base(:,w)));
                    y = g_mat(w,:) * X_rewd';
                    k = coalesce_if_empty(K(i),0);

                    if any(i)
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
                        beta(i)    = b;
                        nu(i)      = v;
                        sig_sq(i)  = s;

                        Y(i) = (1-alpha(i))*Y(i) + alpha(i)*y;
                        K(i) = k + 1;
                        A(i) = alpha(i);
                        S(i) = sig_sq(i);

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

                        alpha(i)  = a;
                        eta(i)    = e;
                        lambda(i) = l;

                    else
                        Y = [Y, y];
                        X = [X, X_base(:,w)];
                        K = [K, 1];
                        A = [A, 1];
                        S = [S, 2];

                        %for all intents and purposes this is the 0th
                        %(aka, initialization) step from the algorithm
                        epsilon = [epsilon;0]; %simply reserving space, this value isn't used
                        beta    = [beta;0];    % we don't use for a few iterations
                        nu      = [nu;0];      % we don't use for a few iterations
                        alpha   = [alpha;1];
                        eta     = [eta;1];
                        lambda  = [lambda;0];  % we don't use for a few iterations

                    end
                end

                if ~production
                    Xs{(n-1)*M + m} = X;
                    Ys{(n-1)*M + m} = Y;
                    Ks{(n-1)*M + m} = K;
                    As{(n-1)*M + m} = A;
                end
        end
        b_time = b_time + toc(t_start);

        t_start = tic;
            model = fitrsvm(X',Y','KernelFunction','rbf', 'Solver', 'SMO', 'Standardize',true);

            avb_v(basii2indexes(avb_p)) = predict(model, avb_p');
            
            Vf{n+1} = @(ss) predict(model, value_basii(ss)');
            Pf{n+1} = policy_function(actions, Vf{n+1}, trans_post);

        m_time = m_time + toc(t_start);
    end

    if v_time ~= 0
        fprintf('v_time(%f)\n',v_time);
    end
    a_time = toc(a_start);
end

function avp = all_value_basii_perms()
    adp = all_deriv_perms();
    atp = all_touch_perms();
    aap = all_approach_perms();
    alp = all_location_perms();
    
    [adp_c, atp_c, aap_c, alp_c] = ndgrid(1:size(adp,2), 1:size(atp,2), 1:size(aap,2), 1:size(alp,2));

    avp = vertcat(adp(:,adp_c(:)), atp(:,atp_c(:)), aap(:,aap_c(:)), alp(:,alp_c(:)));
end

function adp = all_deriv_perms()
    d1x_f = eye(3);
    d1y_f = eye(3);
    d2x_f = eye(3);
    d2y_f = eye(3);

    [d2y_c, d2x_c, d1y_c, d1x_c] = ndgrid(1:size(d2y_f,2), 1:size(d2x_f,2), 1:size(d1y_f,2), 1:size(d1x_f,2));

    adp = vertcat(d1x_f(:,d1x_c(:)), d1y_f(:,d1y_c(:)), d2x_f(:,d2x_c(:)), d2y_f(:,d2y_c(:)));
end

function atp = all_touch_perms()
    atp = [
        1 1 0 0;
        0 0 1 1;
        1 0 1 0;
        0 1 0 1;
    ];
end

function aap = all_approach_perms()
    xap_f = eye(3);
    yap_f = eye(3);
    bap_f = eye(3);

    [xap_c, yap_c, bap_c] = ndgrid(1:size(xap_f,2), 1:size(yap_f,2), 1:size(bap_f,2));

    aap = vertcat(xap_f(:,xap_c(:)), yap_f(:,yap_c(:)), bap_f(:,bap_c(:)));
end

function alp = all_location_perms()
    lox_f = eye(3);
    loy_f = eye(3);

    [lox_c, loy_c] = ndgrid(1:size(lox_f,2), 1:size(loy_f,2));

    alp = vertcat(lox_f(:,lox_c(:)), loy_f(:,loy_c(:)));
end

function b2k = basii2indexes(basii)
    b2k = [0 26244 52488 0 8748 17496 0 2916 5832 0 972 1944 0 486 0 243 0 81 162 0 27 54 0 9 18 0 3 6 1 2 3] * basii;
end