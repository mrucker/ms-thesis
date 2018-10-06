function action = pendulum_handcoded_control(pol, state)

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
% A handcoded controller. Returns an action for each state.
%
% The input pol is ignored; it is used only for compatibility with the
% policy_function interface.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 

  if sign(state(1)) == sign(state(2))
    
    if sign(state(1))>0
      action = 3;
    else
      action = 1;
    end
    
  else
    action = 2;
  end
