function rb = r_basii_4(states)

    %this could be made faster, 
    %it just doesn't seem to matter

    huge_states_assert(states);
    
    rb = zeros(31,size(states,2));

    for i = 1:size(states,2)
        if iscell(states)
            state = states{i};
        else
            state = states(:,i);
        end
        %[dx, dy, ddx, ddy, dddx, dddy, touch_count]
                
        rb(:, i) = [
            double(abs(state(1:6)) < 5)                          ;
            double(abs(state(1:6)) > 5  & abs(state(1:6)) < 10);
            double(abs(state(1:6)) > 10 & abs(state(1:6)) < 20);
            double(abs(state(1:6)) > 20 & abs(state(1:6)) < 50);
            double(abs(state(1:6)) > 50)                         ;
            touch_count(state);
        ];
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