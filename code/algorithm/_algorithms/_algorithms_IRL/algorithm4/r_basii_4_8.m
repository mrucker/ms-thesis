function [state2identity, r_p, r_b] = r_basii_4_8()

    r_p = all_targ_perms();

    a_n = size(r_p,2);
    a_T = basii2indexes_T([3 3 6 8],[3 3 6 8]);

    %we add the "+1" in order to include the 0 target permutation at the start
    state2identity = @(states) double(1:a_n == (a_T*statesfun(@r_basii_dummy, states) + 1)' )';

    r_b = @(states) statesfun(@r_basii_feats, states);
end

function rb = statesfun(func, states)
    if iscell(states)
        rb = cell2mat(cellfun(func, states, 'UniformOutput',false)');
    else
        rb = func(states);
    end
end

function rb = r_basii_dummy(states)

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
        target_features = zeros(20,1);
    else
        %???
        lox = sum(target_lox_features(states)       .* tou,1);

        %???
        loy = sum(target_loy_features(states)       .* tou,1);

        %???
        vel = sum(target_vel_features(states)       .* tou,1);

        %.25
        dir = sum(target_direction_features(states) .* tou,1);

        target_features = double(vertcat((1:3)' == lox, (1:3)' == loy, (1:6)' == vel, (1:8)' == dir));
    end

    rb = target_features;
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
        target_features = zeros(10,1);
    else
        %???
        lox = sum(target_lox_features(states)       .* tou,1);

        %???
        loy = sum(target_loy_features(states)       .* tou,1);

        %???
        vel = sum(target_vel_features(states)       .* tou,1);

        %.25
        dir = sum(target_direction_features(states) .* tou,1);

        val_to_loc = @(val, den) [cos(val*pi/den); sin(val*pi/den)];

        target_features = [
            val_to_loc(lox-1, 4);
            val_to_loc(loy-1, 4);
            val_to_loc(vel-1, 4);
            val_to_loc(dir+3, 4);
        ];
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

    trg_n = (size(states,1) - 11)/3;
    
    tv2 = atan2(states(4,:), states(3,:));    
    tv2 = floor((tv2 + 3*pi/8) ./ (2*pi/8));
    tv2 = tv2 + 8*(tv2<=0);

    td = repmat(tv2,trg_n,1);
end

function tx = target_lox_features(states)

    vals = states(12:3:end,1);
    max  = states(09,1);
    bins = 3;

    tx = repmat(target_bin_features(vals, max, bins)', 1, size(states,2));
end

function ty = target_loy_features(states)

    vals = states(13:3:end,1);
    max  = states(10,1);
    bins = 3;

    ty = repmat(target_bin_features(vals, max, bins)', 1, size(states,2));
end

function tx = target_vel_features(states)

    vals = vecnorm(states(3:4,:))';
    max  = 78;
    bins = 6;
    
    trg_n = (size(states,1) - 11)/3;

    tx = repmat(target_bin_features(vals, max, bins), trg_n, 1);
end

function tb = target_bin_features(vals, max_val, bin_n)

    bins = [(1:bin_n-1)/bin_n, inf] * max_val;

    [~, tb] = max(vals' <= bins');
end

function perms = all_targ_perms()

    val_to_loc = @(val, den) [cos(val*pi/den); sin(val*pi/den)];

    lox_f = cell2mat(arrayfun(@(v) val_to_loc(v-1,2), 1:3, 'UniformOutput', false));
    loy_f = cell2mat(arrayfun(@(v) val_to_loc(v-1,2), 1:3, 'UniformOutput', false));
    vel_f = cell2mat(arrayfun(@(v) val_to_loc(v-1,4), 1:6, 'UniformOutput', false));
    dir_f = cell2mat(arrayfun(@(v) val_to_loc(v+3,4), 1:8, 'UniformOutput', false));

    lox_i = 1:size(lox_f,2);
    loy_i = 1:size(loy_f,2);
    vel_i = 1:size(vel_f,2);
    dir_i = 1:size(dir_f,2);

    [dir_c, vel_c, loy_c, lox_c] = ndgrid(dir_i, vel_i, loy_i, lox_i);

    t_features = vertcat(lox_f(:,lox_c(:)), loy_f(:,loy_c(:)), vel_f(:,vel_c(:)), dir_f(:,dir_c(:)));
    t_features = vertcat(t_features, zeros(1,size(t_features,2)));
    z_features = [zeros(size(t_features,1)-1,1); 4]; 
    
    %min(vecnorm(a_f(:,1) - a_f(:,2:end)))
    %max(pdist(a_f(:,2:end)'))

    perms = horzcat(z_features,t_features);
end

function T = basii2indexes_T(vals, vars)

    vals = [vals, 1]; %add one for easier computing

    targ_2_index_T = cell2mat(arrayfun(@(i) prod(vals((i+1):end)) .* fliplr((vals(i)-1) - (0:vars(i)-1)), 1:(numel(vals)-1), 'UniformOutput',false));

    targ_2_index_T(end-vals(end-1)+1:end) = targ_2_index_T(end-vals(end-1)+1:end) + 1;

    T = targ_2_index_T;
end