/*
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
% A C implementation of the RBF basis functions for the pendulum
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <sys/types.h>
#include <limits.h>
#include <signal.h>
#include <sys/times.h>
#include <sys/time.h>
#include <errno.h>


#define sqr(x)   ((x)*(x))

#define pend_actions 3

#define nrbfx 3
#define nrbfy 3
#define numbasis ( (nrbfx*nrbfy+1) * pend_actions )

#define mypi         (acos(-1))




void pendphi_rbf(double *phi, double *state, double *action, int what)
{
  int base;
  int i;
  double sigma2, x, y, dist;

  if (what==0) {
    *phi = (double) numbasis; 
    return;
  }

  for (i=0; i<numbasis; i++)
    phi[i]=0.0;

  if ( fabs(state[0]) > (mypi/2.0) )
      return;

  base = (numbasis / pend_actions) * ( ((int) *action) - 1 ); 


  phi[base++] = 1.0;

  sigma2 = 1;

  for (x=-mypi/4.0; x<=mypi/4.0; x+=mypi/4.0)
    for (y=-1; y<=1; y+=1) {
      dist = sqr(state[0]-x) + sqr(state[1]-y);
      phi[base++] = exp( -dist / (2*sigma2) );
    }

  return;
}




#include "mex.h"

void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray *prhs[] )
{ 
  
  double *phi;
  double *state;
  double *action;

  
  /* Check for proper number of arguments. */
  if ( (nrhs>2) || (nrhs==1) ) {
    mexErrMsgTxt("Incorrect number of inputs!.");
  } 
  else if (nlhs>1) {
    mexErrMsgTxt("Too many output arguments!");
  }
  
  /* Create a matrix for the return argument */ 
  if (nrhs>0)
    plhs[0] = mxCreateDoubleMatrix(numbasis, 1, mxREAL);
  else 
    plhs[0] = mxCreateDoubleMatrix(1, 1, mxREAL); 


  /* Assign pointers to the various parameters */ 
  phi  = mxGetPr(plhs[0]);
  
  if (nrhs>0) {
    state  = mxGetPr(prhs[0]);
    action = mxGetPr(prhs[1]);
  }
  
  
  /* Do the actual computations in a subroutine */
  pendphi_rbf(phi, state, action, nrhs);  


  return;
    
}


