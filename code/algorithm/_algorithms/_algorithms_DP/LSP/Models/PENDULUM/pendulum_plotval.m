function pendulum_plotval(pol, stp, st2, iteration)

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
% pendulum_plotval(pol, stp, st2)
%  
% Plots the Q(state,pol(state)), Q(state,1), Q(state,2), Q(state,3)
%
% where state = [st1 st2]  and  st1 = [-pi/4:stp:pi/4]
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
  
  z = [-pi/4:stp:pi/4];
  S = length(z);

  QQQ = zeros(S,1);
  Q1 = zeros(S,1);
  Q2 = zeros(S,1);
  Q3 = zeros(S,1);

  for s=1:1:S

    state = [z(s) st2];
    QQQ(s) = Qvalue(state, policy_function(pol,state), pol);
    Q1(s) = Qvalue(state, 1, pol);
    Q2(s) = Qvalue(state, 2, pol);
    Q3(s) = Qvalue(state, 3, pol);
    
  end
  
  figure(1);
  if iteration<=1, clf, end
  if iteration>0, subplot(rows,cols,iteration), end
  
  plot(z, QQQ, 'm.', z, Q1, 'b', z, Q2, 'g', z, Q3, 'r');
  
  axis([z(1) z(S) min( [min(QQQ), min(Q1),  min(Q2), min(Q3)] ) ...
                  max( [max(QQQ), max(Q1),  max(Q2), max(Q3)] ) ]);

  if iteration==0
    xlabel('Angle');
    ylabel('Q-Value');
    legend('policy', 'action 1', 'action 2', 'action 3', 0);
  else
    title(['Qvalue (' num2str(iteration) ')']);
  end
  
  drawnow;
  
  return
