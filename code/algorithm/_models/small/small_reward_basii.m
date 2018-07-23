function basii = small_reward_basii(states, actions, radius)

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

    tf = sum(and(state_point_distance_matrix <= radius, logical(states(10:end,:))));

    basii = [
%        df(1,:) == +3;
        df(1,:) == +2;
        df(1,:) == +1;
%        df(2,:) == +3;
        df(2,:) == +2;
        df(2,:) == +1;
        df(3,:) == +2;
        df(3,:) == +1;
        df(3,:) == +0;
        df(3,:) == -1;
        df(3,:) == -2;
        df(4,:) == +2;
        df(4,:) == +1;
        df(4,:) == +0;
        df(4,:) == -1;
        df(4,:) == -2;
        df(5,:) == +4;
        df(5,:) == +3;
        df(5,:) == +2;
        df(5,:) == +1;
        df(5,:) == +0;
        df(5,:) == -1;
        df(5,:) == -2;
        df(5,:) == -3;
        df(5,:) == -4;
        df(6,:) == +4;
        df(6,:) == +3;
        df(6,:) == +2;
        df(6,:) == +1;
        df(6,:) == +0;
        df(6,:) == -1;
        df(6,:) == -2;
        df(6,:) == -3;
        df(6,:) == -4;
        tf;
    ];
end