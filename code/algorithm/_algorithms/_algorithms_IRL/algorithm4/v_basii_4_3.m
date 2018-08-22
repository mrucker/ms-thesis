function [vb,t] = v_basii_4_2(states)
    [vb,t] = v_basii_cells(states, @v_basii);
end

function [vb,t] = v_basii_cells(states, VBf)
    t = 0;
    if iscell(states)
        vb = [];
        for i = 1:numel(states)
            [vb(:,i),tt] = VBf(states{i});
            t = t+tt;
        end
    else
        [vb,t] = VBf(states);
    end
end

function [vb,time] = v_basii(states)
    %t_start = tic;
    %time = toc(t_start);
    time = 0;

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

    [cd, pd] = target_distance(states);
    
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

function [cd, pd] = target_distance(states)
    cp = states(1:2,:);
    pp = states(1:2,:) - states(3:4,:);   
    tp = [states(12:3:end, 1)';states(13:3:end, 1)'];
    
    dtp = dot(tp,tp,1)';
    dcp = dot(cp,cp,1);
    dpp = dot(pp,pp,1);
    
    cd = dcp+dtp-2*(tp'*cp);
    pd = dpp+dtp-2*(tp'*pp);
end
