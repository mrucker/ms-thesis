close all
fprintf('\n');
run('../../paths.m');

samples = 5;
gamma = .9;

% N = 30;
% M = 80;
% T = 20;
% S = 5;
% W = 5;

N = 10;
M = 80;
T = 20;
S = 5;
W = 5;

algos = {
    @approx_policy_iteration_2 , 'algorithm_2 '; %(lin ols   regression)
    %@approx_policy_iteration_5, 'algorithm_5 '; %(gau ridge regression)
    %@approx_policy_iteration_6, 'algorithm_6 '; %(gau svm   regression)
    %@approx_policy_iteration_7 , 'algorithm_7 '; %(gau svm   regression with BAKF)
    @approx_policy_iteration_8 , 'algorithm_8 '; %(gau svm   regression with BAKF with ONPOLICY sampling)
    %@approx_policy_iteration_9 , 'algorithm_9 '; %(gau svm   regression with BAKF with interval estimation)
    %@approx_policy_iteration_10, 'algorithm_10'; %(gau svm   regression with BAKF with ONPOLICY sampling and interval estimation)
};

s_1 = @( ) state_rand();
v_b = @(s) value_basii_cells(s, @value_basii_2);

states_r = cell(1, samples);
reward_r = cell(1, samples);

for i = 1:samples
    reward_basii_n = size(reward_basii(s_1()),1);
    reward_theta_r = reward_theta_rand(reward_basii_n);
    
    reward_r{i} = @(s) reward_theta_r'*reward_basii(s);
    states_r{i} = {s_1(),s_1(),s_1(),s_1(),s_1(),s_1(),s_1(),s_1(),s_1(),s_1()};
end

s_a = @(s) actions(s);
s_r = @(i) reward_r{i}; 

trans_pre = @(s,a) huge_trans_pre (s,a);
trans_pst = @(s,a) huge_trans_post(s,a);

for a = 1:size(algos,1)
    
    Ts = zeros(4,samples);    
    Pv = zeros(1,samples);
    Pt = zeros(2,samples);
    
    for i = 1:samples

        [Pf, Vf, Xs, Ys, Ks, As, Ts(1,i), Ts(2,i), Ts(3,i), Ts(4,i)] = algos{a,1}(s_1, s_a, s_r(i), v_b, trans_pst, trans_pre, gamma, N, M, S, W);

        Pv(:,i) = policy_eval_at_states(Pf{N+1}, states_r{i}, reward_r{i}            , gamma, T, trans_pre, 10);
        Pt(:,i) = policy_eval_at_states(Pf{N+1}, states_r{i}, @target_new_touch_count, 1    , T, trans_pre, 10);
        Pb      = policy_eval_at_states(Pf{N+1}, states_r{i}, @reward_basii          , 1    , T, trans_pre, 20);
        %Pd(i)  = policy_eval_at_states(Pf{N+1}, states_r{i}, @target_dist           , 1    , T, trans_pre, 20);        

        if samples < 3
            d_results(algos{a,2}, Ks, As);
        end
    end

    p_results(algos{a,2}, Ts(1,:), Ts(2,:), Ts(3,:), Ts(4,:), Pv, Pt(1,:));
end

function s = state_rand()
    population = {
       [1145;673;-8;-2;-1;6;-7;4;3175;1535;156];
       [1158;673;15;0;10;0;5;0;3175;1535;156;626;555;155;2249;305;60];
       [2358;345;203;-153;-79;-68;87;5;3175;1535;156;626;555;953;2249;305;857;1895;1165;536;2847;278;369;2941;1297;225;2701;465;80]
   };

    s = population{randi(numel(population))};
end

function vb = value_basii_cells(states, VBf)
    vb = [];
    
    if iscell(states)
        for i = numel(states)
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

function rt = reward_theta_rand(basii_count)
    rt = [zeros(basii_count-1,1);1];
    %rt = 2*rand(basii_count,1) - 1;
    %rt = [-.25*rand(basii_count-1,1);100];
end

function p_results(test_algo_name, f_time, b_time, v_time, a_time, P_val, P_tch)
    fprintf('%s -- ', test_algo_name);
    fprintf('f_time = % 7.2f; ', sum(f_time));
    fprintf('b_time = % 7.2f; ', sum(b_time));
    fprintf('v_time = % 7.2f; ', sum(v_time));
    fprintf('a_time = % 7.2f; ', sum(a_time));
    fprintf('VAL = %.3f; '     , mean(P_val));
    fprintf('TCH = %f; '       , mean(P_tch));
    fprintf('\n');
end

function d_results(test_algo_name, Ks, As)

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
