function s_2 = small_trans_post(s_1, actions)
    s_2 = vertcat(actions, repmat(s_1(3:end), [1 size(actions,2)]));
end