function x2 = adp_transition_post_decision(x1, u)

    adp_assert_states(x1);

    x2 = x1;
    
    x2 = update_cursor_state(x2,u);
    x2 = update_target_states(x2);
end

function x2 = update_cursor_state(x1,u)

    u(1,(u(1,:) + x1(1)) > x1(9)) = - x1(1) + x1(9);
    u(1,(u(1,:) + x1(1)) < 0    ) = - x1(1);
    
    u(2,(u(2,:) + x1(2)) > x1(10)) = - x1(2) + x1(10);
    u(2,(u(2,:) + x1(2)) < 0     ) = - x1(2);
    
    B = [
        1 0;
        0 1;
        1 0;
        0 1;
        1 0;
        0 1;
        1 0;
        0 1;
    ];

    A = -[
        0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0;
        1 0 0 0 0 0 0 0;
        0 1 0 0 0 0 0 0;
        1 0 1 0 0 0 0 0;
        0 1 0 1 0 0 0 0;
        1 0 1 0 1 0 0 0;
        0 1 0 1 0 1 0 0;        
    ];
    
    x2 = A * x1(1:8) + B * (x1(1:2)+u);
    x2 = vertcat(x2, repmat(x1(9:end), [1 size(x2,2)]));
end

function x2 = update_target_states(x1)

    non_target_count = 11;
    all_target_count = 3;
    
    if(size(x1,1) == non_target_count)
        x2 = x1;
        return;
    end
        
    x2 = x1(1:11,:);
    
    target_count = (size(x1,1)-non_target_count)/all_target_count;
    
    %assumes that 33 ms will pass in transition (aka, 30 observations per second)
    target_ages  = x1(non_target_count+(1:target_count)*all_target_count) + 33;
    
    for i = 1:target_count
        if(target_ages(i) < 1000)
            x = x1(non_target_count+1+(i-1)*all_target_count);
            y = x1(non_target_count+2+(i-1)*all_target_count);
            a = target_ages(i);
            x2 = vertcat(x2, repmat([x; y; a], [1 size(x2,2)]));
        end
    end
    
end