run('../../paths.m');

width  = 2;
height = 2;
radius = 0;

OPS     = 30;
ticks   = floor(1000/OPS);
arrive  = 200;
survive = 1000;

[states, movements, targets, actions, state2index, target2index] = small_world(width,height,radius);

T  = small_trans_matrix(movements, targets, actions, state2index, ticks, survive, arrive);
RB = small_reward_basii(states, actions, radius);
rw = [zeros(1,34), 1];
R  = (rw * RB)';

[V,P] = value_iteration(T, R, .9, .01);

a = 1;