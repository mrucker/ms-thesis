width  = 2;
height = 3;
radius = 0;

[states, movements, targets, actions, state2index, target2index] = small_world(width,height,radius);

T  = one_step(movements, targets, actions, state2index, 33, 1000, 200);
RB = reward_basii(states, actions, radius);
rw = [0 0 0 0 0 0 1];
R  = (rw * RB)';

[V,P] = value_iteration(T, R, .9, .01);

a = 1;