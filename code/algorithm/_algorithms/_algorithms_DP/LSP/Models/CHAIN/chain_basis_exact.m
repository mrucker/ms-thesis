function phi = chain_basis_exact(state, action)

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
% phi = chain_basis_exact(state, action)
%
% Computes indicator basis functions for each pair (state,action)
% There is no approximation in this case. This basis is equivalent
% to having a tabular representation of the Q-function. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  S = chainstates;
  A = chainactions;
  numbasis = S*A;

  if nargin < 1
    phi=numbasis;
    return
  end
  
  phi = zeros(numbasis,1);

  if ( (state < 1) | (state > S) ) 
    return
  end
  
  %%% Find the starting position of the block
  base = (action-1) * (numbasis/A);

  %%% Set the indicator
  phi(base+state) = 1;

  
  return
