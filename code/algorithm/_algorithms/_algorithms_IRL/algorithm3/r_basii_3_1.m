function rb = r_basii_3_1(states)

    %this could be made faster, 
    %it just doesn't seem to matter

    huge_states_assert(states);
    
    rb = zeros(25,size(states,2));

    for i = 1:size(states,2)
        if iscell(states)
            state = states{i};
        else
            state = states(:,i);
        end
        %[dx, dy, ddx, ddy, dddx, dddy, touch_count]
        rb(1: 6,  i) = state(3:8);
        rb(7:12,  i) = sign(state(3:8)) .* state(3:8).^2;
        rb(13:18, i) = abs(state(3:8));
        rb(19:24, i) = abs(state(3:8)).^2;
        rb(   25, i) = touch_count(state);
    end
end

function tc = touch_count(states)
    r2 = states(11, 1).^2;
    cp = states(1:2,:);
    pp = states(1:2,:) - states(3:4,:);
    
    tp = [states(12:3:end, 1)';states(13:3:end, 1)'];

    pt = (dot(pp,pp,1)+dot(tp,tp,1)'-2*(tp'*pp)) <= r2;
    ct = (dot(cp,cp,1)+dot(tp,tp,1)'-2*(tp'*cp)) <= r2;
    
    %not perfect, if a target simply appears on top 
    %of you then it won't count as an actual touch for us
    tc = sum(ct&~pt, 1);
end