function [v, q1, q2, q] = chainsolve(policy)
  
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
% [v, v1, v2, gv] = chainsolve(policy)
%
% Evaluates the input policy by solving the model of the chain
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  
  [s, r, e, PR, R] = chain_simulator;

  dim = length(R);
  
  PA{1} = squeeze( PR(:,1,:) );
  PA{2} = squeeze( PR(:,2,:) );
  
  P = zeros(dim, dim);
  for i=1:dim
    a = policy_function(policy, i);
    P(i,:) = PA{a}(i,:);
  end
  
  v = (eye(dim) - policy.discount * P) \ R;
  
  q1 = R + policy.discount * PA{1} * v;
  q2 = R + policy.discount * PA{2} * v;
  q = max(q1,q2);
  
  return
  
  
