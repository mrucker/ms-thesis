function [basii2index, v_p, v_b] = v_basii_4_3()
    d_p = all_deriv_perms();
    t_p = all_touch_perms();
    a_p = all_approach_perms();
    l_p = all_location_perms();
    
    [l_p_c, a_p_c, t_p_c, d_p_c] = ndgrid(1:size(l_p,2), 1:size(a_p,2), 1:size(t_p,2), 1:size(d_p,2));

    v_p = vertcat(d_p(:,d_p_c(:)), t_p(:,t_p_c(:)), a_p(:,a_p_c(:)), l_p(:,l_p_c(:)));
    
    a_T = basii2indexes_T([3 3 3 3 2 2 3 3 3 3 3]);
    
    basii2index = @(basii) a_T*basii;
    
    v_b = @v_basii_cells;
end

function [vb] = v_basii_cells(states)
    if iscell(states)
        vb = cell2mat(cellfun(@v_basii_feats, states, 'UniformOutput',false)');
    else
        [vb] = v_basii_feats(states);
    end
end

function [vb] = v_basii_feats(states)
    xs = states(1,:);
    ys = states(2,:);
    ds = abs(states(3:6,:));

    grid     = [3 3];
    screen_w = states(9,1);
    screen_h = states(10,1);    
    cell_w   = screen_w/grid(1);
    cell_h   = screen_h/grid(2);
    b_w      = horzcat((1:grid(1))'-1, (1:grid(1))'-0) * (cell_w+1);
    b_h      = horzcat((1:grid(2))'-1, (1:grid(2))'-0) * (cell_h+1);
    
%     b_w = [
%        0     , 1059.3
%        1059.3, 2118.7
%        2118.7, inf
%     ];
%     
%     b_h = [
%        0     , 512.7
%        512.7 , 1025.3
%        1025.3, inf
%     ];
    
    %deriv_deg = 1:4:12;
    %deriv_ind = 0:size(ds,1)-1;
    %deriv_ord = reshape(deriv_deg' + deriv_ind,1,[]);
    deriv_ord = [1 5 9 2 6 10 3 7 11 4 8 12];
    
    %appr_axs = 1:3:9;
    %appr_ind = 0:2;
    %appr_ord = reshape(appr_axs' + appr_ind,1,[]);
    appr_ord = [1 4 7 2 5 8 3 6 9];
    
    %touch_dir = 1:2:4;
    %touch_ind = 0:1;
    %touch_ord = reshape(touch_dir' + touch_ind,1,[]); 
    touch_ord = [1 3 2 4];
    
    %.6
    tf = target_touch_features(states);
    tm = target_approach_features(states);

    deriv_features = [
        double(0  <= ds & ds < 15 );
        double(15 <= ds & ds < 50 );
        double(50 <= ds & ds < inf);
    ];

    touch_features = [
        tf == 0;
        tf >= 1;
    ];

    approach_features = [
        tm == 0;
        tm >= 1 & tm <= 2;
        tm >= 3;
    ];

    location_features = [
        double(b_w(:,1) <= xs & xs < b_w(:,2));
        double(b_h(:,1) <= ys & ys < b_h(:,2));
    ];

    vb = [
        deriv_features(deriv_ord,:);
        touch_features(touch_ord,:);
        approach_features(appr_ord,:);
        location_features;
    ];

end

function tc = target_touch_features(states)
    r2 = states(11, 1).^2;

    [cd, pd] = target_distance_features(states);
    
    ct = cd <= r2;
    pt = pd <= r2;

    %not perfect, if a target simply appears on top 
    %of you then it won't count as an actual touch for us
    tc = [
        sum(ct&~pt, 1);
        sum(~ct&pt, 1);
    ];
end

function ta = target_approach_features(states)

    cp = states(1:2, :);
    pp = states(1:2, :) - states(3:4, :);

    %.04
    tp = reshape([states(12:3:end, 1)';states(13:3:end, 1)'], [], 1);
    tn = numel(tp)/2;

    %.1
    curr_targ_xy_dist = abs(tp - repmat(cp, [tn, 1]));
    prev_targ_xy_dist = abs(tp - repmat(pp, [tn, 1]));
    
    %.1
    targs_with_decrease_x = curr_targ_xy_dist(1:2:end,:) < prev_targ_xy_dist(1:2:end,:);
    targs_with_decrease_y = curr_targ_xy_dist(2:2:end,:) < prev_targ_xy_dist(2:2:end,:);
    
    %.04
    targs_with_decrease_x_count  = sum(targs_with_decrease_x,1);
    targs_with_decrease_y_count  = sum(targs_with_decrease_y,1);
    targs_with_decrease_xy_count = sum(targs_with_decrease_x&targs_with_decrease_y,1);

    %.02
    ta = [
        targs_with_decrease_x_count;
        targs_with_decrease_y_count;
        targs_with_decrease_xy_count;
    ];
end

function [cd, pd] = target_distance_features(states)
    cp = states(1:2,:);
    pp = states(1:2,:) - states(3:4,:);   
    tp = [states(12:3:end, 1)';states(13:3:end, 1)'];
    
    dtp = dot(tp,tp,1)';
    dcp = dot(cp,cp,1);
    dpp = dot(pp,pp,1);
    
    cd = dcp+dtp-2*(tp'*cp);
    pd = dpp+dtp-2*(tp'*pp);
end

function adp = all_deriv_perms()
    d1x_f = eye(3);
    d1y_f = eye(3);
    d2x_f = eye(3);
    d2y_f = eye(3);

    [d2y_c, d2x_c, d1y_c, d1x_c] = ndgrid(1:size(d2y_f,2), 1:size(d2x_f,2), 1:size(d1y_f,2), 1:size(d1x_f,2));

    adp = vertcat(d1x_f(:,d1x_c(:)), d1y_f(:,d1y_c(:)), d2x_f(:,d2x_c(:)), d2y_f(:,d2y_c(:)));
end

function atp = all_touch_perms()
    atp = [
        1 1 0 0;
        0 0 1 1;
        1 0 1 0;
        0 1 0 1;
    ];
end

function aap = all_approach_perms()
    xap_f = eye(3);
    yap_f = eye(3);
    bap_f = eye(3);

    [bap_c, yap_c, xap_c] = ndgrid(1:size(bap_f,2), 1:size(yap_f,2), 1:size(xap_f,2));

    aap = vertcat(xap_f(:,xap_c(:)), yap_f(:,yap_c(:)), bap_f(:,bap_c(:)));
end

function alp = all_location_perms()
    lox_f = eye(3);
    loy_f = eye(3);

    [loy_c, lox_c] = ndgrid(1:size(loy_f,2), 1:size(lox_f,2));

    alp = vertcat(lox_f(:,lox_c(:)), loy_f(:,loy_c(:)));
end

function T = basii2indexes_T(shape)

    shape = [shape, 1]; %add one for easier computing
    
    value_2_index_T = cell2mat(arrayfun(@(i) prod(shape((i+1):end)) .* ((1:shape(i))-1), 1:(numel(shape)-1), 'UniformOutput',false));
    
    value_2_index_T(end-shape(end-1)+1:end) = value_2_index_T(end-shape(end-1)+1:end) + 1;
    
    T = value_2_index_T;
end
