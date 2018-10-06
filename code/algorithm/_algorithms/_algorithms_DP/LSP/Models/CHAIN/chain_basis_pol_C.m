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
% phi = chain_basis_pol_C(state, action)
%
% Computes a set of polynomial (on "state") basis functions (up to a
% certain degree). The set is duplicated for each action. The "action"
% determines which segment will be active.
%
% This is a C implementation of the chain_basis_pol.m function that
% runs much faster.
%
% WARNING: chainsactions, chainstates, and the degree of the
% polynomial are hardwired as constants in the C code. You have to
% update and compile the function every time a change to these is
% made.
%
% Compilation
%
% At the MATLAB prompt issue: 
%
%    >> mex chain_basis_pol_C.c 
%
% and ignore the warnings. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  
