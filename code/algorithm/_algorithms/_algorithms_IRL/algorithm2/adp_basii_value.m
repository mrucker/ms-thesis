function b = adp_basii_value(states)

    adp_assert_states(states);

    %basis = [dx, dy, ddx, ddy, dddx, dddy, touch]
    b = zeros(13,size(states,2));

    for i = 1:size(states,2)
        if iscell(states)
            b(:,i) = state_to_value_basii(states{i});
        else
            b(:,i) = state_to_value_basii(states(:,i));
        end
    end
end

function b = state_to_value_basii(s)
    r = s(11);
    t = s(12:end);

    if isempty(t)
        touch_count = 0;
    else
        t = reshape(t, [], numel(t)/3);

        x1 = s(1:2);
        x2 = t(1:2,:);

        touch_count = sum(sqrt(dot(x2,x2,1)+dot(x1,x1,1)'-2*(x1'*x2)) <= r);
    end

    % basii to consider adding
    %-----------------------------------------------------
    % x distance from center,
    % y distance from center,
    % distance from three nearest targets,
    % direction changes required for optimal 3 target path
    derivative = s(3:8);
    
    derivative_pos = (derivative > 0) .*  derivative;
    derivative_neg = (derivative < 0) .* -derivative;
    
    b = [derivative_pos; derivative_neg; touch_count];
end