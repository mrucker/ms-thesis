%same as 1 but I average over my identical training features. This reduces
%my training set size by around 10% or so without appearing to lose accuracy.
run '../../paths.m';
clear

deriv  = 3;
width  = 3;
height = 3;
radius = 0;

OPS     = 30;
ticks   = floor(1000/OPS);
arrive  = 200;
survive = 1000;

steps = 30;
gamma = .9;
trn_p = .05;

[states, movements, targets, actions, state2index, target2index, trans_pre_pmf, trans_post_pmf, trans_targ_pmf] = small_world(deriv, width, height ,radius, ticks, survive, arrive);

exact_V = exact_value_iteration(trans_pre_pmf, random_rewards(states, actions), gamma, .01, steps);
exact_P = exact_policy_realization(states, actions, exact_V, trans_pre_pmf);

trn_size = min(2000,round(trn_p*size(states,2)));
tst_size = size(states,2) - trn_size;

rng_indexes = randperm(size(states,2));
trn_indexes = rng_indexes(1:trn_size);
tst_indexes = rng_indexes(trn_size+1:end);

v_basii = value_basii_4(states,actions);

xs_train = v_basii(:,trn_indexes)';
ys_train = exact_V(  trn_indexes);

xs_test = v_basii(:,tst_indexes)';
ys_test = exact_V(  tst_indexes);

[~,i,g]=unique(xs_train, 'rows');

xs_train = xs_train(i,:);
ys_train = grpstats(ys_train,g);

dk_mse_t = [];
dk_pse_t = [];
dk_pse_f = [];

lambdas = .005:.005:.020;
sigmas  = 1.00:0.50:3.00;

lambdas = .01;
sigmas  = 2;

lambda_n = size(lambdas,2);
sigma_n  = size(sigmas,2);

for lambda_i = 1:lambda_n
    for sigma_i = 1:sigma_n

        lambda = lambdas(lambda_i);
        sigma  = sigmas(sigma_i);

        index = sub2ind([sigma_n lambda_n], sigma_i, lambda_i);

        dk_fun_1 = batch_ridge_regression(xs_train, ys_train, lambda, k_dot());                       %linear
        dk_fun_2 = batch_ridge_regression(xs_train, ys_train, lambda, k_gaussian(k_norm(),sigma));    %gaussian
        dk_fun_3 = batch_ridge_regression(xs_train, ys_train, lambda, k_exponential(k_norm(),sigma)); %exponential

        dk_val_1 = zeros(size(v_basii,2),1);
        dk_val_2 = zeros(size(v_basii,2),1);
        dk_val_3 = zeros(size(v_basii,2),1);
        
        chunk_size = 10000;
        
        for chunk_page = 1:ceil(size(v_basii,2)/chunk_size)

            chunk_start = 1+(chunk_page-1)*chunk_size;
            chunk_stop  = chunk_page*chunk_size;
            chunk_indexes = chunk_start:min(chunk_stop,size(v_basii,2));
            
            dk_val_1(chunk_indexes) = dk_fun_1(v_basii(:,chunk_indexes)');
            dk_val_2(chunk_indexes) = dk_fun_2(v_basii(:,chunk_indexes)');
            dk_val_3(chunk_indexes) = dk_fun_3(v_basii(:,chunk_indexes)');
        end

        dk_pol_1 = exact_policy_realization(v_basii, actions, dk_val_1, trans_pre_pmf);
        dk_pol_2 = exact_policy_realization(v_basii, actions, dk_val_2, trans_pre_pmf);
        dk_pol_3 = exact_policy_realization(v_basii, actions, dk_val_3, trans_pre_pmf);

        dk_mse_t(1,index) = mean((ys_test - dk_val_1(tst_indexes)).^2);
        dk_mse_t(2,index) = mean((ys_test - dk_val_2(tst_indexes)).^2);
        dk_mse_t(3,index) = mean((ys_test - dk_val_3(tst_indexes)).^2);

        dk_pse_t(1,index) = mean(dk_pol_1(tst_indexes) == exact_P(tst_indexes));
        dk_pse_t(2,index) = mean(dk_pol_2(tst_indexes) == exact_P(tst_indexes));
        dk_pse_t(3,index) = mean(dk_pol_3(tst_indexes) == exact_P(tst_indexes));

        dk_pse_f(1,index) = mean(dk_pol_1 == exact_P);
        dk_pse_f(2,index) = mean(dk_pol_2 == exact_P);
        dk_pse_f(3,index) = mean(dk_pol_3 == exact_P);
    end
end

[~,best_mse_t] = min(dk_mse_t, [], 2);
[~,best_pse_t] = max(dk_pse_t, [], 2);
[~,best_pse_f] = max(dk_pse_f, [], 2);

[sigma_b_m_t, lambda_b_m_t] = ind2sub([sigma_n lambda_n], best_mse_t);
[sigma_b_p_t, lambda_b_p_t] = ind2sub([sigma_n lambda_n], best_pse_t);
[sigma_b_p_f, lambda_b_p_f] = ind2sub([sigma_n lambda_n], best_pse_f);

fprintf('\n');
fprintf('states = %i; train = %i; test = %i', size(states,2), trn_size, tst_size);

fprintf('\n');
fprintf('lin')
fprintf('    -- lambda = %05.2f sigma = %05.2f MSE_t = %05.2f',[lambdas(lambda_b_m_t(1)), sigmas(sigma_b_m_t(1)), dk_mse_t(1,best_mse_t(1))]);
fprintf('    -- lambda = %05.2f sigma = %05.2f PSE_t = %.2f'  ,[lambdas(lambda_b_p_t(1)), sigmas(sigma_b_p_t(1)), dk_pse_t(1,best_pse_t(1))]);
fprintf('    -- lambda = %05.2f sigma = %05.2f PSE_f = %.2f'  ,[lambdas(lambda_b_p_f(1)), sigmas(sigma_b_p_f(1)), dk_pse_f(1,best_pse_f(1))]);
fprintf('\n');

fprintf('gau')
fprintf('    -- lambda = %05.2f sigma = %05.2f MSE_t = %05.2f',[lambdas(lambda_b_m_t(2)), sigmas(sigma_b_m_t(2)), dk_mse_t(2,best_mse_t(2))]);
fprintf('    -- lambda = %05.2f sigma = %05.2f PSE_t = %.2f'  ,[lambdas(lambda_b_p_t(2)), sigmas(sigma_b_p_t(2)), dk_pse_t(2,best_pse_t(2))]);
fprintf('    -- lambda = %05.2f sigma = %05.2f PSE_f = %.2f'  ,[lambdas(lambda_b_p_f(2)), sigmas(sigma_b_p_f(2)), dk_pse_f(2,best_pse_f(2))]);
fprintf('\n');

fprintf('exp')
fprintf('    -- lambda = %05.2f sigma = %05.2f MSE_t = %05.2f',[lambdas(lambda_b_m_t(3)), sigmas(sigma_b_m_t(3)), dk_mse_t(3,best_mse_t(3))]);
fprintf('    -- lambda = %05.2f sigma = %05.2f PSE_t = %.2f'  ,[lambdas(lambda_b_p_t(3)), sigmas(sigma_b_p_t(3)), dk_pse_t(3,best_pse_t(3))]);
fprintf('    -- lambda = %05.2f sigma = %05.2f PSE_f = %.2f'  ,[lambdas(lambda_b_p_f(3)), sigmas(sigma_b_p_f(3)), dk_pse_f(3,best_pse_f(3))]);
fprintf('\n');

if numel(tst_indexes) < 15000
     clf
     subplot(3,1,1)
     drawplot(xs_test,ys_test,dk_val_1(tst_indexes));
    % 
     subplot(3,1,2)
     drawplot(xs_test,ys_test,dk_val_2(tst_indexes));
    % 
     subplot(3,1,3)
     drawplot(xs_test,ys_test,dk_val_3(tst_indexes));
end

%Drawers
function drawplot(xs, y1, y2)

    xlim([1 size(xs,1)])
    hold on
        scatter(1:size(xs,1),y1, [], 'r', 'o');
        scatter(1:size(xs,1),y2, [], 'g', '.');
    hold off
end
%Drawers

function rr = random_rewards(states, actions)
    
    A = [
        1  0  0  0  0  0;
        0  1  0  0  0  0;
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

    points_within_radius = state_point_distance_matrix <= state_radius;
    points_with_targets  = logical(state_targets);

    each_states_touch_count  = sum(points_within_radius&points_with_targets);
    
    deriv_1 = [ 0  0  1  1 -1 -1];
    deriv_2 = [ 0  0 -1 -1 -1 -1];
    touched = 1;
    
    rr = [abs(derivs);abs(derivs).^2;each_states_touch_count]' * [deriv_1,deriv_2,touched]';
end

function vb = value_basii_4(states, actions)

    state_points  = states(1:2,:);
    world_points  = actions;
    state_targets = states((end-size(world_points,2)+1):end,:);
    state_radius  = states(end-size(world_points,2),1);
    
    p1 = state_points;
    p2 = world_points;

    state_point_distance_matrix = sqrt(dot(p1,p1,1) + dot(p2,p2,1)' - 2*(p2' * p1));

    points_within_radius = state_point_distance_matrix <= state_radius;
    points_with_targets  = logical(state_targets);

    curr_points = repmat(states(1:2,:), [size(world_points,2) 1]);
    prev_points = repmat(states(3:4,:), [size(world_points,2) 1]);

    world_points = reshape(world_points, [], 1);
    
    curr_xy_dist = abs(world_points - curr_points);
    prev_xy_dist = abs(world_points - prev_points);

    points_with_decrease_x = curr_xy_dist(1:2:end,:) < prev_xy_dist(1:2:end,:);
    points_with_decrease_y = curr_xy_dist(2:2:end,:) < prev_xy_dist(2:2:end,:);

    A = [
        1  0  0  0  0  0;
        0  1  0  0  0  0;
        1  0 -1  0  0  0;
        0  1  0 -1  0  0;
        1  0 -2  0  1  0;
        0  1  0 -2  0  1;
    ];

    each_states_target_x_decrease_count  = sum(points_with_decrease_x&points_with_targets);
    each_states_target_y_decrease_count  = sum(points_with_decrease_y&points_with_targets);    
    each_states_target_xy_decrease_count = sum(points_with_decrease_x&points_with_decrease_y&points_with_targets);
    each_states_touch_count              = sum(points_within_radius&points_with_targets);
    each_states_target_count             = sum(state_targets);    
    each_states_y_intercept              = ones(1, size(states,2));
    each_states_targets                  = state_targets;
    each_states_derivs                   = A * states(1:6,:);
    each_states                          = states;

    vb = [each_states_y_intercept; each_states_derivs; each_states_touch_count; each_states_target_count];
end