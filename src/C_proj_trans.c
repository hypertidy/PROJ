// needed in every file that uses proj_*() functions
//#include "libproj.h"

#include <Rinternals.h>

// this returns a list of 2 or 4, takes in a list of 2 or 4
// 2 == x,y
// 4 =- x,y,z,t
// If NULL returned,
//    input list not len 2 or 4 || crs_to_crs is invalid || gis-order is invalid || PROJ>=6 is not available
SEXP proj_trans_list(SEXP x, SEXP src_, SEXP tgt_)
{
  return(R_NilValue);
}

SEXP proj_trans_xy(SEXP x_, SEXP y_, SEXP src_, SEXP tgt_)
{
  return(R_NilValue);
}

