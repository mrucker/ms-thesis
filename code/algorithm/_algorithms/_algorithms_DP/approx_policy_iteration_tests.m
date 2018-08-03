run '../../paths.m';

samples = 1;

N = 6;
M = 200;
T = 10;

deriv  = 3;
width  = 2;
height = 2;
radius = 0;

gamma = .9;

OPS     = 30;
ticks   = floor(1000/OPS);
arrive  = 200;
survive = 1000;

test_algo_names = {
    'algorithm_2'; %(lin ols   regression)
    'algorithm_5'; %(gau ridge regression)
    'algorithm_6'; %(gau svm   regression)
};

test_algos = {
    @approx_policy_iteration_2;
    @approx_policy_iteration_5;
    @approx_policy_iteration_6;
};

[states, movements, targets, actions, state2index, target2index, pre_pmf, post_pmf, targ_pmf] = small_world(deriv, width, height ,radius, ticks, survive, arrive);

targ_cdf = diag(1./sum(targ_pmf,2)) * targ_pmf * triu(ones(size(targ_pmf,2)));

s_1 = @() states(:,randperm(size(states,2),1));

transition_pre  = @(s,a) small_trans_pre (s, a, targets, target2index, targ_cdf);
transition_post = @(s,a) small_trans_post(s, a);

v_basii = @(s) value_basii_5(s, actions);

Vs = {};

a_time = [];
f_time = [];
b_time = [];
v_time = [];

V_mse = [];
P_mse = [];

rewards  = cell(1, samples);
exact_Vs = cell(1, samples);
exact_Ps = cell(1, samples);

for i = 1:samples    

    reward = random_rewards(states, actions);
    values = exact_value_iteration(pre_pmf, reward, gamma, 0, min(T,30));
    
    rewards{i}  = @(s) reward(state2index(s));
    exact_Vs{i} = post_pmf * values; %(aka, post-decision-state value)
    exact_Ps{i} = exact_policy_realization(states, actions, values, pre_pmf);
    
    %exact_post_V is definitely right. I have double checked it several times.
    %(aka, V_a(s_t) = E[V(s_{t+1}) | a, s_t] = \sum_{s' \in S} P(s'|s,a) * V(s_t+1) == post_pmf * V)
end

for a = 1:size(test_algos,1)

    f_time = zeros(1,samples);
    b_time = zeros(1,samples);
    v_time = zeros(1,samples);
    a_time = zeros(1,samples);
    
    V_mse = zeros(1,samples);
    P_mse = zeros(1,samples);
    
    for i = 1:samples
        
        tic;
            [Vs, Xs, Ys, Ks, f_time(i), b_time(i), v_time(i)] = test_algos{a}(s_1, @(s) actions, rewards{i}, v_basii, transition_post, transition_pre, gamma, N, M, T, 5);
        a_time(i) = toc;

        page_size = 10000;

        V_errors = zeros(size(states,2),1);
        P_errors = zeros(size(states,2),1);

        for page_index = 1:ceil(size(states,2)/page_size)
            page_start    = 1+(page_index-1)*page_size;
            page_stop     = min(page_index*page_size, size(states,2));            
            page_indexes  = page_start:page_stop;
            page_states   = states(:,page_indexes);
            page_states_i = page_indexes;

            V_errors(page_indexes) = Vs{N+1}(page_states) - exact_Vs{i}(page_states_i);
            P_errors(page_indexes) = approx_policy_realization(page_states, actions, Vs{N+1}, transition_post) == exact_Ps{i}(page_states_i);
            %P_errors(page_indexes) = approx_policy_realization(page_states, actions, @(s) exact_Vs{i}(state2index(s)), transition_post) == exact_Ps{i}(page_states_i);
        end

        V_mse(i) = mean(V_errors.^2);
        P_mse(i) = mean(P_errors.^2);
    end
    
    fprintf('\n');
    fprintf('%s --  ', test_algo_names{a});
    fprintf('f_time = % 7.3f; ', sum(f_time));
    fprintf('b_time = % 7.3f; ', sum(b_time));
    fprintf('v_time = % 7.3f; ', sum(v_time));
    fprintf('a_time = % 7.3f; ', sum(a_time));
    fprintf('MSE = % 9.3f; '   , mean(V_mse));
    fprintf('MSP = %.3f; '     , mean(P_mse,1));
end


%    clf
%    hold on;
%        scatter(1:size(states,2), exact_post_V                 , [], 'r', 'o');
%        scatter(1:size(states,2), approx_post_v{plot_i}(states), [], 'b', '.');
%    hold off
%sortrows(vertcat(exact_post_V(30:40)',states(:,30:40))',1)'

fprintf('\n');

function vb = value_basii_1(ss, actions, radius, deriv, small_reward_basii)
    vb = small_reward_basii(ss, actions, radius, deriv);
end

function vb = value_basii_2(ss, actions, radius, deriv, small_reward_basii)
    rb = small_reward_basii(ss, actions, radius, deriv);
    vb = rb([1:4, end], :);
end

function vb = value_basii_3(states, actions, radius)
    
    state_points  = states(1:2,:);
    world_points  = actions;
    state_targets = states((end-size(world_points,2)+1):end,:);

    p1 = state_points;
    p2 = world_points;

    state_point_distance_matrix = sqrt(dot(p1,p1,1) + dot(p2,p2,1)' - 2*(p2' * p1));

    points_within_radius = state_point_distance_matrix <= radius;
    points_with_targets  = logical(state_targets);

    each_states_touch_count  = sum(points_within_radius&points_with_targets);
    each_states_target_count = sum(state_targets);
    
    vb = [each_states_target_count; each_states_touch_count];
end

function vb = value_basii_4(states, actions, radius)

    state_points  = states(1:2,:);
    world_points  = actions;
    state_targets = states((end-size(world_points,2)+1):end,:);

    p1 = state_points;
    p2 = world_points;

    state_point_distance_matrix = sqrt(dot(p1,p1,1) + dot(p2,p2,1)' - 2*(p2' * p1));

    points_within_radius = state_point_distance_matrix <= radius;
    points_with_targets  = logical(state_targets);

    each_states_touch_count  = sum(points_within_radius&points_with_targets);
    each_states_target_count = sum(state_targets);

    curr_points = repmat(states(1:2,:), [size(world_points,2) 1]);
    prev_points = repmat(states(3:4,:), [size(world_points,2) 1]);

    world_points = reshape(world_points, [], 1);
    
    curr_xy_dist = abs(world_points - curr_points);
    prev_xy_dist = abs(world_points - prev_points);

    points_with_decrease_x = curr_xy_dist(1:2:end,:) < prev_xy_dist(1:2:end,:);
    points_with_decrease_y = curr_xy_dist(2:2:end,:) < prev_xy_dist(2:2:end,:);

    %how many targets did my x distance decrease
    target_x_decrease_count = sum(points_with_decrease_x&points_with_targets);
    
    %how many targets did my y distance decrease
    target_y_decrease_count = sum(points_with_decrease_y&points_with_targets);
    
    %how many targets dyd my x,y distance decrease
    target_xy_decrease_count = sum(points_with_decrease_x&points_with_decrease_y&points_with_targets);

    y_intercept = ones(1, size(states,2));
    
    vb = [y_intercept; states(1:2,:); target_x_decrease_count; target_y_decrease_count; target_xy_decrease_count; each_states_target_count; each_states_touch_count];
end

function vb = value_basii_5(states, actions)

    A = [
        1  0 -1  0  0  0;
        0  1  0 -1  0  0;
        1  0 -2  0  1  0;
        0  1  0 -2  0  1;
    ];

    state_points  = states(1:2,:);
    world_points  = actions;
    state_targets = states((end-size(world_points,2)+1):end,:);
    state_radius  = states(end-size(world_points,2),1);
    
    p1 = state_points;
    p2 = world_points;

    state_point_distance_matrix = sqrt(dot(p1,p1,1) + dot(p2,p2,1)' - 2*(p2' * p1));

    not_touched_last_step = ~all(states(1:2,:) == states(3:4,:));
    points_within_radius  = state_point_distance_matrix <= state_radius;
    points_with_targets   = logical(state_targets);

    curr_points = repmat(states(1:2,:), [size(world_points,2) 1]);
    prev_points = repmat(states(3:4,:), [size(world_points,2) 1]);
    
    center_point     = (max(world_points, [], 2) + min(world_points, [], 2))/2;    
    
    world_points = reshape(world_points, [], 1);
    
    curr_xy_dist = abs(world_points - curr_points);
    prev_xy_dist = abs(world_points - prev_points);

    points_with_decrease_x = curr_xy_dist(1:2:end,:) < prev_xy_dist(1:2:end,:);
    points_with_decrease_y = curr_xy_dist(2:2:end,:) < prev_xy_dist(2:2:end,:);

    each_states_target_x_decrease_count  = sum(points_with_decrease_x&points_with_targets);
    each_states_target_y_decrease_count  = sum(points_with_decrease_y&points_with_targets);
    each_states_target_xy_decrease_count = sum(points_with_decrease_x&points_with_decrease_y&points_with_targets&not_touched_last_step);
    each_states_touch_count              = sum(points_within_radius&points_with_targets);
    each_states_target_count             = sum(state_targets);
    each_states_y_intercept              = ones(1, size(states,2));
    each_states_targets                  = state_targets;
    each_states_derivs                   = A * states(1:6,:);
    each_states                          = states;
    each_states_center_vector            = center_point - state_points;
    each_states_movement_towards_targets = [each_states_target_x_decrease_count;each_states_target_y_decrease_count;each_states_target_xy_decrease_count];
    
    vb = [
        each_states_y_intercept; 
        each_states_derivs; 
        each_states_touch_count; 
        each_states_target_count; 
        each_states_movement_towards_targets;     
        each_states_center_vector
    ];
end

function rr = random_rewards(states, actions)

    A = [
        1  0 -1  0  0  0;
        0  1  0 -1  0  0;
        1  0 -2  0  1  0;
        0  1  0 -2  0  1;
    ];

    derivs = A * states(1:6,:);
    
    state_points  = states(1:2,:);
    world_points  = actions;
    state_targets = states((end-size(world_points,2)+1):end,:);
    state_radius  = states(end-size(world_points,2),1);
    
    p1 = state_points;
    p2 = world_points;

    state_point_distance_matrix = sqrt(dot(p1,p1,1) + dot(p2,p2,1)' - 2*(p2' * p1));

    not_touched_last_step = ~all(states(1:2,:) == states(3:4,:));
    points_within_radius  = state_point_distance_matrix <= state_radius;
    points_with_targets   = logical(state_targets);

    each_states_touch_count  = sum(points_within_radius&points_with_targets&not_touched_last_step);    

    deriv_1 = [  1  1 -1 -1] * 10 * (.5-rand);
    deriv_2 = [ -1 -1 -1 -1] * 10 * (.5-rand);
    touched = 1 * 10 * (.5-rand);

    rr = [abs(derivs);abs(derivs).^2;each_states_touch_count]' * [deriv_1,deriv_2,touched]';
end