function [r_i, r_p, r_b] = r_basii_4_9()

    LEVELS_N = [3 3 12 6 8 1];
    
    r_p = r_perms();

    r_I = I(LEVELS_N);

    r_i = @(states) r_I'*(statesfun(@r_levels, states)-1) + 1;
    r_b = @(states) statesfun(@r_feats, states);
end

function rl = r_levels(states)

    s_n = size(states,2);
    tou = touch_features(states);

    if all(all(~tou))
        rl = ones(6, s_n);
    else
        [~,ti] = max(tou,[],1);
        tou(:) = 0;
        tou(sub2ind(size(tou), ti, 1:s_n)) = 1;

        lox = sum(target_x_features(states) .* tou,1) + all(~tou);
        loy = sum(target_y_features(states) .* tou,1) + all(~tou);
        vel = sum(target_v_features(states) .* tou,1) + all(~tou);
        acc = sum(target_a_features(states) .* tou,1) + all(~tou);
        dir = sum(target_d_features(states) .* tou,1) + all(~tou);
        tou = 1*(sum(tou,1) == 0) + 2*(sum(tou,1) == 1);

        rl = vertcat(lox, loy, vel, acc, dir, tou);
    end
end

function rf = r_feats(states)

    levels = r_levels(states);

    assert(all(levels>0), 'bad levels');

    val_to_rad = @(val, den) (val~=-1) .* [cos(val*pi/den); sin(val*pi/den)];

    x = levels(1,:) - (levels(end) == 1);
    y = levels(2,:) - (levels(end) == 1);
    v = levels(3,:) - (levels(end) == 1);
    a = levels(4,:) - (levels(end) == 1);
    d = levels(5,:) - (levels(end) == 1);

    rf = [
        val_to_rad(x-1, 2 );
        val_to_rad(y-1, 2 );
        val_to_rad(v-1, 30);
        val_to_rad(a-1, 5 );
        val_to_rad(d-1, 4 );
        4 * all(levels(end)==1);
    ];

end

function rp = r_perms()

    LEVELS_N = [3 3 12 6 8 1];

    val_to_rad = @(val, den) [cos(val*pi/den); sin(val*pi/den)];

    x_f = cell2mat(arrayfun(@(v) val_to_rad(v-1,2 ), 1:LEVELS_N(1), 'UniformOutput', false));
    y_f = cell2mat(arrayfun(@(v) val_to_rad(v-1,2 ), 1:LEVELS_N(2), 'UniformOutput', false));
    v_f = cell2mat(arrayfun(@(v) val_to_rad(v-1,30), 1:LEVELS_N(3), 'UniformOutput', false));
    a_f = cell2mat(arrayfun(@(v) val_to_rad(v-1,5 ), 1:LEVELS_N(4), 'UniformOutput', false));
    d_f = cell2mat(arrayfun(@(v) val_to_rad(v-1,4 ), 1:LEVELS_N(5), 'UniformOutput', false));
    z_f = 0;

    x_i = 1:size(x_f,2);
    y_i = 1:size(y_f,2);
    v_i = 1:size(v_f,2);
    a_i = 1:size(a_f,2);
    d_i = 1:size(d_f,2);
    z_i = 1:size(z_f,2);

    [z_c, d_c, a_c, v_c, y_c, x_c] = ndgrid(z_i, d_i, a_i, v_i, y_i, x_i);

    touch_1 = vertcat(x_f(:,x_c(:)), y_f(:,y_c(:)), v_f(:,v_c(:)), a_f(:,a_c(:)), d_f(:,d_c(:)), z_f(:,z_c(:)));
    touch_0 = [zeros(10,1); 4];

    rp = horzcat(touch_0,touch_1);
end

function tx = target_x_features(states)

    LEVELS_N = [3 3 12 6 8 1];

    bin_n = LEVELS_N(1);
    bin_s = states(09,1)/bin_n;    
    vals  = states(12:3:end,1);

    tx = repmat(binned_features(vals, bin_s, bin_n)', 1, size(states,2));
end

function ty = target_y_features(states)

    LEVELS_N = [3 3 12 6 8 1];

    bin_n = LEVELS_N(2);
    bin_s = states(10,1)/bin_n;
    vals  = states(13:3:end,1);

    ty = repmat(binned_features(vals, bin_s, bin_n)', 1, size(states,2));
end

function tv = target_v_features(states)

    LEVELS_N = [3 3 12 6 8 1];

    bin_n = LEVELS_N(3);
    bin_s = 6;
    vals = vecnorm(states(3:4,:))';

    trg_n = (size(states,1) - 11)/3;

    tv = repmat(binned_features(vals, bin_s, bin_n), trg_n, 1);
end

function ta = target_a_features(states)

    LEVELS_N = [3 3 12 6 8 1];

    bin_n = LEVELS_N(4);
    bin_s = 20;
    vals = vecnorm(states(5:6,:))';

    trg_n = (size(states,1) - 11)/3;

    ta = repmat(binned_features(vals, bin_s, bin_n), trg_n, 1);
end

function td = target_d_features(states)

    LEVELS_N = [3 3 12 6 8 1];

    slice = LEVELS_N(5);
    trg_n = (size(states,1) - 11)/3;

    tv2 = atan2(-states(4,:), states(3,:));
    tv2 = floor((tv2 + 3*pi/slice) ./ (2*pi/slice));
    tv2 = tv2 + slice*(tv2<=0);

    td = repmat(tv2,trg_n,1);
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

function tb = binned_features(vals, bin_s, bin_n)

    bins = [1:bin_n-1, inf] * bin_s;

    [~, tb] = max(vals' <= bins');
end

function tt = touch_features(states)
    r2 = states(11, 1).^2;

    [cd, pd] = distance_features(states);

    ct = cd <= r2;
    pt = pd <= r2;
    nt = states(14:3:end, 1) <= 30; %in theory this could be 33 (aka, one observation 30 times a second)

    tt = ct&(~pt|nt);
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