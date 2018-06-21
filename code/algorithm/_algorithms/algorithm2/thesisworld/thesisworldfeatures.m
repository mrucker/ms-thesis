% Construct the raw features for the gridworld domain.
function [feature_data,true_feature_map] = peterworldfeatures(mdp_params,mdp_data)

% mdp_params - definition of MDP domain
% mdp_data - generic definition of domain
% feature_data - generic feature data:
%   splittable - matrix of states to features
%   stateadjacency - sparse state adjacency matrix

% Fill in default parameters.
mdp_params = peterworlddefaultparams(mdp_params);

% Construct adjacency table.
stateadjacency = sparse([],[],[], mdp_data.states, mdp_data.states, mdp_data.states*mdp_data.actions);

for s=1:mdp_data.states
    for a=1:mdp_data.actions
        stateadjacency(s,mdp_data.sa_s(s,a,1)) = 1;
    end;
end;

% Construct true feature map. All states belonging to the same macro cell have a shared feature.
true_feature_map = [0 0 0 0;
                    0 0 1 0;
                    0 0 2 0;
                    0 1 0 0;
                    0 1 1 0;
                    0 1 1 1;
                    0 2 0 0;
                    1 0 1 0;
                    1 0 2 0;
                    1 1 1 0;
                    1 1 1 1;
                    2 0 2 0];
                
feature_data = struct('stateadjacency',stateadjacency,'splittable',true_feature_map);