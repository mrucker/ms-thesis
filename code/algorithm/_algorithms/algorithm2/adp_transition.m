function x2 = adp_transition(x1, u, create)

    %assumed state = [x, y, dx, dy, ddx,ddy, dddx,dddy, r, \forall targets {x, y, age}]
    
    isRightDataTypes = isnumeric(x1) && isrow(x1);
    isRightDimension = numel(x1) == 8 || (numel(x1) > 8 && mod(numel(x1), 3) == 0);
    
    assert(isRightDataTypes, 'each state must be a numeric row vector');
    assert(isRightDimension, 'each state must have 8 cursor features + [1 radius feature + 3x target features]');

    x2 = x1;
    
    x2 = update_cursor_state(x2,u);
    x2 = update_existing_targets(x2);
    
    if(create)
        x2 = create_new_targets(x2);
    end
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

    if(numel(x1) < 9)
        x2 = x1;
        return;
    end
    
    x2 = x1(1:8);
    
    target_count = (numel(x2)-9)/3;    
    target_ages  = x1(9+(1:target_count)*3) + 33;
    
    for i = 1:target_count        
        if(target_ages(i) < 1000)
            x2 = horzcat(x2, x1( (10+(i-1)*3):(11+(i-1)*3) ), target_ages(i));
        end
    end
    
end

function x2 = create_new_targets(x1)
    x2 = x1;
end