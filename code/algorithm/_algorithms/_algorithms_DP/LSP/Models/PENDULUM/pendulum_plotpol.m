function pendulum_plotpol(pol, stp1, stp2, iteration)

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
% pendulum_plotpol(pol, stp1, stp2)
%  
% Plots a 2D colormap of pol(state)
%
% The range is state = [st1 st2]
%    where st1 = [-pi/4:stp1:pi/4]  and  st2 = [-3:stp2:3] 
%
% "Iteration" is an optional argument. If provided (valid range is
% [1:12]) it creates 12 subplots and plots the data at the appropriate
% subplot according to the index "iteration". All figures are cleared
% for "iteration"==1. The previous subplots are held while
% "iteration">1.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

  rows=4;
  cols=3;

  if nargin<4
    iteration = 0;
  else
    iteration = min(rows*cols, iteration);
  end
  
  z1 = [-pi/4:stp1:pi/4];
  z2 = [-3:stp2:3];
  S1 = length(z1);
  S2 = length(z2);

  
  PPP=zeros(S1,S2);
  
  for ss1=1:S1
    for ss2=1:S2
      PPP(ss1, ss2) = policy_function(pol, [z1(ss1) z2(ss2)]);
      %PPP(ss1, ss2) = mglpendcontrol(pol, [z1(ss1) z2(ss2)]);
    end
  end
  
  figure(4); 
  if iteration<=1, clf, end
  if iteration>0, subplot(rows,cols,iteration), end
  
  pcolor(z1, z2, PPP');
  shading flat;
  
  if iteration==0
    colorbar;
    title('Policy');
    xlabel('Angle');
    ylabel('Angular velocity'); 
  else
    title(['Policy (' num2str(iteration) ')']);
  end

  drawnow;
  
  
  return
