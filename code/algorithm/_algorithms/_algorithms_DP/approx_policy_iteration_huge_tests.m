clear
close all
fprintf('\n');
try run('../../paths.m'); catch; end

rewd_count = 20;
eval_steps = 10;

trans_pre = @(s,a) huge_trans_pre (s,a);
trans_pst = @(s,a) huge_trans_post(s,a);

s_1 = @( ) state_rand();
v_b = @(s) value_basii_cells(s, @value_basii_2);
s_a = @(s) actions(s);

%algorithm_2   == (lin ols regression with n-step Monte Carlo                             )
%algorithm_5   == (gau ridge regression                                                   )
%algorithm_8   == (gau svm regression with n-step Monte Carlo, BAKF, and ONPOLICY sampling)
%algorithm_8b  == (algorithm_8 except I've reintroduced an old bug that made it run better)
%algorithm_12  == (algorithm_8 but with bootstrapping after n-step Monte Carlo            )
%algorithm_13  == (algorithm_8 but with interval estimation to choose the first action    )
%algorithm_13b == (algorithm_13 but with a small bug fix around the on-policy distribution)
%algorithm_13c == (algorithm_13b but with a small bug fix in the confidence interval      )
%algorithm_14  == (true TD(lambda) with bootstrap, confidence interval and on-policy dist )

%#1 13b
%#2 13
%#3 14
%#4 08b

algo_a = @(s_r) approx_policy_iteration_2  (s_1, s_a, s_r, v_b, trans_pst, trans_pre, 0.9*1.0, 30, 40, 2, 3);  %  no-opt

algo_b = @(s_r) approx_policy_iteration_8b (s_1, s_a, s_r, v_b, trans_pst, trans_pre, 0.9*1.0, 30, 50, 2, 3);  % WSL-opt
algo_c = @(s_r) approx_policy_iteration_8  (s_1, s_a, s_r, v_b, trans_pst, trans_pre, 0.9*1.0, 30, 40, 2, 3);  % WSL-opt
algo_d = @(s_r) approx_policy_iteration_8  (s_1, s_a, s_r, v_b, trans_pst, trans_pre, 0.9*0.4, 30, 40, 2, 3);  %   L-opt

algo_e = @(s_r) approx_policy_iteration_12 (s_1, s_a, s_r, v_b, trans_pst, trans_pre, 0.9*1.0, 30, 40, 2, 3);  %LWSM-opt

algo_f = @(s_r) approx_policy_iteration_13 (s_1, s_a, s_r, v_b, trans_pst, trans_pre, 0.9*1.0, 30, 40, 2, 3);  %  no-opt
algo_g = @(s_r) approx_policy_iteration_13b(s_1, s_a, s_r, v_b, trans_pst, trans_pre, 0.9*1.0, 30, 50, 5, 3); %  no-opt
algo_h = @(s_r) approx_policy_iteration_13c(s_1, s_a, s_r, v_b, trans_pst, trans_pre, 0.9*1.0, 30, 50, 5, 3); %  no-opt

algo_i = @(s_r) approx_policy_iteration_14 (s_1, s_a, s_r, v_b, trans_pst, trans_pre, 0.9*0.7, 30, 50, 5, 0); %  no-opt
algo_j = @(s_r) approx_policy_iteration_13b(s_1, s_a, s_r, v_b, trans_pst, trans_pre, 0.9*1.0, 30, 50, 5, 3); %  no-opt

algos = {
%   algo_a, 'algorithm_2  (G=0.9, L=1.0, N=30, M=40, S=2, W=3)';
%   algo_b, 'algorithm_8b (G=0.9, L=1.0, N=30, M=50, S=2, W=3)';
%   algo_c, 'algorithm_8  (G=0.9, L=1.0, N=30, M=40, S=2, W=3)';
%   algo_d, 'algorithm_8  (G=0.9, L=0.4, N=30, M=40, S=2, W=3)';
%   algo_e, 'algorithm_12 (G=0.9, L=1.0, N=30, M=40, S=2, W=3)';
%   algo_f, 'algorithm_13 (G=0.9, L=1.0, N=10, M=400, S=2, W=3)';
   algo_g, 'algorithm_13b(G=0.9, L=1.0, N=30, M=50, S=5, W=3)';
   algo_h, 'algorithm_13c(G=0.9, L=1.0, N=30, M=50, S=5, W=3)';
%   algo_i, 'algorithm_14 (G=0.9, L=0.6, N=30, M=50, S=5, W=0)';
%   algo_j, 'algorithm_13b(G=0.9, L=1.0, N=30, M=50, S=5, W=3)';
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

    fT = zeros(1,rewd_count);
    bT = zeros(1,rewd_count);
    vT = zeros(1,rewd_count);
    aT = zeros(1,rewd_count);
    Pv = zeros(1,rewd_count);

    for r_i = 1:rewd_count
        [Pf, Vf, Xs, Ys, Ks, As, fT(r_i), bT(r_i), vT(r_i), aT(r_i)] = algos{a_i,1}(reward_f{r_i});

        %eval_stats = @(s) [reward_f{r_i}(s); target_new_touch_count(s)];
        eval_stats = @(s) reward_f{r_i}(s);

        Pv(r_i) = policy_eval_at_states(Pf{end}, states_c{r_i}, eval_stats, 0.9, eval_steps, trans_pre, 20);
    end

    if rewd_count == 1
        d_results_1(algos{a_i,2}, Ks, As);

        Vs = zeros(1,numel(Pf)-1);

        eval_states = states_c{r_i};
        eval_reward = reward_f{r_i};

        parfor Pf_i = 1:(numel(Pf)-1)
            Vs(Pf_i) = policy_eval_at_states(Pf{Pf_i+1}, eval_states, eval_reward, 0.9, eval_steps, trans_pre, 20);
        end

        d_results_3(algos{a_i,2}, Vs);
    end
    
    p_results(algos{a_i,2}, fT, bT, vT, aT, Pv);
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

function vb = value_basii_cells(states, VBf)
    vb = [];

    if iscell(states)
        for i = 1:numel(states)
            vb(:,i) = VBf(states{i});
        end        
    else
        vb = VBf(states);
    end
end

function vb = value_basii_1(states)

    vb = zeros(14,size(states,2));
    
    vb(1    , :) = 1;
    vb(2:7  , :) = states(3:8,:);
    vb(8    , :) = target_count(states(:,1));
    vb(9    , :) = target_new_touch_count(states);
    vb(10:12, :) = target_relative_movement(states);
    vb(13:14, :) = states(9:10,1)/2 - states(1:2,:);
end

function vb = value_basii_2(states)

    xs = states(1,:);
    ys = states(2,:);
    ds = abs(states(3:8,:));

    screen_w  = states(9,1);
    screen_h = states(10,1);

    grid = [3 3];

    cell_w = screen_w/grid(1);
    cell_h = screen_h/grid(2);

    b_w = horzcat((1:grid(1))'-1, (1:grid(1))'-0) * cell_w;
    b_h = horzcat((1:grid(2))'-1, (1:grid(2))'-0) * cell_h;

    vb = [
        double(0  <= ds & ds < 15 );
        double(15 <= ds & ds < 50 );
        double(50 <= ds & ds < inf);
        target_new_touch_count(states);
        target_relative_movement(states);
        double(b_w(:,1) <= xs & xs < b_w(:,2));
        double(b_h(:,1) <= ys & ys < b_h(:,2));
    ];
end

function rb = reward_basii(states)

    rb = zeros(7,size(states,2));

    for i = 1:size(states,2)
        if iscell(states)
            state = states{i};
        else
            state = states(:,i);
        end

        tc = target_new_touch_count(state);

        %[dx, dy, ddx, ddy, dddx, dddy, touch_count]
        rb(1:6, i) = (abs(state(3:8)) > 50).*abs(state(3:8));
        rb(  7, i) = tc(1,:);
    end
end

function rt = reward_theta(basii_count)
    rt = [zeros(basii_count-1,1);1];
    %rt = 2*rand(basii_count,1) - 1;
    %rt = [-.25*rand(basii_count-1,1);100];
end

function tc = target_new_touch_count(states)
    r2 = states(11, 1).^2;
    cp = states(1:2,:);
    pp = states(1:2,:) - states(3:4,:);

    pt = target_distance([pp;states(3:end,:)]) <= r2;
    ct = target_distance([cp;states(3:end,:)]) <= r2;

    %not perfect, if a target simply appears on top 
    %of you then it won't count as an actual touch for us
    tc = [
        sum(ct&~pt, 1);
        sum(~ct&pt, 1);
    ];
end

function td = target_distance(states)
    cp = states(1:2,:);
    tp = [states(12:3:end, 1)';states(13:3:end, 1)'];
    
    td = dot(cp,cp,1)+dot(tp,tp,1)'-2*(tp'*cp);
end

function tm = target_relative_movement(states)

    cp = states(1:2, :);
    pp = states(1:2, :) - states(3:4, :);

    tp = [states(12:3:end, 1)';states(13:3:end, 1)'];

    curr_targ_xy_dist = abs(reshape(tp, [], 1) - repmat(cp, [size(tp,2), 1]));
    prev_targ_xy_dist = abs(reshape(tp, [], 1) - repmat(pp, [size(tp,2), 1]));

    targs_with_decrease_x = curr_targ_xy_dist(1:2:end,:) < prev_targ_xy_dist(1:2:end,:);
    targs_with_decrease_y = curr_targ_xy_dist(2:2:end,:) < prev_targ_xy_dist(2:2:end,:);

    targs_with_decrease_x_count  = sum(targs_with_decrease_x,1);
    targs_with_decrease_y_count  = sum(targs_with_decrease_y,1);
    targs_with_decrease_xy_count = sum(targs_with_decrease_x&targs_with_decrease_y,1);

    tm = [
        targs_with_decrease_x_count;
        targs_with_decrease_y_count;
        targs_with_decrease_xy_count;
    ];
end

function tc = target_count(state)
    tc = (numel(state) - 11)/3;
end

function p_results(test_algo_name, f_time, b_time, v_time, a_time, P_val)
    fprintf('%s ', test_algo_name);
    fprintf('f_time = % 5.2f; ', mean(f_time));
    fprintf('b_time = % 5.2f; ', mean(b_time));
    fprintf('v_time = % 5.2f; ', mean(v_time));
    fprintf('a_time = % 5.2f; ', mean(a_time));
    fprintf('VAL = % 7.3f; '   , mean(P_val));
    %fprintf('TCH = %f; '       , mean(P_tch));
    fprintf('\n');
end

function d_results_1(test_algo_name, Ks, As)

    flat_ns = cell2mat(arrayfun(@(ni) ni*ones(size(Ks{ni})), 1:numel(Ks), 'UniformOutput', false));
    flat_ks = cell2mat(Ks);
    flat_as = cell2mat(As);
    
    [k_val,~,gk] = unique(flat_ks);
    [n_val,~,gn] = unique(flat_ns);

    %max(K), average(K), var(K), number of (K) each Ks{i}
    nk_avg = grpstats(flat_ks, gn, @mean);
    nk_max = grpstats(flat_ks, gn, @max);
    nk_var = grpstats(flat_ks, gn, @var);
    nk_num = grpstats(flat_ks, gn, @numel);

    %max(A), average(A), var(A), min(A) per unique value of N over all Ns, As
    na_min = grpstats(flat_as, gn, @min);
    na_avg = grpstats(flat_as, gn, @mean);
    na_max = grpstats(flat_as, gn, @max);
    na_var = grpstats(flat_as, gn, @var);

    %max(A), min(A), average(A), Var(A) per unique value of K over all Ks, As
    ka_min = grpstats(flat_as, gk, @min);
    ka_avg = grpstats(flat_as, gk, @mean);
    ka_max = grpstats(flat_as, gk, @max);
    ka_var = grpstats(flat_as, gk, @var);

    figure('NumberTitle', 'off', 'Name', test_algo_name);

    subplot(3,1,1);
    plot(n_val, nk_num, n_val, nk_avg, n_val, nk_max, n_val, nk_var);
    title('visits by iteration')
    xlabel('iteration index')
    legend('k num', 'k avg', 'k max', 'k var')

    subplot(3,1,2);
    plot(n_val, na_min, n_val, na_avg, n_val, na_max, n_val, na_var);
    title('alpha by iteration')
    xlabel('iteration index')
    legend('a min', 'a avg', 'a max', 'a var')

    subplot(3,1,3);
    hold on
    plot(k_val, ka_min, k_val, ka_avg, k_val, ka_max, k_val, ka_var);
    title('alpha by visits')
    xlabel('vb visitation count')
    legend('a min', 'a avg', 'a max', 'a var')
end

function d_results_2(test_algo_name, Ss, Ws, Vs)

    figure('NumberTitle', 'off', 'Name', test_algo_name);

    scatter3(Ss, Ws, Vs, '.', 'b');
    xlabel('S')
    ylabel('W')
    zlabel('V')
end

function d_results_3(test_algo_name, Vs)

    figure('NumberTitle', 'off', 'Name', test_algo_name);

    scatter(1:numel(Vs), Vs, '.');
    title('Convergence of value function');
    xlabel('N')
    ylabel('V')
end

function a = actions(s)
    % The actions matrix should be 2 x |number of actions| where the first row is dx and the second row is dy.
    % This means each column in the matrix represents a dx/dy pair that is the action taken.
    % The small model assumes an action is the location on the grid so be careful when going between the two.

    %all combinations of (dx,dy) for dx,dy \in [-10,10]

    dx = -1:1:1;
    dy = -1:1:1;

    dx = dx*100;
    dy = dy*100;

    dx = [100,50,10,2,0];
    dy = [100,50,10,2,0];

    dx = horzcat(dx,0,-dx);
    dy = horzcat(dy,0,-dy);

    %dx = 1:2;
    %dy = [1,1];

    a = vertcat(reshape(repmat(dx,numel(dx),1), [1,numel(dx)^2]), reshape(repmat(dy',1,numel(dy)), [1,numel(dy)^2]));

    np = s(1:2) + a;

    np_too_small_x = np(1,:) < 0;
    np_too_small_y = np(2,:) < 0;
    np_too_large_x = np(1,:) > s(9);
    np_too_large_y = np(2,:) > s(10);

    valid_actions = ~(np_too_small_x|np_too_small_y|np_too_large_x|np_too_large_y);

    a = a(:, valid_actions);
end
