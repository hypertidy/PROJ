
#ifndef HAVE_PROJ6_API

#include <Rinternals.h>

SEXP PROJ_proj_create(SEXP a, SEXP b) {
  REprintf("Version of proj too old (need >=6.1.0)");
  SEXP out = PROTECT(Rf_allocVector(STRSXP, 1));
  SET_STRING_ELT(out, 1, NA_STRING);
  UNPROTECT(1);
  return out;
}

SEXP PROJ_proj_set_data_dir(SEXP a) {
  Rf_error("Version of proj too old (need >=6.1.0)");
}

SEXP PROJ_proj_trans_xy(SEXP a, SEXP b, SEXP c, SEXP d) {
  REprintf("Version of proj too old (need >=6.1.0)");
  return R_NilValue;
}

SEXP PROJ_proj_trans_list(SEXP a, SEXP b, SEXP c) {
  REprintf("Version of proj too old (need >=6.1.0)");
  return R_NilValue;
}

#endif
