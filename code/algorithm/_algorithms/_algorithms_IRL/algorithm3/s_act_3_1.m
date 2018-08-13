function a = s_act_3_1(states)

    huge_states_assert(states);

    % The actions matrix should be 2 x |number of actions| where the first row is dx and the second row is dy.
    % This means each column in the matrix represents a dx/dy pair that is the action taken. 
    % The small model assumes an action is the location on the grid so be careful when going between the two.

    %all combinations of (dx,dy) for dx,dy \in [-10,10]

    dx = -1:1:1;
    dy = -1:1:1;

    dx = dx*100;
    dy = dy*100;
    
    dx = [100,50,10,2,0];
    dy = [100,50,10,2,0];
    
    dx = horzcat(dx,0,-dx);
    dy = horzcat(dy,0,-dy);
        
    %dx = 1:2;
    %dy = [1,1];
    
    a = vertcat(reshape(repmat(dx,numel(dx),1), [1,numel(dx)^2]), reshape(repmat(dy',1,numel(dy)), [1,numel(dy)^2]));
    
    np = states(1:2) + a;
        
    np_too_small_x = np(1,:) < 0;
    np_too_small_y = np(2,:) < 0;
    np_too_large_x = np(1,:) > states(9);
    np_too_large_y = np(2,:) > states(10);
    
    valid_actions = ~(np_too_small_x|np_too_small_y|np_too_large_x|np_too_large_y);
    
    a = a(:, valid_actions);

end
