[states, state2index] = all_states(2,3,0);

%if 2,2 use these actions
%[[1;1] [1;2] [2;1] [2;2]]

%if 2,3 use these actions
%[[1;1] [1;2] [1;3] [2;1] [2;2] [2;3]]

%if 3,3 use these actions
%[[1;1] [1;2] [1;3] [2;1] [2;2] [2;3] [3;1] [3;2] [3;3]]

tic
P = one_step(states, state2index, [[1;1] [1;2] [1;3] [2;1] [2;2] [2;3]], 1000, 200);
toc
%abc
y = 1;