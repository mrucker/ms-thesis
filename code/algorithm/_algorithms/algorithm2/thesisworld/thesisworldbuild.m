function [mdp_data,r,feature_data,true_feature_map] = thesisworldbuild(mdp_params)

target_locations = [100 200; 50 50]';
target_radius    = 10;

width   = 3000;
height  = 3000;

num_x   = 10;
num_y   = 10;

actions = createActionsMatrix();
states  = createFeatureMatrix(width, height, num_x, num_y, target_locations, target_radius);

% Fill in default parameters.
mdp_params = thesisworlddefaultparams(mdp_params);

% Set random seed.
rand('seed',mdp_params.seed);



% Build action mapping.
state_count  = size(states,2);
action_count = size(actions,2);
state_area   = 4;

sa_s = zeros(state_count,action_count,state_area);
sa_p = thesisworldtransitions();

% Create MDP data structure.
mdp_data = struct(...
    'states',state_count,...
    'actions',action_count,...
    'discount',mdp_params.discount,...
    'determinism',1,...
    'sa_s',sa_s,...
    'sa_p',sa_p);

r = rand(state_count,1);

feature_data     = struct('stateadjacency',[],'splittable',[]);
true_feature_map = states;

end

function a = createActionsMatrix()
    % The actions matrix should be 2 x |number of actions| where the first row is dx and the second row is dy.
    % This means each column in the matrix represents a dx/dy pair that is the action taken.

    dx = -100:1:100;
    dy = -100:1:100;

    a = vertcat(reshape(repmat(dx,numel(dy),1), [1,numel(dx)*numel(dy)]), reshape(repmat(dy',1,numel(dx)), [1,numel(dy)*numel(dx)]));
end

function f = createFeatureMatrix(width, height, num_x, num_y, target_locations, target_radius)
    x_step = round(width/num_x);
    y_step = round(height/num_y);

    xs = x_step * (1:num_x - 1/2);
    ys = y_step * (1:num_y - 1/2);
    
    f = vertcat(reshape(repmat(xs,numel(ys),1), [1,numel(xs)*numel(ys)]), reshape(repmat(ys',1,numel(xs)), [1,numel(ys)*numel(xs)]));
    
    x1 = f;
    x2 = target_locations;
    
    target_distances = sqrt(dot(x2,x2,1)+dot(x1,x1,1)'-2*(x1'*x2));
    
    f = vertcat(f, double(any(target_distances <= target_radius)));
end

function g = createGridWorld(width, height, target_locations, target_radius)
    xs = 1:width;
    ys = 1:height;    
    
    g = vertcat(reshape(repmat(xs,numel(ys),1), [1,numel(xs)*numel(ys)]), reshape(repmat(ys',1,numel(xs)), [1,numel(ys)*numel(xs)]));
    
    x1 = g;
    x2 = target_locations;
    
    target_distances = sqrt(dot(x2,x2,1)+dot(x1,x1,1)'-2*(x1'*x2));
    
    g = vertcat(g, double(any(target_distances <= target_radius)));
end
