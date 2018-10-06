function phi = chain_basis_rbf(state, action)

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
% phi = chain_basis_rbf(state, action)
%
% Computes a number of radial basis functions (on "state") with means
% spread uniformly over the chain. This block of basis functions is
% duplicated for each action. The "action" determines which segment
% will be active.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  S = chainstates;
  A = chainactions;
  
  PP = 4;              % Number of states between RBFs
  nrbf = floor(S/PP); 
  SS = 2*S/nrbf;
  
  %%% The RBFs and a constant is repeated for each action
  numbasis = (nrbf+1)*A;
  
  %%% If no arguments just return the number of basis functions
  if nargin < 1
    phi=numbasis;
    return
  end
  
  %%% Initialize
  phi = zeros(numbasis,1);
  
  %%% If state is out of bounds, return
  if ( (state < 1) | (state > S) ) 
    return
  end
  
  %%% Find the starting position
  base = (action-1) * (numbasis/A);
  
  %%% Compute the RBFs
  for i=1:nrbf
    cent = (i-1)*PP+1;
    phi(base+i) = exp(-norm(state-cent)^2/SS^2);
  end
  
  %%% ... and the constant!
  phi(base+nrbf+1) = 1;
  
  return
  
