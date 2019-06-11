#include <R.h>
#include <Rinternals.h>
#include "Rcpp.h"

#include <proj.h>

//' R_proj_trans_base
//' @param src_ PROJ string
//' @param tgt_ PROJ string
//' @param x_ x coordinate
//' @param y_ y coordinate
//' @param z_ z coordinate
//' @param t_ t coordinate
//' @noRd
SEXP R_proj_trans_INV (SEXP src_, SEXP tgt_, SEXP x_, SEXP y_, SEXP z_, SEXP t_)
{
 const char* src_crs = CHAR(asChar(src_));
 const char* tgt_crs = CHAR(asChar(tgt_));

//x_, y_, z_, t_  must be all same length
//size_t n = length(x_);

//proj_context_use_proj4_init_rules(PJ_DEFAULT_CTX, 1);
PJ *PP = proj_create_crs_to_crs(PJ_DEFAULT_CTX, src_crs, tgt_crs, NULL);
if (PP == NULL) {
  //how to error?
}

  std::vector<PJ_COORD> xd(1);
  xd.data()[0].lp.lam = 0.0;
  xd.data()[0].lp.phi = 0.0;


const char *names[] = {"X", "Y", "Z", ""};                   /* note the null string */
SEXP res = PROTECT(mkNamed(VECSXP, names));  /* list of length 3 */

return res;

}
