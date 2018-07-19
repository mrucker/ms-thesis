[states, movements, targets, actions, state2index, target2index] = small_world(3,3,0);

P = one_step(movements, targets, actions, state2index, 33, 1000, 200);

%abc
y = 1;