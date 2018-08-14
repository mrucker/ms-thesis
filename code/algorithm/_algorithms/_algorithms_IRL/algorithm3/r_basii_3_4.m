function rb = r_basii_3_4(states)
    rb = r_basii_cells(states, @r_basii_features);    
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

function rb = r_basii_cells(states, RBf)
    rb = [];
    
    if iscell(states)
        for i = 1:numel(states)
            rb(:,i) = RBf(states{i});
        end
        
    else
        rb = RBf(states);
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