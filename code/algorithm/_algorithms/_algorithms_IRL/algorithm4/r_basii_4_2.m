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

    touch_f = [1 0];    
    touch_i = 1:size(touch_f,2);    
    touch_c = ndgrid(touch_i);            

    t_features = vertcat(touch_f(:,touch_c(:)));
end

function rb = r_basii_features(states)

    ds   = abs(states(3:6,:));
    tc   = target_new_touch_count(states);
    ds_i = 1:4:12;

    rb = [
        double(0  <= ds & ds < 15 );
        double(15 <= ds & ds < 50 );
        double(50 <= ds & ds < inf);
        double(0  <  tc(1)        );
    ];

    rb = rb([0+ds_i,1+ds_i,2+ds_i,3+ds_i,13],:);
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

function [tc,lc] = target_new_touch_count(states)
    r2 = states(11, 1).^2;
    cp = states(1:2,:);
    pp = states(1:2,:) - states(3:4,:);

    pt = target_distance([pp;states(3:end,:)]) <= r2;
    ct = target_distance([cp;states(3:end,:)]) <= r2;

    %not perfect, if a target simply appears on top 
    %of you then it won't count as an actual touch for us
    tc = sum(ct&~pt, 1);
    lc = sum(~ct&pt, 1);
end

function td = target_distance(states)
    cp = states(1:2,:);
    tp = [states(12:3:end, 1)';states(13:3:end, 1)'];

    td = dot(cp,cp,1)+dot(tp,tp,1)'-2*(tp'*cp);
end

function locB = locb_ismember(A,B)
    [Lia, locB] = ismember(A, B, 'rows');

    assert(all(Lia), 'there is a mismatch between the feature matrix and our state features');
end