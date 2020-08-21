// needed in every file that uses proj_*() functions
#include "libproj.h"

#include <Rinternals.h>

// this returns a list of 2 or 4, takes in a list of 2 or 4
// 2 == x,y
// 4 =- x,y,z,t
// If NULL returned,
//    input list not len 2 or 4 || crs_to_crs is invalid || gis-order is invalid || PROJ>=6 is not available
SEXP proj_trans_list(SEXP x, SEXP src_, SEXP tgt_)
{
  PJ_CONTEXT *C;
  PJ *P;
  PJ* P_for_GIS;
  PJ_COORD a, b;
  C = PJ_DEFAULT_CTX;

  int ncolumns = length(x);
  if (ncolumns != 2 && ncolumns != 4) {
    Rprintf("bad columns %i\n", ncolumns);
    return(R_NilValue);
  }
  //const char* Rf_translateChar(SEXP src_);
  SEXP src_copy = PROTECT(duplicate(src_));
  SEXP tgt_copy = PROTECT(duplicate(tgt_));

  SEXP x_copy = PROTECT(duplicate(VECTOR_ELT(x, 0)));
  SEXP y_copy = PROTECT(duplicate(VECTOR_ELT(x, 1)));
  SEXP z_copy, t_copy;
  if (ncolumns == 4) {
    z_copy = PROTECT(duplicate(VECTOR_ELT(x, 2)));
    t_copy = PROTECT(duplicate(VECTOR_ELT(x, 3)));
  }
  /* FIXME: could in principle be a long vector */
  int N = length(x_copy);
  int r;

  const char*  crs_in[] = {CHAR(STRING_ELT(src_copy, 0))};
  const char*  crs_out[] = {CHAR(STRING_ELT(tgt_copy, 0))};

  P = proj_create_crs_to_crs(C, *crs_in, *crs_out, NULL);
  if (0 == P) {
    Rprintf("crs to crs problem\n");
    return(R_NilValue);
  }

  P_for_GIS = proj_normalize_for_visualization(C, P);
  if( 0 == P_for_GIS )  {
    Rprintf("bad longlat order\n");
    return(R_NilValue);
  }
  proj_destroy(P);
  P = P_for_GIS;

  for (int i = 0; i < N; i++) {
    if (ncolumns == 2) {
      a = proj_coord(REAL(x_copy)[i], REAL(y_copy)[i], 0, 0);
    } else {
      a = proj_coord(REAL(x_copy)[i], REAL(y_copy)[i], REAL(z_copy)[i], REAL(t_copy)[i]);
    }
    b = proj_trans(P, PJ_FWD, a);
    REAL(x_copy)[i] = b.xyzt.x;
    REAL(y_copy)[i] = b.xyzt.y;
    if (ncolumns == 4) {
      REAL(z_copy)[i] = b.xyzt.z;
      REAL(t_copy)[i] = b.xyzt.t;
    }
  }
  r = proj_errno(P);
  proj_destroy(P);
  if (r) {
    Rprintf("Error detected, some values Inf (error code: %i)\n\n", r);
    Rprintf("' %s\n\n '", proj_errno_string(r));
  }


  SEXP vec = PROTECT(allocVector(VECSXP, ncolumns));
  SET_VECTOR_ELT(vec, 0, x_copy);
  SET_VECTOR_ELT(vec, 1, y_copy);

  int unprot;
  if (ncolumns == 2) {
    unprot = 5;
  } else {
    SET_VECTOR_ELT(vec, 2, z_copy);
    SET_VECTOR_ELT(vec, 3, t_copy);

    unprot= 7;
  }

  UNPROTECT(unprot);
  return vec;
}

SEXP proj_trans_xy(SEXP x_, SEXP y_, SEXP src_, SEXP tgt_)
{
  PJ_CONTEXT *C;
  PJ *P;
  PJ* P_for_GIS;
  PJ_COORD a, b;
  C = PJ_DEFAULT_CTX;
  /* FIXME: could in principle be a long vector */
    int N = length(x_);
    int r;

    //const char* Rf_translateChar(SEXP src_);
    SEXP src_copy = PROTECT(duplicate(src_));
    SEXP tgt_copy = PROTECT(duplicate(tgt_));
    SEXP x_copy = PROTECT(duplicate(x_));
    SEXP y_copy = PROTECT(duplicate(y_));

    const char*  crs_in[] = {CHAR(STRING_ELT(src_copy, 0))};
    const char*  crs_out[] = {CHAR(STRING_ELT(tgt_copy, 0))};

    P = proj_create_crs_to_crs(C, *crs_in, *crs_out, NULL);
    if (0 == P) {
      return(R_NilValue);
    }

    P_for_GIS = proj_normalize_for_visualization(C, P);
    if( 0 == P_for_GIS )  {
      return(R_NilValue);
    }
    proj_destroy(P);
    P = P_for_GIS;

    for (int i = 0; i < N; i++) {
      a = proj_coord(REAL(x_copy)[i], REAL(y_copy)[i], 0, 0);
      b = proj_trans(P, PJ_FWD, a);
      REAL(x_copy)[i] = b.xyzt.x;
      REAL(y_copy)[i] = b.xyzt.y;
    }
    r = proj_errno(P);
    proj_destroy(P);
    if (r) {
      Rprintf("Error detected, some values Inf (error code: %i)\n\n", r);
      Rprintf("' %s\n\n '", proj_errno_string(r));
    }

  SEXP vec = PROTECT(allocVector(VECSXP, 2));
  SET_VECTOR_ELT(vec, 0, x_copy);
  SET_VECTOR_ELT(vec, 1, y_copy);

  UNPROTECT(5);
  return vec;
}

