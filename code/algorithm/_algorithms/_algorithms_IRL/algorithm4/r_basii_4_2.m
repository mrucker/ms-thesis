function [state2vindex, m_f, t_f, a_f] = r_basii_4_2()

    m_f = move_features();
    t_f = targ_features();

    [t_c, m_c] = ndgrid(1:size(t_f,2),1:size(m_f,2));

    a_f = vertcat(m_f(:,m_c(:)), t_f(:,t_c(:)));

    a_n = size(a_f,2);
    e_n = @(row_n,rows) cell2mat(arrayfun(@(row) [zeros(row-1,1);1;zeros(row_n-row,1)], rows, 'UniformOutput', false)');
    
    state2vindex = @(states) e_n(a_n, locb_ismember(r_basii_cells(states)', a_f'));
end

function m_features = move_features()

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

function t_features = targ_features()

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

    [cnt_c, dir_c, age_c] = ndgrid(cnt_i, dir_i, age_i);

    t_features = vertcat(cnt_f(:,cnt_c(:)), dir_f(:,dir_c(:)), age_f(:,age_c(:)));
    z_features = zeros(size(t_features,1),1);
    
    t_features = horzcat(t_features, z_features);
end

function rb = r_basii_cells(states)
    rb = [];

    if iscell(states)
        for i = 1:numel(states)
            rb(:,i) = r_basii_features(states{i});
        end
    else
        rb = r_basii_features(states);
    end
end

function rb = r_basii_features(states)

    sc = size(states,2);
    ds = abs(states(3:6,:));

    tou = target_is_new_touch(states);
    
    %loc = target_location(states);
    cnt = target_center(states);
    age = target_age(states);    
    
    target_features = zeros(16,sc);
    
    for s_i = 1:sc
        %doing this means we don't differentiate between a double touch and
        %a single touch. This decision was made in order to reduce the size 
        %of our total feature matrix for kernel mathematics purposes.
        t_i = find(tou(:,s_i),1);
        tou(:  ,s_i) = 0;
        tou(t_i,s_i) = 1;
        
        dir = target_direction(states(:,s_i));
        target_features(:,s_i) = vertcat(cnt, dir, age) * tou;
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

    
    rb = rb();
end

function tnt = target_is_new_touch(states)
    r2 = states(11, 1).^2;
    cp = states(1:2,:);
    pp = states(1:2,:) - states(3:4,:);

    pt = target_distance([pp;states(3:end,:)]) <= r2;
    ct = target_distance([cp;states(3:end,:)]) <= r2;
    nt = states(14:3:end, 1) == 10; %10 comes from huge_trans_pre

    tnt = ct&(~pt|nt);
end

function td = target_distance(states)
    cp = states(1:2,:);
    tp = [states(12:3:end, 1)';states(13:3:end, 1)'];

    td = dot(cp,cp,1)+dot(tp,tp,1)'-2*(tp'*cp);
end

function td = target_direction(states)

    directions = [
        -1*pi/8, +1*pi/8, 1;
        +1*pi/8, +3*pi/8, 2;
        +3*pi/8, +5*pi/8, 3;
        +5*pi/8, +7*pi/8, 4;
        +7*pi/8, +8*pi/8, 5;
        -8*pi/8, -7*pi/8, 5;
        -7*pi/8, -5*pi/8, 6;
        -5*pi/8, -3*pi/8, 7;
        -3*pi/8, -1*pi/8, 8;
    ];

    direction_eye = eye(8);

    sc = size(states,2);
    cp = reshape(states(1:2,:), [], 1);
    tp = repmat([states(12:3:end, 1)';states(13:3:end, 1)'], sc, 1);

    tp_with_cp_as_origin = tp-cp;

    %when there are two maxes, it returns the first index. This might introduce
    %bias when learning rewards, but I don't think it is enough to matter.
    tv     = atan2(tp_with_cp_as_origin(2:2:end,:), tp_with_cp_as_origin(1:2:end,:));
    [~,ti] = max(directions(:,1) <= tv & tv <= directions(:,2), [], 1);
    td     = direction_eye(:,directions(ti,3)');
end

function tl = target_location(states)

    grid     = [3 3];

    screen_w = states(9,1);
    screen_h = states(10,1);

    cell_w   = screen_w/grid(1);
    cell_h   = screen_h/grid(2);

    b_w = horzcat((1:grid(1))'-1, (1:grid(1))'-0) * cell_w;
    b_h = horzcat((1:grid(2))'-1, (1:grid(2))'-0) * cell_h;

    tp = [states(12:3:end, 1)';states(13:3:end, 1)'];

    xs = tp(1,:);
    ys = tp(2,:);

    tl = [double(b_w(:,1) <= xs & xs < b_w(:,2));double(b_h(:,1) <= ys & ys < b_h(:,2))];
end

function ta = target_age(states)

    age_eye = eye(4);

    ages = [
        0  , 250, 1;
        250, 500, 2;
        500, 750, 3;
        750, inf, 4;
    ];

    tv     = states(14:3:end, 1)';
    [~,ti] = max(ages(:,1) <= tv & tv <= ages(:,2), [], 1);
    ta     = age_eye(:,ages(ti,3)');
end

function tc = target_center(states)

    center_eye = eye(4);

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
    tc     = center_eye(:,centers(ti,3)');
end

function locB = locb_ismember(A,B)
    [Lia, locB] = ismember(A, B, 'rows');

    assert(all(Lia), 'The state reward features (A) were not found anywhere in the complete feature matrix (B)');
end