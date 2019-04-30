#include <R.h>
#include <Rinternals.h>

#include <proj.h>

//' R_proj_trans_base
//' @param s_ PROJ string
//' @param x_ x coordinate
//' @param y_ y coordinate
//' @param z_ z coordinate
//' @noRd
SEXP R_proj_trans_INV (SEXP s_, SEXP x_, SEXP y_, SEXP z_)
{
  PJ_CONTEXT *C;
  PJ *P;
  PJ_COORD a, b;
  size_t n = length (x_);
  /* or you may set C=PJ_DEFAULT_CTX if you are sure you will     */
  /* use PJ objects from only one thread                          */
  C = proj_context_create();
  double *rx, *ry, *rz;
  rx = REAL (x_);
  ry = REAL (y_);
  rz = REAL (z_);
  SEXP bx = PROTECT (allocVector (REALSXP, n));
  SEXP by = PROTECT (allocVector (REALSXP, n));
  SEXP bz = PROTECT (allocVector (REALSXP, n));
  double *xout, *yout, *zout;
  xout = REAL (bx);
  yout = REAL (by);
  zout = REAL (bz);

  const char* crs = CHAR(asChar(s_));
  P = proj_create (C, crs);
  //if (0==P) Rcpp::stop("Failed to create CRS from TARGET\n");
  for (int i = 0; i < n; i++) {
    if (i % 100 == 0)
      R_CheckUserInterrupt ();
    a = proj_coord (rx[i], ry[i], rz[i], 0);
    /* transform to target */
    b = proj_trans (P, PJ_INV, a);
    xout[i] = proj_todeg(b.lpz.lam);
    yout[i] = proj_todeg(b.lpz.phi);
    zout[i] = b.lpz.z;
  }
  /* Clean up */
  proj_destroy (P);
  proj_context_destroy (C); /* may be omitted in the single threaded case */


  const char *names[] = {"X", "Y", "Z", ""};                   /* note the null string */
  SEXP res = PROTECT(mkNamed(VECSXP, names));  /* list of length 3 */
  SET_VECTOR_ELT(res, 0, bx);
  SET_VECTOR_ELT(res, 1, by);
  SET_VECTOR_ELT(res, 2, bz);


  UNPROTECT(4);
  return res;
}


//' R_proj_trans_base
//' @param s_ PROJ string
//' @param x_ x coordinate
//' @param y_ y coordinate
//' @param z_ z coordinate
//' @noRd
SEXP R_proj_trans_FWD (SEXP s_, SEXP x_, SEXP y_, SEXP z_)
{
  PJ_CONTEXT *C;
  PJ *P;
  PJ_COORD a, b;
  size_t n = length (x_);
  /* or you may set C=PJ_DEFAULT_CTX if you are sure you will     */
  /* use PJ objects from only one thread                          */
  C = proj_context_create();
  double *rx, *ry, *rz;
  rx = REAL (x_);
  ry = REAL (y_);
  rz = REAL (z_);
  SEXP bx = PROTECT (allocVector (REALSXP, n));
  SEXP by = PROTECT (allocVector (REALSXP, n));
  SEXP bz = PROTECT (allocVector (REALSXP, n));
  double *xout, *yout, *zout;
  xout = REAL (bx);
  yout = REAL (by);
  zout = REAL (bz);

  const char* crs = CHAR(asChar(s_));
  P = proj_create (C, crs);
  //if (0==P) Rcpp::stop("Failed to create CRS from TARGET\n");
  for (int i = 0; i < n; i++) {
    if (i % 100 == 0)
      R_CheckUserInterrupt ();
    /* note: PROJ.4 works in radians, hence the proj_torad() calls */
    a = proj_coord (proj_torad(rx[i]), proj_torad(ry[i]), rz[i], 0);
    /* transform to target */
    b = proj_trans (P, PJ_FWD, a);
    xout[i] = b.enu.e;
    yout[i] = b.enu.n;
    zout[i] = b.enu.u;
  }
  /* Clean up */
  proj_destroy (P);
  proj_context_destroy (C); /* may be omitted in the single threaded case */


  const char *names[] = {"X", "Y", "Z", ""};                   /* note the null string */
  SEXP res = PROTECT(mkNamed(VECSXP, names));  /* list of length 3 */
  SET_VECTOR_ELT(res, 0, bx);
  SET_VECTOR_ELT(res, 1, by);
  SET_VECTOR_ELT(res, 2, bz);


  UNPROTECT(4);
  return res;
}
