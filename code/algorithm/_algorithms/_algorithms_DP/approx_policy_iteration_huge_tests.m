clear
close all
fprintf('\n');
try run('../../paths.m'); catch; end

rewd_count = 30;
eval_steps = 10;

trans_pre = @(s,a) huge_trans_pre (s,a);
trans_pst = @(s,a) huge_trans_post(s,a);

[state2rew_ident, r_p, r_b] = r_basii_4_2();

s_1 = @( ) state_rand();
s_a = s_act_4_1();
v_b = @v_basii_4_4;

%algorithm_2   == (lin ols regression with n-step Monte Carlo                             )
%algorithm_5   == (gau ridge regression                                                   )
%algorithm_8   == (gau svm regression with n-step Monte Carlo, BAKF, and ONPOLICY sampling)
%algorithm_8b  == (algorithm_8 except I've reintroduced an old bug that made it run better)
%algorithm_12  == (algorithm_8 but with bootstrapping after n-step Monte Carlo            )
%algorithm_13  == (algorithm_8 but with interval estimation to choose the first action    )
%algorithm_13b == (algorithm_13 but with a small bug fix around the on-policy distribution)
%algorithm_13c == (algorithm_13b but with a small bug fix in the confidence interval      )
%algorithm_13d == (algorithm_13b but with a small change to cache values in iterations    )
%algorithm_13e == (algorithm_13b but with a change to calculate all values once each N    )
%algorithm_13f == (algorithm_13e but adding in policy_iter data to the kernel value basii )
%algorithm_13g == (algorithm_13f but more intelligent explore/exploit logic               )
%algorithm_14  == (true TD(lambda) with bootstrap, confidence interval and on-policy dist )

%13e is always faster than 13d no matter what I do to the algorithm paramaters

%#1 13b
%#2 13
%#3 14
%#4 08b

algo_a = @(s_r) approx_policy_iteration_2  (s_1, s_a, s_r, v_b, trans_pst, trans_pre, 0.9*1.0, 30, 50, 2, 3);  %  no-opt

algo_j = @(s_r) approx_policy_iteration_13b(s_1, s_a, s_r, v_b, trans_pst, trans_pre, 0.9*1.0, 30, 50, 5, 3); %  no-opt

algo_l = @(s_r) approx_policy_iteration_13e(s_1, s_a, s_r, v_b, trans_pst, trans_pre, 0.9*1.0, 30, 50, 5, 3); %  no-opt
algo_m = @(s_r) approx_policy_iteration_13e(s_1, s_a, s_r, v_b, trans_pst, trans_pre, 0.9*1.0, 10, 50, 7, 3); %  no-opt

algo_n = @(s_r) approx_policy_iteration_13f(s_1, s_a, s_r, v_b, trans_pst, trans_pre, 0.9*1.0, 30, 50, 5, 3); %  no-opt
algo_o = @(s_r) approx_policy_iteration_13f(s_1, s_a, s_r, v_b, trans_pst, trans_pre, 0.9*1.0, 5, 400, 5, 4); %  no-opt

algo_p = @(s_r) approx_policy_iteration_13g(s_1, s_a, s_r, v_b, trans_pst, trans_pre, 0.9*1.0, 30, 50, 5, 3); %  no-opt
algo_q = @(s_r) approx_policy_iteration_13h(s_1, s_a, s_r, @v_basii_4_3, trans_pst, trans_pre, 0.9*1.0, 30, 70, 3, 3); %  no-opt
algo_r = @(s_r) approx_policy_iteration_13h(s_1, s_a, s_r, @v_basii_4_4, trans_pst, trans_pre, 0.9*1.0, 30, 70, 3, 3); %  no-opt

algos = {
%   algo_a, 'algorithm_2  (G=0.9, L=1.0, N=30, M=50 , S=2, W=3)';
%   algo_j, 'algorithm_13b(G=0.9, L=1.0, N=30, M=50 , S=5, W=3)';
%   algo_l, 'algorithm_13e(G=0.9, L=1.0, N=30, M=50 , S=5, W=3)';
%   algo_m, 'algorithm_13e(G=0.9, L=1.0, N=10, M=50 , S=7, W=3)';
%   algo_n, 'algorithm_13f(G=0.9, L=1.0, N=30, M=50 , S=5, W=3)';
%   algo_o, 'algorithm_13f(G=0.9, L=1.0, N=10, M=200, S=7, W=3)';
%   algo_p, 'algorithm_13g(G=0.9, L=1.0, N=30, M=50 , S=5, W=3)';
   algo_q, 'algorithm_13h(G=0.9, L=1.0, N=30, M=70 , S=3, W=3)';
   algo_r, 'algorithm_13h(G=0.9, L=1.0, N=30, M=70 , S=3, W=3)';
};

states_c = cell(1, rewd_count);
reward_f = cell(1, rewd_count);

for r_i = 1:rewd_count
    reward_basii_n = size(r_b(s_1()),1);
    reward_theta_r = reward_theta(reward_basii_n);

    reward_f{r_i} = @(s) reward_theta_r'*r_b(s);
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

        eval_states = states_c{r_i};
        eval_reward = reward_f{r_i};

        Pv(r_i) = policy_eval_at_states(Pf{end}, eval_states, eval_reward, 0.9, eval_steps, trans_pre, 400);
    end

    if rewd_count == 1
        %d_results_1(algos{a_i,2}, Ks, As);

        Vs = zeros(1,numel(Pf)-1);

        eval_states = states_c{r_i};
        eval_reward = reward_f{r_i};

        parfor Pf_i = 2:numel(Pf)
            Vs(Pf_i-1) = policy_eval_at_states(Pf{Pf_i}, eval_states, eval_reward, 0.9, eval_steps, trans_pre, 100);
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

function rt = reward_theta(basii_count)
    %rt = [zeros(basii_count-1,1);1];
    rt = 2*rand(basii_count,1) - 1;
    %rt = [-.25*rand(basii_count-1,1);100];
end

function p_results(test_algo_name, f_time, b_time, v_time, a_time, P_val)
    fprintf('%s ', test_algo_name);
    fprintf('f_time = %5.2f; ', mean(f_time));
    fprintf('b_time = %5.2f; ', mean(b_time));
    fprintf('v_time = %5.2f; ', mean(v_time));
    fprintf('a_time = %5.2f; ', mean(a_time));
    fprintf('VAL = %7.3f; '   , mean(P_val));
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