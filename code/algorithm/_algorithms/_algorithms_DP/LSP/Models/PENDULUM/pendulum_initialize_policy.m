function policy = pendulum_initialize_policy(explore, discount, basis)
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 
%
% policy = pendulum_initialize_policy(explore, discount, basis)
%
% Creates and initializes a new policy
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  
  policy.explore = explore;
  
  policy.discount = discount;

  policy.actions = 3;
  
  policy.basis = basis;
  
  k = feval(basis);
  
  %%% Initial weights 
  policy.weights = zeros(k,1);  % Zeros
  %policy.weights = rand(k,1);  % Random

  return
