function state_2 = small_trans_post(state_1, actions)
    state_2 = vertcat(actions, repmat(state_1(3:end), [1 size(actions,2)]));
end