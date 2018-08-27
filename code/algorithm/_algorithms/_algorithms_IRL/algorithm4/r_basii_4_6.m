function [state2identity, r_p, r_b] = r_basii_4_6()

    r_p = all_targ_perms();

    a_n = size(r_p,2);
    a_T = basii2indexes_T([3 3 3 3 8],[3 3 3 3 8]);

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
        vox = sum(target_vox_features(states)       .* tou,1);

        %???
        voy = sum(target_voy_features(states)       .* tou,1);

        %.25
        dir = sum(target_direction_features(states) .* tou,1);

        target_features = double(vertcat((1:3)' == lox, (1:3)' == loy, (1:3)' == vox, (1:3)' == voy, (1:8)' == dir));
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
        vox = sum(target_vox_features(states)       .* tou,1);

        %???
        voy = sum(target_voy_features(states)       .* tou,1);

        %.25
        dir = sum(target_direction_features(states) .* tou,1);

        val_to_loc = @(val, den) [cos(val*pi/den); sin(val*pi/den)];

        target_features = [
            val_to_loc(lox-1, 4);
            val_to_loc(loy-1, 4);
            val_to_loc(vox-1, 4);
            val_to_loc(voy-1, 4);
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

function tx = target_vox_features(states)

    vals = states(3,:)';
    max  = 99;
    bins = 3;
    
    trg_n = (size(states,1) - 11)/3;

    tx = repmat(target_bin_features(vals, max, bins), trg_n, 1);
end

function ty = target_voy_features(states)

    vals = states(4,:)';
    max  = 99;
    bins = 3;

    trg_n = (size(states,1) - 11)/3;

    ty = repmat(target_bin_features(vals, max, bins), trg_n, 1);
end

function tb = target_bin_features(vals, max_val, bin_n)

    bins = [(1:bin_n-1)/bin_n, inf] * max_val;

    [~, tb] = max(vals' <= bins');
end

function perms = all_targ_perms()

    val_to_loc = @(val, den) [cos(val*pi/den); sin(val*pi/den)];

    lox_f = cell2mat(arrayfun(@(v) val_to_loc(v-1,4), 1:3, 'UniformOutput', false));
    loy_f = cell2mat(arrayfun(@(v) val_to_loc(v-1,4), 1:3, 'UniformOutput', false));
    vox_f = cell2mat(arrayfun(@(v) val_to_loc(v-1,4), 1:3, 'UniformOutput', false));
    voy_f = cell2mat(arrayfun(@(v) val_to_loc(v-1,4), 1:3, 'UniformOutput', false));
    dir_f = cell2mat(arrayfun(@(v) val_to_loc(v+3,4), 1:8, 'UniformOutput', false));

    lox_i = 1:size(lox_f,2);
    loy_i = 1:size(loy_f,2);
    vox_i = 1:size(vox_f,2);
    voy_i = 1:size(voy_f,2);
    dir_i = 1:size(dir_f,2);

    [dir_c, voy_c, vox_c, loy_c, lox_c] = ndgrid(dir_i, voy_i, vox_i, loy_i, lox_i);

    t_features = vertcat(lox_f(:,lox_c(:)), loy_f(:,loy_c(:)), vox_f(:,vox_c(:)), voy_f(:,voy_c(:)), dir_f(:,dir_c(:)));
    z_features = zeros(size(t_features,1),1);

    perms = horzcat(z_features,t_features);
end

function T = basii2indexes_T(vals, vars)

    vals = [vals, 1]; %add one for easier computing
    
    targ_2_index_T = cell2mat(arrayfun(@(i) prod(vals((i+1):end)) .* fliplr((vals(i)-1) - (0:vars(i)-1)), 1:(numel(vals)-1), 'UniformOutput',false));

    targ_2_index_T(end-vals(end-1)+1:end) = targ_2_index_T(end-vals(end-1)+1:end) + 1;
        
    T = targ_2_index_T;
end