function [state2identity, r_p, r_b] = r_basii_4_4()

    r_p = all_targ_perms();
    
    a_n = size(r_p,2);
    a_T = basii2indexes_T([4 8 4],[4 8 4]);
    
    %we add the "+1" in order to include the 0 target permutation at the start
    state2identity = @(states) double(1:a_n == (a_T*r_basii_cells(states) + 1)' )';
    
    r_b = @r_basii_cells;
end

function rb = r_basii_cells(states)
    if iscell(states)
        rb = cell2mat(cellfun(@r_basii_feats, states, 'UniformOutput',false)');
    else
        rb = r_basii_feats(states);
    end
end

function rb = r_basii_feats(states)

    sc = size(states,2);

    %.5
    tou = target_touch_features(states);

    if any(sum(tou,1)>1)
        %.1
        [tv,ti] = max(tou,[],1);
        tou(:) = 0;
        tou(sub2ind(size(tou), ti, 1:sc))  = tv;
    end

    if any(sum(tou,1) == 0)
        target_features = zeros(16,1);
    else
        %loc = target_location(states);

        %.25
        cnt = sum(target_center_features(states)    .* tou,1);

        %.25
        dir = sum(target_direction_features(states) .* tou,1);

        %.15
        age = sum(target_age_features(states)       .* tou,1);

        target_features = double(vertcat((1:4)' == cnt, (1:8)' == dir, (1:4)' == age));
    end

    rb = target_features;
end

function tt = target_touch_features(states)
    r2 = states(11, 1).^2;

    [cd, pd] = target_distance_features(states);

    ct = cd <= r2;
    pt = pd <= r2;
    nt = states(14:3:end, 1) <= 30; %in theory this could be 33 (aka, one observation 30 times a second)

    tt = ct&(~pt|nt);
end

function [cd, pd] = target_distance_features(states)
    cp = states(1:2,:);
    pp = states(1:2,:) - states(3:4,:);   
    tp = [states(12:3:end, 1)';states(13:3:end, 1)'];
    
    dtp = dot(tp,tp,1);
    dcp = dot(cp,cp,1);
    dpp = dot(pp,pp,1);
    
    cd = dcp+dtp'-2*(tp'*cp);
    pd = dpp+dtp'-2*(tp'*pp);
end

function td = target_direction_features(states)

    % +1 ... 1
    % +2 ... 2
    % +3 ... 3
    % +4 ... 4
    % +5 ... 5
    % -4 ... 5
    % -3 ... 6
    % -2 ... 7
    % -1 ... 8

    %   cx1, cx2, c3 ...
    %tx1
    %tx2
    %tx3
    %...

    cx = states(1,:); %row
    cy = states(2,:); %row

    tx = states(12:3:end, 1); %col
    ty = states(13:3:end, 1); %col

    tx_with_cx_as_origin = tx-cx;
    ty_with_cy_as_origin = ty-cy;

    %when there are two maxes, it returns the first index. This might introduce
    %bias when learning rewards, but I don't think it is enough to matter.
    tv2 = atan2(ty_with_cy_as_origin, tx_with_cx_as_origin);    
    tv2 = floor((tv2 + 3*pi/8) ./ (2*pi/8));
    tv2 = tv2 + ((tv2<=0) * 8);

    td = tv2;
end

function ta = target_age_features(states)

    ages = [
        0  , 250, 1;
        250, 500, 2;
        500, 750, 3;
        750, inf, 4;
    ];

    tv     = states(14:3:end, 1)';
    [~,ti] = max(ages(:,1) <= tv & tv <= ages(:,2), [], 1);
    ta     = repmat(ti', 1, size(states,2));
end

function tc = target_center_features(states)

    centers = [
        0   , 400 , 1;
        400 , 900 , 2;
        900 , 1500, 3;
        1500, inf , 4;
    ];

    sc = states(9:10,1)/2;    
    tp = [states(12:3:end, 1)';states(13:3:end, 1)'];

    tv     = vecnorm(tp-sc);
    [~,ti] = max(centers(:,1) <= tv & tv <= centers(:,2), [], 1);
    tc     = repmat(ti', 1, size(states,2));
end

function t_features = all_targ_perms()

    %lox_f = eye(3);
    %loy_f = eye(3);

    cnt_f = eye(4);
    dir_f = eye(8);
    age_f = eye(4);

    %lox_i = 1:size(lox_f,2);
    %loy_i = 1:size(loy_f,2);

    cnt_i = 1:size(cnt_f,2);
    dir_i = 1:size(dir_f,2);
    age_i = 1:size(age_f,2);

    [age_c, dir_c, cnt_c] = ndgrid(age_i, dir_i, cnt_i);

    t_features = vertcat(cnt_f(:,cnt_c(:)), dir_f(:,dir_c(:)), age_f(:,age_c(:)));
    z_features = zeros(size(t_features,1),1);

    t_features = horzcat(z_features,t_features);

end

function T = basii2indexes_T(vals, vars)

    vals = [vals, 1]; %add one for easier computing
    
    targ_2_index_T = cell2mat(arrayfun(@(i) prod(vals((i+1):end)) .* fliplr((vals(i)-1) - (0:vars(i)-1)), 1:(numel(vals)-1), 'UniformOutput',false));

    targ_2_index_T(end-vals(end-1)+1:end) = targ_2_index_T(end-vals(end-1)+1:end) + 1;
        
    T = targ_2_index_T;
end