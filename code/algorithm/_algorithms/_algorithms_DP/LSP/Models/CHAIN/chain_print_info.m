function chain_print_info(all_policies)
  
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
% chain_print_info(all_policies)
%
% Calls chainplotval to display info about the last two policies
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
  
  last = length(all_policies);
  chainplotval(all_policies{last}, all_policies{last-1}, last-1);
  
  % Uncomment to save the policies so far in the file "allpolfile"
  %save allpolfile all_policies  
  
  return
