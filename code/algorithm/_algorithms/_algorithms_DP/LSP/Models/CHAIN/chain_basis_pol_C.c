#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <sys/types.h>
#include <limits.h>
#include <signal.h>
#include <sys/times.h>
#include <sys/time.h>
#include <errno.h>


#define degpol 4
#define KK (degpol+1)
#define chain_actions 2
#define chain_states 20
#define numbasis (KK * chain_actions)


double sign(double x)
{
  if (x==0.0)
    return 0.0;
  else if (x>0.0)
    return +1.0;
  else 
    return -1.0;
}


void chainphi_pol(double *phi, double *state, double *action, int what)
{
  int base;
  int i;
  
  if (what==0) {
    *phi = (double) numbasis; 
    return;
  }

  for (i=0; i<numbasis; i++)
    phi[i]=0.0;
  
  if ( (*state < 1) || (*state > chain_states) )
    return;
  
  base = (numbasis / chain_actions) * ( ((int) *action) - 1 ); 

  phi[base] = 1.0;

  for (i=1; i<KK; i++)
    phi[base+i] = phi[base+i-1] * 10.0*(*state/chain_states);

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
  chainphi_pol(phi, state, action, nrhs);    

  return;
    
}


