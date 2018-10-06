function pendulum_plotval23d(pol, stp1, stp2, action, iteration)

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
% pendulum_plotval23d(pol, stp1, stp2, action)
%  
% Plots a 2D (colormap) and a 3D graph of Q(state,action) if action>0
% or Q(state, pol(state)) if action==0
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

  if nargin<5
    iteration = 0;
  else
    iteration = min(rows*cols, iteration);
  end
  
  z1 = [-pi/4:stp1:pi/4];
  z2 = [-3:stp2:3];
  S1 = length(z1);
  S2 = length(z2);
  

  QQQ=zeros(S1,S2);

  for ss1=1:S1
    for ss2=1:S2
      
      state = [z1(ss1) z2(ss2)];
      
      if action==0
	QQQ(ss1, ss2) = Qvalue(state, policy_function(pol,state), pol);
      else
	QQQ(ss1, ss2) = Qvalue(state, action, pol);
      end
      
    end
  end


    
  figure(2);
  if iteration<=1, clf, end
  if iteration>0, subplot(rows,cols,iteration), end

  imagesc(QQQ');
  
  xlabel('Angle');
  ylabel('Angular velocity');
  
  colorbar;
  drawnow;
  
  
  figure(3);
  if iteration<=1, clf, end
  if iteration>0, subplot(rows,cols,iteration), end

  surf(z1,z2,QQQ');

  xlabel('Angle');
  ylabel('Angular Velocity');
  zlabel(strcat('Q-value for action ',num2str(action)));

  drawnow;  
  
    
  
  return
