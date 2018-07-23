run '../../paths.m';

deriv  = 3;
width  = 2;
height = 2;
radius = 0;

OPS     = 30;
ticks   = floor(1000/OPS);
arrive  = 200;
survive = 1000;

[states, movements, targets, actions, state2index, target2index, trans_pmf, target_pmf] = small_world(deriv, width, height ,radius, ticks, survive, arrive);

target_cdf = diag(1./sum(target_pmf,2)) * target_pmf * triu(ones(size(target_pmf,2)));

%this seems to be slightly faster but for now I'm not going to do it
%perhaps I can put this logic into small_world?
%save('transition_one', 'transition_one', '-v7.3');
%load('transition_one');

s_1 = @() states(:,randperm(size(states,2),1));

RB = small_reward_basii(states, actions, radius);

transition_pre  = @(s,a) small_trans_pre (s, a, targets, target2index, target_cdf);
transition_post = @(s,a) small_trans_post(s, a);

g = .9;
N = 20;
M = 40;
T = 10;

value_basii = @(s) value_basii_3(s, actions, radius, @small_reward_basii);

mse_V1 = [];
mse_V2 = [];
mse_P1 = [];
mse_P2 = [];

exact_V = exact_value_iteration(trans_pmf, RB'*RW', g, .01);
exact_P = exact_policy_realization(states, actions, exact_V, trans_pmf);

for i = 1:1
    RW     = random_rw(RB);
    reward = @(s) RB(:,state2index(s))' * RW';
    
    tic;
        [approx_v_theta1, f_time1(i), b_time1(i), v_time1(i)] = approx_policy_iteration_1(s_1, @(s) actions, reward, value_basii, transition_post, transition_pre, g, N, M, T);
    p_time1(i) = toc;
    
    tic;
        [approx_v_theta2, f_time2(i), b_time2(i), v_time2(i)] = approx_policy_iteration_2(s_1, @(s) actions, reward, value_basii, transition_post, transition_pre, g, N, M, T);
    p_time2(i) = toc;

    mse_V1(i) = mean(power(value_basii(states)' * approx_v_theta1 - exact_V, 2));
    mse_V2(i) = mean(power(value_basii(states)' * approx_v_theta2 - exact_V, 2));

    mse_P1(i) = mean(approx_policy_realization(states, actions, approx_v_theta1, value_basii, transition_post) == exact_P);
    mse_P2(i) = mean(approx_policy_realization(states, actions, approx_v_theta2, value_basii, transition_post) == exact_P);
end

[
    mean(f_time1), mean(b_time1), mean(v_time1), mean(p_time1);
    mean(f_time2), mean(b_time2), mean(v_time2), mean(p_time2)
]

[
    mean(mse_V1), mean(mse_P1);
    mean(mse_V2), mean(mse_P2);
]

function vb = value_basii_1(ss, actions, radius, small_reward_basii)
    vb = small_reward_basii(ss, actions, radius);
end

function vb = value_basii_2(ss, actions, radius, small_reward_basii)
    rb = small_reward_basii(ss, actions, radius);
    vb = rb([1:4, end], :);
end

function vb = value_basii_3(ss, actions, radius, small_reward_basii)
    rb = small_reward_basii(ss, actions, radius);
    
    state_count = size(ss,2);
    
    vb = [ones(1,state_count); sum(ss(end-3:end, :)); rb(end,:)];
end

function rw = random_rw(RB)
    max_RW = .1;
    num_RW = size(RB,1)-1;
    rng_RW = max_RW *(1-2*rand(1,num_RW));
    
    rw = [rng_RW, 1];
end