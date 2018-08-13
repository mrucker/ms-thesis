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
%algorithm_14  == (full tabular TD lambda with interval estimation and on-policy sampling )

algos = {
    
    @approx_policy_iteration_13b, 'algorithm_13b';
    @approx_policy_iteration_14 , 'algorithm_14 ';
    @approx_policy_iteration_8b , 'algorithm_8b ';
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

            for Pf_i = 1:(numel(Pf)-1)
                vs(Pf_i) = policy_eval_at_states(Pf{Pf_i+1}, eval_states, eval_reward, 0.9, eval_steps, trans_pre, 20);
            end

            max_vs(r_i) = max(vs);
            avg_vs(r_i) = mean(vs(6:end));
            lst_vs(r_i) = vs(end);
            var_vs(r_i) = var(vs(6:end));
        end

        p_results(algos{a_i,2}, tuning, max_vs, avg_vs, lst_vs, var_vs, fT, bT, mT, aT);
    end
    
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

function rt = reward_theta(basii_count)
    rt = 2*rand(basii_count,1) - 1;
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

function p_results(algo_name, tuning, max_vs, avg_vs, lst_vs, var_vs, f_time, b_time, v_time, a_time)
    fprintf('%s', algo_name);
    fprintf('(G=0.9, L=%03.1f, N=%3i, M=%3i, S=%2i, W=%2i) ',tuning);

    fprintf('AVG_MAX_V = %8.3f; '  , mean(max_vs));
    fprintf('AVG_AVG_V = %8.3f; '  , mean(avg_vs));
    fprintf('AVG_LST_V = %8.3f; '  , mean(lst_vs));
    fprintf('AVG_VAR_V = %10.3f; ' , mean(var_vs));
    
    fprintf('fT = %5.2f; '        , mean(f_time));
    fprintf('bT = %5.2f; '        , mean(b_time));
    fprintf('vT = %5.2f; '        , mean(v_time));
    fprintf('aT = %5.2f; '        , mean(a_time));
    fprintf('\n');
end

function params = tunings()

    L = .1:.3:1;
    N = 10:20:100;
    M = 10:40:210;
    S = 2:10;
    W = 3:5;

    [cw, cs, cm, cn, cl] = ndgrid(W, S, M, N, L);

    params = [cl(:), cn(:), cm(:), cs(:), cw(:)]';
end
