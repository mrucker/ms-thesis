function policy = chain_initialize_policy(explore, discount, basis)
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Copyright 2000-2002 
%
% Michail G. Lagoudakis (mgl@cs.duke.edu)
% Ronald Parr (parr@cs.duke.edu)
%
% Department of Computer Science
% Box 90129
% Duke University, NC 27708
% 
%
% policy = chain_initialize_policy(explore, discount, basis)
%
% Creates and initializes a new policy
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  
  policy.explore = explore;
  
  policy.discount = discount;

  policy.actions = 2;
  
  policy.basis = basis;
  
  k = feval(basis);
  
  %%% Initial weights 
  policy.weights = zeros(k,1);  % Zeros
  %policy.weights = ones(k,1);  % Ones
  %policy.weights = rand(k,1);  % Random
