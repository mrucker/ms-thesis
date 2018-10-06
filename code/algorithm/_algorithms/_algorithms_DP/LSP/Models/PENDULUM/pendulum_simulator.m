function  [nexts, reward, endsim] = pendulum_simulator(state, action)

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
% [nextstate, reward, absorb] = pendulum_simulator(state, action)
%
% A simulator for the pendulum domain.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  
  persistent dt;
  persistent tol;
  persistent noise;
  persistent allu;

  if nargin<1
  
    % Initialize
  
    dt = 0.1;           % Simulation step
    tol = 1.0e-5;       % Simulation error tolerance
    noise = 10;         % Range of noise
    allu = [-50 0 +50]; % The 3 actions in Newtons
    
    nexts = [ 0 0 ];
    reward = 0;
    endsim = 0;
    
    return
    
  elseif nargin<2
    
    % Set state
    
    nexts = state/5;
    reward = 0;
    endsim = 0;
    return
    
  end
  
  u = allu(action);
  
  %u = u + (2*rand-1)*noise;    % Uniform noise
  u = u + randn * noise;       % Gaussian noise
  
  % Simulate
  
  x0 = [state(:)*5; u];
  
  % The following are equivalent but the second is a little faster
  %[t, x] = ode45_us('pendulum', 0, dt, x0, tol, 1);
  [t, x] = pendulum_ode45(0, dt, x0, tol);

  nexts = x(size(x,1), 1:2)/5;
 
  % If the pendulum is below the horizontal configuration,
  % the game is over
  % reward = - abs(x(1)/100);
  reward = 0;
  if abs(nexts(1)) > pi/2;
    reward = -1;
    endsim = 1;
  else
    reward = reward;
    endsim = 0;
  end
  
  
  %  Other possible reward schemes
  
  %  reward = (state(1)*2/pi)^2 - (nexts(1)*2/pi)^2;
  %  reward = abs(state(1)*2/pi) - abs(nexts(1)*2/pi);
  %  reward = abs(state(1)) - abs(nexts(1));
  %  reward = norm(state) - norm(nexts);
  
  
  return
  
