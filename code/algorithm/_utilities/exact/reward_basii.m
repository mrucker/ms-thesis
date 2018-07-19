function basii = reward_basii(states, actions, radius)

    point_count = size(actions,2);

    A = [
        1  0  0  0  0  0 zeros(1,3 + point_count);
        0  1  0  0  0  0 zeros(1,3 + point_count);
        1  0 -1  0  0  0 zeros(1,3 + point_count);
        0  1  0 -1  0  0 zeros(1,3 + point_count);
        1  0 -2  0  1  0 zeros(1,3 + point_count);
        0  1  0 -2  0  1 zeros(1,3 + point_count);
    ];
    df = A * states;


    XY = [
        1  0  0  0  0  0 zeros(1,3 + point_count);
        0  1  0  0  0  0 zeros(1,3 + point_count);
    ];

    state_points = XY * states;
    world_points = actions; 
    
    p1 = state_points;
    p2 = world_points;
    
    state_point_distance_matrix = sqrt(dot(p1,p1,1) + dot(p2,p2,1)' - 2*(p2' * p1));
    
    tf = sum(and( state_point_distance_matrix <= radius, logical(states(10:end,:))));

    basii = vertcat(df,tf);
end