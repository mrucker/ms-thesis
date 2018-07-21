
deriv  = 3;
width  = 2;
height = 2;
radius = 0;

OPS     = 30;
ticks   = floor(1000/OPS);
arrive  = 200;
survive = 1000;

[states, movements, targets, actions, state2index, target2index, transition_one] = small_world(deriv, width, height ,radius, ticks, survive, arrive);

s_1         = @() states(:,randperm(size(states,2),1));

RB          = small_reward_basii(states, actions, radius);
RW          = [zeros(1,size(RB,1)-1), 1];
reward      = @(s) RB(:,state2index(s))' * RW';

transition_pre  = @(s,a) small_trans_pre (s, a, states, actions, transition_one, state2index);
transition_post = @(s,a) small_trans_post(s, a);

g = .9;
N = 20;
M = 20;
T = 10;

value_basii = @(s) value_basii_3(s, actions, radius, @small_reward_basii);

approx_v_theta = approx_policy_iteration_1(s_1, @(s) actions, reward, value_basii, transition_post, transition_pre, g, N, M, T);

approx_V = value_basii(states)' * approx_v_theta;
exact_V  = exact_value_iteration(transition_one, RB'*RW', g, .01);

approx_P = approx_policy_realization(states, @(s) actions, approx_v_theta, value_basii, transition_post);
exact_P  = exact_policy_realization(states, actions, exact_V, transition_one);

mse_V = mean(power(approx_V - exact_V, 2));
mse_P = mean(approx_P == exact_P);

[mse_V,  mse_P]

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
