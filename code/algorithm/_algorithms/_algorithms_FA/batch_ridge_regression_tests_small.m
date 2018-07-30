clear

run '../../paths.m';

deriv  = 4;
width  = 2;
height = 2;
radius = 0;

OPS     = 30;
ticks   = floor(1000/OPS);
arrive  = 200;
survive = 1000;

steps = 20;
gamma = .9;

[states, movements, targets, actions, state2index, target2index, trans_pre_pmf, trans_post_pmf, trans_targ_pmf] = small_world(deriv, width, height ,radius, ticks, survive, arrive);

exact_V = exact_value_iteration(trans_pre_pmf, 100*rand(1,size(states,2))', gamma, .01, steps);
exact_P = exact_policy_realization(states, actions, exact_V, trans_pre_pmf);

train_size = round(size(states,2)*.75);

rand_is  = randperm(size(states,2));
train_is = rand_is(1:train_size);
test_is  = rand_is(train_size+1:end);

xs_train = states (:,train_is)';
ys_train = exact_V(  train_is);

xs_test = states (:,test_is)';
ys_test = exact_V(  test_is);

dk_fun = {};
dk_mse_t = [];

lambdas = .03:.01:.05;
sigmas  = .25:.25:.75;

lambda_n = size(lambdas,2);
sigma_n  = size(sigmas,2);

for lambda_i = 1:lambda_n
    for sigma_i = 1:sigma_n

        lambda = lambdas(lambda_i);
        sigma  = sigmas(sigma_i);

        index = sub2ind([sigma_n lambda_n], sigma_i, lambda_i);
        
        dk_fun{1,index} = batch_ridge_regression(xs_train, ys_train, lambda, k_dot());                       %linear
        dk_fun{2,index} = batch_ridge_regression(xs_train, ys_train, lambda, k_gaussian(k_norm(),sigma));    %gaussian
        dk_fun{3,index} = batch_ridge_regression(xs_train, ys_train, lambda, k_exponential(k_norm(),sigma)); %exponential

        dk_val_1 = dk_fun{1,index}(states');
        dk_val_2 = dk_fun{2,index}(states');
        dk_val_3 = dk_fun{3,index}(states');
        
        dk_pol_1 = exact_policy_realization(states, actions, dk_val_1, trans_pre_pmf);
        dk_pol_2 = exact_policy_realization(states, actions, dk_val_2, trans_pre_pmf);
        dk_pol_3 = exact_policy_realization(states, actions, dk_val_3, trans_pre_pmf);
        
        dk_mse_t(1,index) = mean((ys_test - dk_val_1(test_is)).^2);
        dk_mse_t(2,index) = mean((ys_test - dk_val_2(test_is)).^2);
        dk_mse_t(3,index) = mean((ys_test - dk_val_3(test_is)).^2);
        
        dk_pse_t(1,index) = mean(dk_pol_1(test_is) == exact_P(test_is));
        dk_pse_t(2,index) = mean(dk_pol_2(test_is) == exact_P(test_is));
        dk_pse_t(3,index) = mean(dk_pol_3(test_is) == exact_P(test_is));
        
        dk_pse_f(1,index) = mean(dk_pol_1 == exact_P);
        dk_pse_f(2,index) = mean(dk_pol_2 == exact_P);
        dk_pse_f(3,index) = mean(dk_pol_3 == exact_P);

    end
end

[~,best_mse_t] = min(dk_mse_t, [], 2);
[~,best_pse_t] = max(dk_pse_t, [], 2);
[~,best_pse_f] = max(dk_pse_f, [], 2);

[lambda_b_m_t, sigma_b_m_t] = ind2sub([sigma_n lambda_n], best_mse_t);
[lambda_b_p_t, sigma_b_p_t] = ind2sub([sigma_n lambda_n], best_pse_t);
[lambda_b_p_f, sigma_b_p_f] = ind2sub([sigma_n lambda_n], best_pse_f);

fprintf('\n');
fprintf('lin -- lambda = %05.2f sigma = %05.2f MSE_t = %.2f \n',[lambdas(lambda_b_m_t(1)), sigmas(sigma_b_m_t(1)), dk_mse_t(1,best_mse_t(1))]);
fprintf('gau -- lambda = %05.2f sigma = %05.2f MSE_t = %.2f \n',[lambdas(lambda_b_m_t(2)), sigmas(sigma_b_m_t(2)), dk_mse_t(2,best_mse_t(2))]);
fprintf('exp -- lambda = %05.2f sigma = %05.2f MSE_t = %.2f \n',[lambdas(lambda_b_m_t(3)), sigmas(sigma_b_m_t(3)), dk_mse_t(3,best_mse_t(3))]);
fprintf('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n');
fprintf('lin -- lambda = %05.2f sigma = %05.2f PSE_t = %.2f \n',[lambdas(lambda_b_p_t(1)), sigmas(sigma_b_p_t(1)), dk_pse_t(1,best_pse_t(1))]);
fprintf('gau -- lambda = %05.2f sigma = %05.2f PSE_t = %.2f \n',[lambdas(lambda_b_p_t(2)), sigmas(sigma_b_p_t(2)), dk_pse_t(2,best_pse_t(2))]);
fprintf('exp -- lambda = %05.2f sigma = %05.2f PSE_t = %.2f \n',[lambdas(lambda_b_p_t(3)), sigmas(sigma_b_p_t(3)), dk_pse_t(3,best_pse_t(3))]);
fprintf('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n');
fprintf('lin -- lambda = %05.2f sigma = %05.2f PSE_f = %.2f \n',[lambdas(lambda_b_p_f(1)), sigmas(sigma_b_p_f(1)), dk_pse_t(1,best_pse_f(1))]);
fprintf('gau -- lambda = %05.2f sigma = %05.2f PSE_f = %.2f \n',[lambdas(lambda_b_p_f(2)), sigmas(sigma_b_p_f(2)), dk_pse_t(2,best_pse_f(2))]);
fprintf('exp -- lambda = %05.2f sigma = %05.2f PSE_f = %.2f \n',[lambdas(lambda_b_p_f(3)), sigmas(sigma_b_p_f(3)), dk_pse_t(3,best_pse_f(3))]);

clf
subplot(3,1,1)
drawplot(xs_test,ys_test,dk_fun{1,best_mse_t(1)});

subplot(3,1,2)
drawplot(xs_test,ys_test,dk_fun{2,best_mse_t(2)});

subplot(3,1,3)
drawplot(xs_test,ys_test,dk_fun{3,best_mse_t(3)});

%Drawers
function drawplot(xs, ys, dk)

    xlim([1 size(xs,1)])
    hold on
        scatter(1:size(xs,1),ys    , [], 'r', 'o');
        scatter(1:size(xs,1),dk(xs), [], 'g', '.');
    hold off
end
%Drawers