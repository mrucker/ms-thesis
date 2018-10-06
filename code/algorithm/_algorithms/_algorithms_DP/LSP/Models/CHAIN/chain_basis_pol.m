function phi = chain_basis_pol(state, action)
  
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
% phi = chain_basis_pol(state, action)
%
% Computes a set of polynomial (on "state") basis functions (up to a
% certain degree). The set is duplicated for each action. The "action"
% determines which segment will be active.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  
  degpol = 4;          % Degree of the polynomial 
  S = chainstates;
  A = chainactions;

  %%% The polynomial is repeated for each action
  numbasis = (degpol+1) * A;
  
  %%% If no arguments just return the number of basis functions
  if nargin == 0
    phi = numbasis;
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
  
  %%% Compute polynomial terms
  phi(base+1) = 1;

  for i = 2:(degpol+1)
  
    %%% Scaling of state to (0,10] to avoid numerical problems
    phi(base+i) = phi(base+i-1) * (10*state/S);
    
    %%% Without scaling should also be OK in most cases
    %phi(base+i) = phi(base+i-1) * state;
    
  end
  
  
  return
  
