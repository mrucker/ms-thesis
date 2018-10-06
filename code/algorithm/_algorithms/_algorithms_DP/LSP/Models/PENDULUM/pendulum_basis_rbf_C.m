function   phi = pendulum_basis_rbf_C( state, action,  Dic, para)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Copyright 2000-2002 
%
% Michail G. Lagoudakis (mgl@cs.duke.edu)
% Ronald Parr (parr@cs.duke.edu)
%
% Department of Computer Science
% Box 90129
% Duke University
% Durham, NC 27708
% 
%
% phi = pendulum_basis_rbf_C(state, action)
%
% Computes RBF basis functions for the pendulum domain. The RBFs are
% arranged in a nrbfx x nrbfy grid with their means equally spaced
% over angle [-pi/4:pi/4] and angular velocity [-1:1] and sigma^2 =
% 1. In addition, there is also a constant basis function. The set is
% duplicated for each action. The "action" determines which segment
% will be active.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 pend_actions = 3;

 nrbfx = 3;
 nrbfy = 3;
 numbasis = (nrbfx*nrbfy+1) * pend_actions ;

 mypi  =  acos(-1);
  
  

  if  nargin<2
     phi =  numbasis; 
     return;
  else
     phi = zeros(numbasis, 1); %%%% phi[i]=0.0;
  end

  
   

  if  abs(state(1)) > (mypi/2.0) 
      return;
  end
  
  base = (numbasis / pend_actions) * ( action - 1 ); 

  base =base +1;
  phi(base) = 1.0;
  

  sigma2 = 1;
  x=zeros(2, 1);
  for i=-1:1:1  %% x(1,1)=(-mypi/4.0); mypi/4.0: mypi/4.0
    for j=-1:1:1 %%x(2,1)=-1: 1: 1 
      x(1, 1)= i*(-mypi/4.0);
      x(2, 1)= j;
      dist = norm(state-x')* norm (state-x');  %% sqr(state[0]-x) + sqr(state[1]-y);      
      base=base +1;
      phi(base) = exp( -dist / (2*sigma2) );      
   end
  end
  
return;