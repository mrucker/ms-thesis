function data = pendulum_test(pol, maxsteps, iteration, kernel_flag, Dic, Dic_old, para)

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
% data = pendulum_test(pol, maxsteps, iteration)
%
% Testing and plotting results about a policy ("pol"). It runs one
% episode of "maxsteps" steps at most following policy "pol". It
% returns all the samples recorded in "data". 
%
% The following figures are printed for each iteration: 
%
% Figure 5: The trajectory of state(1) / angle over time
%
% Figure 6: The trajectory of state(2) / angular velocity over time
%
% Figure 7: The trajectory(-ies) in state space
%
% Figure 8: The actions taken over time (commented out)
%
% "Iteration" is an optional argument. If provided (valid range is
% [1:12]) it creates 12 subplots in each figure and plots the data at
% the appropriate subplot according to the index "iteration". All
% figures are cleared for "iteration"==1. The previous subplots are
% held while "iteration">1.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  rows=3;
  cols=3;
  
  if nargin<3
    iteration = 0;
  else
    iteration = min(rows*cols, iteration);
  end
  
  pol.explore=0.0;
  
  init_state = pendulum_simulator;

  if kernel_flag == 1
        [data, totdrew, toturew] = k_execute(init_state, 'pendulum_simulator', ...
				     pol, maxsteps, Dic, para);
  else 
       [data, totdrew, toturew] = execute(init_state, 'pendulum_simulator', ...
				     pol, maxsteps);
  end
  
  step = 1;
  range = [1:step:length(data)];

  states = cat(1, data(range).state);
  actions = cat(1, data(range).action);
  
  
  figure(5);
  if iteration<=1, clf, end
  if iteration>0, subplot(rows,cols,iteration), end
  plot(range, states(:,1));
  axis([0 maxsteps -pi/2 +pi/2]);
  if iteration==0
    title('Angle');
    xlabel('Steps');
    ylabel('Angle');
  else
    title(['Angle (' num2str(iteration) ')']);
  end
  drawnow;
  
  figure(6);
  if iteration<=1, clf, end
  if iteration>0, subplot(rows,cols,iteration), end
  plot(range, states(:,2));
  axis([0 maxsteps -3 +3]);
  if iteration==0
    title('Angular Velocity');
    xlabel('Steps');
    ylabel('Angular Velocity');
  else
    title(['Angular Velocity (' num2str(iteration) ')']);
  end
  drawnow;

  figure(7);
  if iteration<=1, clf, end
  if iteration>0, subplot(rows,cols,iteration), end
  plot(states(:,1), states(:,2));
  axis([-pi/2 pi/2 -2 2]);
  if iteration==0
      title('Trajectory');
      xlabel('Angle');
      ylabel('Angular Velocity');
  else
      title(['Trajectory (' num2str(iteration) ')']);
  end
  rectangle('Position', [-0.05 -0.05 0.1 0.1], 'Curvature', [1 1]);
  drawnow;
  
  
  %figure(8);
  %if iteration==1, clf, end
  %if iteration>0, subplot(rows,cols,iteration), end
  %plot(range, actions,'.');
  %axis([0 maxsteps 0.5 3.5]);
  %if iteration==0
  %  title('Actions');
  %  xlabel('Steps');
  %  ylabel('Actions');
  %else
  %  title(['Actions (' num2str(iteration) ')']);
  %end
  %drawnow;
  
  
  return;
