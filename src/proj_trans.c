#include <R.h>
#include <Rdefines.h>
#include <stdio.h>

#ifdef HAVE_PROJ6_API
#include <proj.h>
#endif

SEXP PROJ_proj_trans(SEXP x_, SEXP y_, SEXP src_, SEXP tgt_)
{

  #ifdef HAVE_PROJ6_API
  PJ_CONTEXT *C;
  PJ *P;
  PJ* P_for_GIS;
  PJ_COORD a, b;
  C = proj_context_create();
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
      //z_[i] = b.xyzt.z;
      //t_[i] = b.xyzt.t;
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
#else
  return(R_NilValue);
#endif
}

