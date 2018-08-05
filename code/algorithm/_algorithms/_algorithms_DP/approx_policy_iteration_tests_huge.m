close all
fprintf('\n');
run('../../paths.m');

samples = 1;
gamma = .9;

N = 30;
M = 200;
T = 5;
W = 3;

algos = {
    @approx_policy_iteration_2, 'algorithm_2'; %(lin ols   regression)
    %@approx_policy_iteration_5, 'algorithm_5'; %(gau ridge regression)
    @approx_policy_iteration_6, 'algorithm_6'; %(gau svm   regression)
    @approx_policy_iteration_7, 'algorithm_7'; %(gau svm   regression with BAKF)
};

s_1 = @() state_rand();

states_r = cell(1, samples);
reward_r = cell(1, samples);

for i = 1:samples
    reward_basii_n = size(reward_basii(s_1()),1);
    reward_theta_r = reward_theta_rand(reward_basii_n);
    
    reward_r{i} = @(s) reward_theta_r'*reward_basii(s);
    states_r{i} = {s_1(),s_1(),s_1(),s_1(),s_1(),s_1(),s_1(),s_1(),s_1(),s_1()};
end

s_a = @(s) actions();
s_r = @(i) reward_r{i}; 
v_b = @(s) value_basii_5(s);

trans_pre = @(s,a) huge_trans_pre (s,a);
trans_pst = @(s,a) huge_trans_post(s,a);

for a = 1:size(algos,1)
    
    Ts = zeros(4,samples);    
    Pv = zeros(1,samples);
    
    for i = 1:samples

        [Vf, Xs, Ys, Ks, Ts(1,i), Ts(2,i), Ts(3,i), Ts(4,i)] = algos{a,1}(s_1, s_a, s_r(i), v_b, trans_pst, trans_pre, gamma, N, M, T, W);

        ia = @(a,i) a(:,i);
        Pf = @(s) ia(s_a(a), max_i(Vf{N+1}(trans_pst(s, s_a(s)))));
        
        Pv(i) = evaluate_policy_at_states(Pf, states_r{i}, reward_r{i}, gamma, T, trans_pre, 10);

        if samples < 3
            %d_results(test_algo_names{a}, Xs, Ys, Ks, v_basii(states), exact_Es{i}, exact_Vs{i});
        end
    end

    p_results(algos{a,2}, Ts(1,i), Ts(2,i), Ts(3,i), Ts(4,i), Pv);

end

function s = state_rand()
    population = {
       [1145;673;-8;-2;-1;6;-7;4;3175;1535;156];
       [1158;673;15;0;10;0;5;0;3175;1535;156;626;555;155;2249;305;60];
       [2358;345;203;-153;-79;-68;87;5;3175;1535;156;626;555;953;2249;305;857;1895;1165;536;2847;278;369;2941;1297;225;2701;465;80]
   };

    s = population{randi(numel(population))};
end

function vb = value_basii_5(states)

    vb = zeros(14,size(states,2));

    if iscell(states)
        for i = numel(states)
            state = states{i};
            
            vb(1    , i) = 1;
            vb(2:7  , i) = state(3:8);
            vb(8    , i) = target_count(state);
            vb(9    , i) = touch_count(state);
            vb(10:12, i) = target_movement(state);
            vb(13:14, i) = state(9:10)/2 - state(1:2);
        end
        
    else
        vb(1    , :) = 1;
        vb(2:7  , :) = states(3:8,:);
        vb(8    , :) = target_count(states(:,1));
        vb(9    , :) = touch_count(states);
        vb(10:12, :) = target_movement(states);
        vb(13:14, :) = states(9:10,1)/2 - states(1:2,:);
    end
end

function rb = reward_basii(states)
    
    rb = zeros(7,size(states,2));

    for i = 1:size(states,2)
        if iscell(states)
            state = states{i};
        else
            state = states(:,i);
        end
        %[dx, dy, ddx, ddy, dddx, dddy, touch_count]
        rb(1:6, i) = state(3:8);
        rb(  7, i) = touch_count(state);
    end    
end

function tc = touch_count(states)
    r2 = states(11, 1).^2;
    cp = states(1:2,:);
    pp = states(1:2,:) - states(3:4,:);
    
    tp = [states(12:3:end, 1)';states(13:3:end, 1)'];

    pt = (dot(pp,pp,1)+dot(tp,tp,1)'-2*(tp'*pp)) <= r2;
    ct = (dot(cp,cp,1)+dot(tp,tp,1)'-2*(tp'*cp)) <= r2;
    
    %not perfect, if a target simply appears on top 
    %of you then it won't count as an actual touch for us
    tc = sum(ct&~pt, 1);
end

function tm = target_movement(states)
    
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
    rt = rand(basii_count,1);
end

function p_results(test_algo_name, f_time, b_time, v_time, a_time, P_val)
    fprintf('%s -- ', test_algo_name);
    fprintf('f_time = % 7.3f; ', sum(f_time));
    fprintf('b_time = % 7.3f; ', sum(b_time));
    fprintf('v_time = % 7.3f; ', sum(v_time));
    fprintf('a_time = % 7.3f; ', sum(a_time));
    fprintf('VAL = %.3f; '     , mean(P_val));
    fprintf('\n');
end

function d_results(test_algo_name, As, Ks)
    
    figure('NumberTitle', 'off', 'Name', test_algo_name);

    subplot(2,1,1);    
    %scatter3(step_visit_count(1,:),step_visit_count(2,:),step_visit_count(3,:), '.');
    title('visitation bins')
    
    subplot(2,1,2);
    %scatter3(step_visit_error(1,:),step_visit_error(2,:),step_visit_error(3,:), '.');
    title('convergence rate')
end

function V = evaluate_policy_at_states(Pf, eval_states, reward, gamma, T, transition_pre, sample_size)
    V = 0;
    
    for i = 1:size(eval_states,2)
        eval_state = eval_states{i};
        V = V + evaluate_policy_at_state(Pf, eval_state, reward, gamma, T, transition_pre, sample_size);
    end
    
    V = V/size(eval_states,2);
end

function V = evaluate_policy_at_state(Pf, state, reward, gamma, T, transition_pre, sample_size)

    V = 0;    
    
    for n = 1:sample_size

        s = state;
        v = 0;
        
        for t = 1:T
            v = v + gamma^(t-1) * reward(s);
            a = Pf(s);
            s = transition_pre(s,a);
        end
        
        V = V + v;
    end
    
    V = V/sample_size;
end

function i = max_i(M)
 [~, i] = max(M);
end

function a = actions()
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
end
