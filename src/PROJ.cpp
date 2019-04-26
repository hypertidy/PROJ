#include <Rcpp.h>
using namespace Rcpp;

#include "proj.h"

// [[Rcpp::export]]
List proj_trans_cpp(
                        Rcpp::CharacterVector TARGET,
                        Rcpp::DoubleVector X,
                        Rcpp::DoubleVector Y,
                        Rcpp::DoubleVector Z,
                        Rcpp::LogicalVector INV) {

  PJ_CONTEXT *C;
  PJ *P;
  PJ_COORD a, b;

  /* or you may set C=PJ_DEFAULT_CTX if you are sure you will     */
  /* use PJ objects from only one thread                          */
  C = proj_context_create();
  P = proj_create (C, TARGET[0]);
  if (0==P) Rcpp::stop("oops\n");

  int n = X.length();
  NumericVector bx(n);
  NumericVector by(n);
  NumericVector bz(n);

  for (int i = 0; i < n; i++) {
  if (!INV[0]) {
   /* note: PROJ.4 works in radians, hence the proj_torad() calls */
   a = proj_coord (proj_torad(X[i]), proj_torad(Y[i]), Z[i], 0);
   /* transform to target */
   b = proj_trans (P, PJ_FWD, a);
   bx[i] = b.enu.e;
   by[i] = b.enu.n;
   bz[i] = b.enu.u;

  } else {
   a = proj_coord (X[i], Y[i], Z[i], 0);
   b = proj_trans (P, PJ_INV, a);

   bx[i] = proj_todeg( b.lp.lam);
   by[i] = proj_todeg(b.lp.phi);
  }
  }
  /* Clean up */
  proj_destroy (P);
  proj_context_destroy (C); /* may be omitted in the single threaded case */

  Rcpp::List out(3);
  CharacterVector outnames(3);
  outnames[0] = "X";
  outnames[1] = "Y";
  outnames[2] = "Z";
  out.attr("names") = outnames;

  out[0] = bx;
  out[1] = by;
  out[2] = bz;
  return out;
}


// old api proj_api.h
// NumericVector proj_test(Rcpp::CharacterVector SOURCE,
//               Rcpp::CharacterVector TARGET,
//               Rcpp::DoubleVector X,
//               Rcpp::DoubleVector Y,
//               Rcpp::DoubleVector Z) {
//     projPJ ps, pd;
//     int r;
//     int n = X.length();
//     ps = pj_init_plus(SOURCE[0]);
//     pd = pj_init_plus(TARGET[0]);
//     // FIXME error handling
// //   if (!(ps = pj_init_plus(*psrc)))
// //      error(pj_strerrno(*pj_get_errno_ref()));
// //    if (!(pd = pj_init_plus(*pdst))) {
// //      pj_free(ps);
// //      error(pj_strerrno(*pj_get_errno_ref()));
// //    }
//   double x[n];
//   double y[n];
//   double z[n];
//   for (int i = 0; i < n; i++){
//    x[i] = X[i];
//    y[i] = Y[i];
//    z[i] = Z[i];
//  }
//  r = pj_transform(ps, pd, n, 0, x, y, z);
//  // proj_trans_generic(  );
//  //
//  pj_free(ps);
//  pj_free(pd);
//  //
//  //    if (r) {
//  //    //      error(pj_strerrno(*pj_get_errno_ref()));
//  //    }
//  NumericVector out(3);
//  out[0] = x[0];
//  out[1] = y[0];
//  out[2] = z[0];
//
//  return out;
// }

