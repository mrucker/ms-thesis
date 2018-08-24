function [state2identity, r_p, r_b, m_p, t_p] = r_basii_4_3()

    m_p = all_move_perms();
    t_p = all_targ_perms();

    [t_c, m_c] = ndgrid(1:size(t_p,2),1:size(m_p,2));

    r_p = vertcat(m_p(:,m_c(:)), t_p(:,t_c(:)));
    
    a_n = size(r_p,2);
    a_T = basii2indexes_T([3 3 3 3],[4 8 4]);
    
    %we add the "1+" in order to include the 0 target permutation at the start
    state2identity = @(states) double(1:a_n == (1+a_T*r_basii_cells(states))' )';
    
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
    ds = abs(states(3:6,:));
    
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

    deriv_features = [
        double(0  <= ds & ds < 15 );
        double(15 <= ds & ds < 50 );
        double(50 <= ds & ds < inf);
    ];

    deriv_deg = 1:4:12;
    deriv_ind = 0:size(ds,1)-1;
    deriv_ord = reshape(deriv_deg' + deriv_ind,1,[]);

    rb = [
        deriv_features(deriv_ord,:);
        target_features;
    ];
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
    tv2 = floor((tv2 + 3*pi/8 ) ./ (2*pi/8));
    tv2 = tv2 + ((tv2<=0) * 9);

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

function m_features = all_move_perms()

    d1x_f = eye(3);
    d1y_f = eye(3);
    d2x_f = eye(3);
    d2y_f = eye(3);

    d1x_i = 1:size(d1x_f,2);
    d1y_i = 1:size(d1y_f,2);
    d2x_i = 1:size(d2x_f,2);
    d2y_i = 1:size(d2y_f,2);

    [d2y_c, d2x_c, d1y_c, d1x_c] = ndgrid(d2y_i, d2x_i, d1y_i, d1x_i);

    m_features = vertcat(d1x_f(:,d1x_c(:)), d1y_f(:,d1y_c(:)), d2x_f(:,d2x_c(:)), d2y_f(:,d2y_c(:)));

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

function T = basii2indexes_T(move_shape, targ_shape)

    move_shape = [move_shape, 1]; %add one for easier computing
    targ_shape = [targ_shape, 1]; %add one for easier computing
    
    move_2_index_T = cell2mat(arrayfun(@(i) prod(move_shape((i+1):end)) .* ((1:move_shape(i))-1), 1:(numel(move_shape)-1), 'uniformoutput',false));
    targ_2_index_T = cell2mat(arrayfun(@(i) prod(targ_shape((i+1):end)) .* ((1:targ_shape(i))-1), 1:(numel(targ_shape)-1), 'uniformoutput',false));
    
    %move_2_index_T(end-move_shape(end-1)+1:end) = move_2_index_T(end-move_shape(end-1)+1:end) + 1;
    targ_2_index_T(end-targ_shape(end-1)+1:end) = targ_2_index_T(end-targ_shape(end-1)+1:end) + 1;
    
    T = [move_2_index_T * (prod(targ_shape)+1), targ_2_index_T];
end