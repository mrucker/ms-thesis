function pendulum_print_info(all_policies, kernel_flag, Dic, Dic_old, para)
  
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
% pendulum_print_info(all_policies)
%
% Calls several functions to compute/display info about the last policy
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
  

  %pendulum_plotval(all_policies{last}, 0.1, 0, last-1);
  %pendulum_plotval23d(all_policies{last}, 0.1, 0.3, 0, last-1);
  %pendulum_plotpol(all_policies{last}, 0.02, 0.05, last-1);
  %pendulum_test(all_policies{last}, 1000, last-1);
  %pendulum_evalpol(all_policies{last}, 100, 1800);
  
  last = length(all_policies);
  %pendulum_plotval(all_policies{last}, 0.1, 0, last-1);
  %pendulum_plotval23d(all_policies{last}, 0.1, 0.3, 0, last-1);
  %pendulum_plotpol(all_policies{last}, 0.02, 0.05, last-1);
  pendulum_test(all_policies{last}, 12000, last-1, kernel_flag, Dic, Dic_old, para(1));
  % Uncomment to save the policies so far in the file "allpolfile"
  %save allpolfile all_policies  
  
  return
