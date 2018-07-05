function x2 = adp_transition_post_decision(x1, u)

    %assumes that 33 ms will pass in transition (aka, 30 observations per second)
    %assumed state = [x, y, dx, dy, ddx, ddy, dddx, dddy, w, h, r, \forall targets {x, y, age}]
    
    isRightDataTypes = isnumeric(x1) && isrow(x1);
    isRightDimension = numel(x1) == 11 || (numel(x1) > 11 && mod(numel(x1)-8, 3) == 0);
    
    assert(isRightDataTypes, 'each state must be a numeric row vector');
    assert(isRightDimension, 'each state must have 8 cursor features + [1 radius feature + 3x target features]');

    x2 = x1;
    
    x2 = update_cursor_state(x2,u);
    x2 = update_existing_targets(x2);
end

function x2 = update_cursor_state(x1,u)

    B = [ 
        1 0 1 0 1 0 1 0;
        0 1 0 1 0 1 0 1;
    ];

    A = -[
        0 0 1 0 1 0 1 0;
        0 0 0 1 0 1 0 1;
        0 0 0 0 1 0 1 0;
        0 0 0 0 0 1 0 1;
        0 0 0 0 0 0 1 0;
        0 0 0 0 0 0 0 1;
        0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0;
    ];
    
    x2      = x1;
    x2(1:8) = x(1:8) * A + u * B;    
end

function x2 = update_existing_targets(x1)

    non_target_fields = 11;
    
    if(numel(x1) == non_target_fields)
        x2 = x1;
        return;
    end
        
    x2 = x1(:,1:11);
    
    target_count = (numel(x2)-non_target_fields)/3;
    target_ages  = x1(non_target_fields+(1:target_count)*3) + 33;
    
    for i = 1:target_count
        if(target_ages(i) < 1000)
            x = x1(non_target_fields+1+(i-1)*3);
            y = x1(non_target_fields+2+(i-1)*3);
            a = target_ages(i);
            x2 = [x2, x, y, a];
        end
    end
    
end

function x2 = create_new_targets(x1)
    x2 = x1;
end