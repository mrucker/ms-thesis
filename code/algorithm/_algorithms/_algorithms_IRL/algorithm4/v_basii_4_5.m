function [v_i, v_p, v_b] = v_basii_4_5()
    
    LEVELS_N = [3 3 3 3 8 3 3];
           
    v_I = I(LEVELS_N);

    v_p = v_perms();
    v_i = @(states) v_I'*(statesfun(@v_levels, states)-1) + 1;
    v_b = @(states) statesfun(@v_feats, states);    
end

function vl = v_levels(states)

    l_x = cursor_x_levels(states);
    l_y = cursor_y_levels(states);
    l_v = cursor_v_levels(states);
    l_a = cursor_a_levels(states);
    l_d = cursor_d_levels(states);
    [l_t,l_n] = target_t_n_levels(states);

    vl = vertcat(l_x, l_y, l_v, l_a, l_d, l_t, l_n);
end

function [vf] = v_feats(states)
    val_to_d = @(val,den) val/den;
    val_to_e = @(val,  n) double(1:n == val')';
    val_to_r = @(val, den) [cos(val*pi/den); sin(val*pi/den)];
    
    levels = v_levels(states);
    
    x = levels(1,:);
    y = levels(2,:);
    v = levels(3,:);
    a = levels(4,:);
    d = levels(5,:);
    t = levels(6,:);
    n = levels(7,:);
    
    vf = [
        val_to_d(x-1,2);
        val_to_d(y-1,2);
        val_to_d(v-1,2);
        val_to_d(a-1,2);
        val_to_r(d-1,4);
        val_to_e(t-0,3);
        val_to_d(n-1,2);
    ];
end

function rp = v_perms()

    LEVELS_N = [3 3 3 3 8 3 3];

    val_to_d = @(val,den) val/den;
    val_to_e = @(val,  n) double(1:n == val)';
    val_to_r = @(val, den) [cos(val*pi/den); sin(val*pi/den)];

    x_f = cell2mat(arrayfun(@(L) val_to_d(L-1, 2), 1:LEVELS_N(1), 'UniformOutput', false));
    y_f = cell2mat(arrayfun(@(L) val_to_d(L-1, 2), 1:LEVELS_N(2), 'UniformOutput', false));
    v_f = cell2mat(arrayfun(@(L) val_to_d(L-1, 2), 1:LEVELS_N(3), 'UniformOutput', false));
    a_f = cell2mat(arrayfun(@(L) val_to_d(L-1, 2), 1:LEVELS_N(4), 'UniformOutput', false));
    d_f = cell2mat(arrayfun(@(L) val_to_r(L-1, 4), 1:LEVELS_N(5), 'UniformOutput', false));
    t_f = cell2mat(arrayfun(@(L) val_to_e(L-0, 3), 1:LEVELS_N(6), 'UniformOutput', false));
    n_f = cell2mat(arrayfun(@(L) val_to_d(L-1, 2), 1:LEVELS_N(7), 'UniformOutput', false));

    x_i = 1:size(x_f,2);
    y_i = 1:size(y_f,2);
    v_i = 1:size(v_f,2);
    a_i = 1:size(a_f,2);
    d_i = 1:size(d_f,2);
    t_i = 1:size(t_f,2);
    n_i = 1:size(n_f,2);
    
    [n_c, t_c, d_c, a_c, v_c, y_c, x_c] = ndgrid(n_i, t_i, d_i, a_i, v_i, y_i, x_i);

    rp = [
        x_f(:,x_c(:));
        y_f(:,y_c(:));
        v_f(:,v_c(:));
        a_f(:,a_c(:));
        d_f(:,d_c(:));
        t_f(:,t_c(:));
        n_f(:,n_c(:));
    ];
end

function cx = cursor_x_levels(states)
    LEVELS_N = [3 3 3 3 8 3 3];

    bin_n = LEVELS_N(1);
    bin_s = states(09,1)/bin_n;    
    vals  = states(1,:);

    cx = bin_levels(vals, bin_s, bin_n);
end

function cy = cursor_y_levels(states)
    LEVELS_N = [3 3 3 3 8 3 3];

    bin_n = LEVELS_N(2);
    bin_s = states(10,1)/bin_n;    
    vals  = states(2,:);

    cy = bin_levels(vals, bin_s, bin_n);
end

function cv = cursor_v_levels(states)
    LEVELS_N = [3 3 3 3 8 3 3];

    bin_n = LEVELS_N(3);
    bin_s = 25;
    vals = vecnorm(states(3:4,:));

    cv = bin_levels(vals, bin_s, bin_n);
end

function ca = cursor_a_levels(states)
    LEVELS_N = [3 3 3 3 8 3 3];

    bin_n = LEVELS_N(3);
    bin_s = 25;
    vals = vecnorm(states(5:6,:));

    ca = bin_levels(vals, bin_s, bin_n);
end

function cd = cursor_d_levels(states)
    LEVELS_N = [3 3 3 3 8 3 3];

    slices = LEVELS_N(5);

    tv2 = atan2(-states(4,:), states(3,:));
    tv2 = floor((tv2 + 3*pi/slices) ./ (2*pi/slices));
    tv2 = tv2 + slices*(tv2<=0);

    cd = tv2;
end

function [tt, tn] = target_t_n_levels(states)
    
    LEVELS_N = [3 3 3 3 8 3 3];
    
    r2 = states(11, 1).^2;
    
    [cd, pd] = distance_features(states);

    ct = cd <= r2;
    pt = pd <= r2;
    nt = states(14:3:end, 1) <= 30; %in theory this could be 33 (aka, one observation 30 times a second)

    enter_target = any(ct&(~pt|nt),1);
    leave_target = any(~ct&pt     ,1);

    approach_n = sum(cd < pd,1);

    tt = [1 2 3] * [ (~enter_target & ~leave_target); (enter_target); (~enter_target & leave_target ); ];
    tn = bin_levels(approach_n, 2, LEVELS_N(7));
end

%% Probably don't need to change %%
function v = I(n)
    n = [n, 1]; %add one for easier computing
    v = arrayfun(@(i) prod(n(i:end)), 2:numel(n))';
end

function sf = statesfun(func, states)
    if iscell(states)
        sf = cell2mat(cellfun(func, states, 'UniformOutput',false)');
    else
        sf = func(states);
    end
end

function bl = bin_levels(vals, bin_s, bin_n)

    %r_bins = [   1:bin_n-1, inf]' * bin_s;
    %l_bins = [0, 1:bin_n-1     ]' * bin_s;
    
    %bin_ident = l_bins <= vals & vals < r_bins;
    %bl = (1:bin_n) * bin_ident;
    
    [~, bl] = max(vals <= [1:bin_n-1, inf]' * bin_s);
    
    %bins = (1:bin_n-1) * bin_s;
    %bl = discretize(vals,[0,bins,inf]);
end

function [cd, pd] = distance_features(states)
    cp = states(1:2,:);
    pp = states(1:2,:) - states(3:4,:);   
    tp = [states(12:3:end, 1)';states(13:3:end, 1)'];

    dtp = dot(tp,tp,1);
    dcp = dot(cp,cp,1);
    dpp = dot(pp,pp,1);

    cd = dcp+dtp'-2*(tp'*cp);
    pd = dpp+dtp'-2*(tp'*pp);
end

%% Probably don't need to change %%