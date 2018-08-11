function vb = v_basii_3_2(states)
    vb = v_basii_cells(states, @v_basii_features);
end

function vb = v_basii_features(states)
    xs = states(1,:);
    ys = states(2,:);
    ds = abs(states(3:8,:));
    
    screen_w  = states(9,1);
    screen_h = states(10,1);
    
    grid = [3 3];
    
    cell_w = screen_w/grid(1);
    cell_h = screen_h/grid(2);
    
    b_w = horzcat((1:grid(1))'-1, (1:grid(1))'-0) * cell_w;
    b_h = horzcat((1:grid(2))'-1, (1:grid(2))'-0) * cell_h;
    
    vb = [
        double(0  <= ds & ds < 15 );
        double(15 <= ds & ds < 50 );
        double(50 <= ds & ds < inf);
        target_new_touch_count(states);
        target_relative_movement(states);
        double(b_w(:,1) <= xs & xs < b_w(:,2));
        double(b_h(:,1) <= ys & ys < b_h(:,2));
    ];
end

function vb = v_basii_cells(states, VBf)
    vb = [];
    
    if iscell(states)
        for i = numel(states)
            vb(:,i) = VBf(states{i});
        end
        
    else
        vb = VBf(states);
    end
end

function tc = target_new_touch_count(states)
    r2 = states(11, 1).^2;
    cp = states(1:2,:);
    pp = states(1:2,:) - states(3:4,:);

    pt = target_distance([pp;states(3:end,:)]) <= r2;
    ct = target_distance([cp;states(3:end,:)]) <= r2;

    %not perfect, if a target simply appears on top 
    %of you then it won't count as an actual touch for us
    tc = [        
        sum(~ct&pt, 1);
        sum(ct&~pt, 1);
    ];
end

function td = target_distance(states)
    cp = states(1:2,:);
    tp = [states(12:3:end, 1)';states(13:3:end, 1)'];
    
    td = dot(cp,cp,1)+dot(tp,tp,1)'-2*(tp'*cp);
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