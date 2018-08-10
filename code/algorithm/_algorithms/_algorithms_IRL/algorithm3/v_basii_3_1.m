function vb = v_basii_3_1(states)

    huge_states_assert(states);

    vb = zeros(14,size(states,2));

    if iscell(states)
        for i = 1:numel(states)
            state = states{i};

            vb(1    , i) = 1;
            vb(2:7  , i) = state(3:8);
            vb(8    , i) = target_count(state);
            vb(9    , i) = touch_count(state);
            vb(10:12, i) = target_relative_movement(state);
            vb(13:14, i) = state(9:10)/2 - state(1:2);
        end

    else
        vb(1    , :) = 1;
        vb(2:7  , :) = states(3:8,:);
        vb(8    , :) = target_count(states(:,1));
        vb(9    , :) = touch_count(states);
        vb(10:12, :) = target_relative_movement(states);
        vb(13:14, :) = states(9:10,1)/2 - states(1:2,:);
    end    
end

function tc = target_count(state)
    tc = (numel(state) - 11)/3;
end

function tc = touch_count(states)
    r2 = states(11, 1).^2;
    cp = states(1:2,:);
    pp = states(1:2,:) - states(3:4,:);

    tp = [states(12:3:end, 1)';states(13:3:end, 1)'];

    pt = (dot(pp,pp,1)+dot(tp,tp,1)'-2*(tp'*pp)) <= r2;
    ct = (dot(cp,cp,1)+dot(tp,tp,1)'-2*(tp'*cp)) <= r2;

    %not perfect, if a target simply appears on top 
    %of you then it won't count as an actual touch for us
    tc = sum(ct&~pt, 1);
end

function tm = target_relative_movement(states)

    cp = states(1:2, :);
    pp = states(1:2, :) - states(3:4, :);

    tp = [states(12:3:end, 1)';states(13:3:end, 1)'];

    curr_targ_xy_dist = abs(reshape(tp, [], 1) - repmat(cp, [size(tp,2), 1]));
    prev_targ_xy_dist = abs(reshape(tp, [], 1) - repmat(pp, [size(tp,2), 1]));

    targs_with_decrease_x = curr_targ_xy_dist(1:2:end,:) < prev_targ_xy_dist(1:2:end,:);
    targs_with_decrease_y = curr_targ_xy_dist(2:2:end,:) < prev_targ_xy_dist(2:2:end,:);

    targs_with_decrease_x_count  = sum(targs_with_decrease_x,1);
    targs_with_decrease_y_count  = sum(targs_with_decrease_y,1);
    targs_with_decrease_xy_count = sum(targs_with_decrease_x&targs_with_decrease_y,1);

    tm = [
        targs_with_decrease_x_count;
        targs_with_decrease_y_count;
        targs_with_decrease_xy_count;
    ];
end

