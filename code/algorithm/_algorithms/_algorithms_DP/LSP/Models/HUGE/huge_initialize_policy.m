function policy = huge_initialize_policy(explore, discount, basis); persistent actions;

  if(isempty(actions))
    s_a = s_act_4_2();
    actions = s_a([]);
  end

  policy.explore = explore;
  
  policy.discount = discount;

  policy.actions = size(actions,2);
  
  policy.basis = basis;
  
  k = feval(basis);
  
  %%% Initial weights 
  policy.weights = zeros(k,1);  % Zeros
  %policy.weights = ones(k,1);  % Ones
  %policy.weights = rand(k,1);  % Random
end