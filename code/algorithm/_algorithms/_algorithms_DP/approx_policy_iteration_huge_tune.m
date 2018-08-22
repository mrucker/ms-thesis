clear
close all
fprintf('\n');
try run('../../paths.m'); catch; end

rewd_count = 20;
eval_steps = 10;

trans_pre = @(s,a) huge_trans_pre (s,a);
trans_pst = @(s,a) huge_trans_post(s,a);

as = actions_matrix();

s_1 = @( ) state_rand();
v_b = @(s) value_basii_cells(s, @value_basii_2);
s_a = @(s) actions_valid(s, as);

%algorithm_2   == (lin ols regression with n-step Monte Carlo                             )
%algorithm_5   == (gau ridge regression                                                   )
%algorithm_8   == (gau svm regression with n-step Monte Carlo, BAKF, and ONPOLICY sampling)
%algorithm_8b  == (algorithm_8 except I've reintroduced an old bug that made it run better)
%algorithm_12  == (algorithm_8 but with bootstrapping after n-step Monte Carlo            )
%algorithm_13  == (algorithm_8 but with interval estimation to choose the first action    )
%algorithm_13b == (algorithm_13 but with a small bug fix around the on-policy distribution)
%algorithm_14  == (full tabular TD lambda with interval estimation and on-policy sampling )

algos = {
    @approx_policy_iteration_13h, 'algorithm_13h';
};

states_c = cell(1, rewd_count);
reward_f = cell(1, rewd_count);

for r_i = 1:rewd_count
    reward_basii_n = size(reward_basii(s_1()),1);
    reward_theta_r = reward_theta(reward_basii_n);

    reward_f{r_i} = @(s) reward_theta_r'*reward_basii(s);
    states_c{r_i} = state_init();
end

for a_i = 1:size(algos,1)

    ts = tunings();
    
    for tuning = ts

        fT = zeros(1,rewd_count);
        bT = zeros(1,rewd_count);
        mT = zeros(1,rewd_count);
        aT = zeros(1,rewd_count);

        max_vs = zeros(1,rewd_count);
        avg_vs = zeros(1,rewd_count);
        lst_vs = zeros(1,rewd_count);
        var_vs = zeros(1,rewd_count);

        for r_i = 1:rewd_count

            G = 0.9;
            L = tuning(1);
            N = tuning(2);
            M = tuning(3);
            S = tuning(4);
            W = tuning(5);

            [Pf, ~, ~, ~, ~, ~, fT(r_i), bT(r_i), mT(r_i), aT(r_i)] = algos{a_i,1}(s_1, s_a, reward_f{r_i}, v_b, trans_pst, trans_pre, G*L, N, M, S, W);

            eval_states = states_c{r_i};
            eval_reward = reward_f{r_i};

            vs = zeros(1, numel(Pf)-1);

            parfor Pf_i = 2:numel(Pf)
                vs(Pf_i-1) = policy_eval_at_states(Pf{Pf_i}, eval_states, eval_reward, 0.9, eval_steps, trans_pre, 100);
            end

            max_vs(r_i) = max(vs);
            avg_vs(r_i) = mean(vs(6:end));
            lst_vs(r_i) = vs(end);
            var_vs(r_i) = var(vs(6:end));
        end

        p_results(algos{a_i,2}, tuning, max_vs, avg_vs, lst_vs, var_vs, fT, bT, mT, aT);
    end

end

function a = actions_matrix()
    dx = [100,50,10,2,0];
    dy = [100,50,10,2,0];

    dx = horzcat(dx,0,-dx);
    dy = horzcat(dy,0,-dy);

    a = vertcat(reshape(repmat(dx,numel(dx),1), [1,numel(dx)^2]), reshape(repmat(dy',1,numel(dy)), [1,numel(dy)^2]));
end

function a = actions_valid(s, a)
    np = s(1:2) + a;

    np_too_small_x = np(1,:) < 0;
    np_too_small_y = np(2,:) < 0;
    np_too_large_x = np(1,:) > s(9);
    np_too_large_y = np(2,:) > s(10);

    valid_actions = ~(np_too_small_x|np_too_small_y|np_too_large_x|np_too_large_y);

    a = a(:, valid_actions);
end

function s = state_init()
    s = {
       [1145;673;-8;-2;-1;6;-7;4;3175;1535;156;626;555;155;2249;305;60];
       [1158;673;15;0;10;0;5;0;3175;1535;156;626;555;155;2249;305;60];
       [1588;768;0;0;0;0;0;0;3175;1535;156;626;555;155;2249;305;60];
   };
end

function s = state_rand()
    population = state_init();

    s = population{randi(numel(population))};
end

function rbs = reward_basii(states)

    rbs = [];

    for i = 1:size(states,2)
        if iscell(states)
            state = states{i};
        else
            state = states(:,i);
        end

        ds = abs(states(3:6,:));

        deriv_features = [
            double(0  <= ds & ds < 15 );
            double(15 <= ds & ds < 50 );
            double(50 <= ds & ds < inf);
        ];

        deriv_deg = 1:4:12;
        deriv_ind = 0:size(ds,1)-1;
        deriv_ord = reshape(deriv_deg' + deriv_ind,1,[]);

        tc = target_touch_features(state);

        rb = [
            deriv_features(deriv_ord,:);
            tc > 0;
        ];

        rbs = horzcat(rbs, rb);

    end
end

function rt = reward_theta(basii_count)
    %rt = [zeros(basii_count-1,1);1];
    rt = 2*rand(basii_count,1) - 1;
    %rt = [-.25*rand(basii_count-1,1);100];
end

function [vb,t] = value_basii_cells(states, VBf)
    t = 0;
    if iscell(states)
        vb = [];
        for i = 1:numel(states)
            [vb(:,i),ti] = VBf(states{i});
            t = t+ti;
        end
    else
        [vb,t] = VBf(states);
    end
end

function [vb,time] = value_basii_2(states)
    %t_start = tic;
    %time = toc(t_start);
    time = 0;

    xs = states(1,:);
    ys = states(2,:);
    ds = abs(states(3:6,:));

    grid     = [3 3];
    screen_w = states(9,1);
    screen_h = states(10,1);    
    cell_w   = screen_w/grid(1);
    cell_h   = screen_h/grid(2);
    b_w      = horzcat((1:grid(1))'-1, (1:grid(1))'-0) * (cell_w+1);
    b_h      = horzcat((1:grid(2))'-1, (1:grid(2))'-0) * (cell_h+1);
    
%     b_w = [
%        0     , 1059.3
%        1059.3, 2118.7
%        2118.7, inf
%     ];
%     
%     b_h = [
%        0     , 512.7
%        512.7 , 1025.3
%        1025.3, inf
%     ];
    
    %deriv_deg = 1:4:12;
    %deriv_ind = 0:size(ds,1)-1;
    %deriv_ord = reshape(deriv_deg' + deriv_ind,1,[]);
    deriv_ord = [1 5 9 2 6 10 3 7 11 4 8 12];
    
    %appr_axs = 1:3:9;
    %appr_ind = 0:2;
    %appr_ord = reshape(appr_axs' + appr_ind,1,[]);
    appr_ord = [1 4 7 2 5 8 3 6 9];
    
    %touch_dir = 1:2:4;
    %touch_ind = 0:1;
    %touch_ord = reshape(touch_dir' + touch_ind,1,[]); 
    touch_ord = [1 3 2 4];
    
    %.6
    tf = target_touch_features(states);
    tm = target_approach_features(states);

    deriv_features = [
        double(0  <= ds & ds < 15 );
        double(15 <= ds & ds < 50 );
        double(50 <= ds & ds < inf);
    ];

    touch_features = [
        tf == 0;
        tf >= 1;
    ];

    approach_features = [
        tm == 0;
        tm >= 1 & tm <= 2;
        tm >= 3;
    ];

    location_features = [
        double(b_w(:,1) <= xs & xs < b_w(:,2));
        double(b_h(:,1) <= ys & ys < b_h(:,2));
    ];

    vb = [
        deriv_features(deriv_ord,:);
        touch_features(touch_ord,:);
        approach_features(appr_ord,:);
        location_features;
    ];

end

function tc = target_touch_features(states)
    r2 = states(11, 1).^2;

    [cd, pd] = target_distance(states);
    
    ct = cd <= r2;
    pt = pd <= r2;

    %not perfect, if a target simply appears on top 
    %of you then it won't count as an actual touch for us
    tc = [
        sum(ct&~pt, 1);
        sum(~ct&pt, 1);
    ];
end

function ta = target_approach_features(states)

    cp = states(1:2, :);
    pp = states(1:2, :) - states(3:4, :);

    %.04
    tp = reshape([states(12:3:end, 1)';states(13:3:end, 1)'], [], 1);
    tn = numel(tp)/2;

    %.1
    curr_targ_xy_dist = abs(tp - repmat(cp, [tn, 1]));
    prev_targ_xy_dist = abs(tp - repmat(pp, [tn, 1]));
    
    %.1
    targs_with_decrease_x = curr_targ_xy_dist(1:2:end,:) < prev_targ_xy_dist(1:2:end,:);
    targs_with_decrease_y = curr_targ_xy_dist(2:2:end,:) < prev_targ_xy_dist(2:2:end,:);
    
    %.04
    targs_with_decrease_x_count  = sum(targs_with_decrease_x,1);
    targs_with_decrease_y_count  = sum(targs_with_decrease_y,1);
    targs_with_decrease_xy_count = sum(targs_with_decrease_x&targs_with_decrease_y,1);

    %.02
    ta = [
        targs_with_decrease_x_count;
        targs_with_decrease_y_count;
        targs_with_decrease_xy_count;
    ];
end

function [cd, pd] = target_distance(states)
    cp = states(1:2,:);
    pp = states(1:2,:) - states(3:4,:);   
    tp = [states(12:3:end, 1)';states(13:3:end, 1)'];
    
    dtp = dot(tp,tp,1)';
    dcp = dot(cp,cp,1);
    dpp = dot(pp,pp,1);
    
    cd = dcp+dtp-2*(tp'*cp);
    pd = dpp+dtp-2*(tp'*pp);
end

function p_results(algo_name, tuning, max_vs, avg_vs, lst_vs, var_vs, f_time, b_time, m_time, a_time)
    fprintf('%s', algo_name);
    fprintf('(G=0.9, L=%03.1f, N=%3i, M=%3i, S=%2i, W=%2i) ',tuning);

    fprintf('AVG_MAX_V = %6.3f; '  , mean(max_vs));
    fprintf('AVG_AVG_V = %6.3f; '  , mean(avg_vs));
    fprintf('AVG_LST_V = %6.3f; '  , mean(lst_vs));
    fprintf('AVG_VAR_V = %6.3f; ' , mean(var_vs));

    fprintf('fT = %5.2f; '        , mean(f_time));
    fprintf('bT = %5.2f; '        , mean(b_time));
    fprintf('mT = %5.2f; '        , mean(m_time));
    fprintf('aT = %5.2f; '        , mean(a_time));
    fprintf('\n');
end

function params = tunings()

    L = 1;
    N = 10:20:50;
    M = 10:20:90;
    S = 3:1:9;
    W = 2:4;

    [cw, cs, cm, cn, cl] = ndgrid(W, S, M, N, L);

    params = [cl(:), cn(:), cm(:), cs(:), cw(:)]';
end
