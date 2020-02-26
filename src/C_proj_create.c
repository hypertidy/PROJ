#include <R.h>
#include <Rinternals.h>

#ifdef HAVE_PROJ6_API
#include <proj.h>
#endif

SEXP PROJ_proj_create(SEXP crs_, SEXP format)
{

  SEXP crs_sxp;
  PROTECT(crs_sxp = STRING_ELT(crs_, 0));
  UNPROTECT(1);
  const char*  crs_a = CHAR(crs_sxp);
  const char*  crs_in[] = {crs_a};

  int success = 0L;
#ifdef HAVE_PROJ6_API
  PJ *pj;

  if (!(pj =   proj_create(0, *crs_in)))
    error(proj_errno_string(proj_errno(0)));

  const char  *outstring = {"dummy"};
  int fmt;
  fmt = Rf_asInteger(format);
  if (fmt == 0L) {
    Rprintf("WKT2\n");
  //proj_as_wkt();
  //  PJ_WKT1_ESRI;
  //  PJ_WKT1_GDAL;
  //  PJ_WKT2_2015;
  //  PJ_WKT2_2015_SIMPLIFIED;
  //  PJ_WKT2_2018;
  //  PJ_WKT2_2018_SIMPLIFIED;
    outstring = proj_as_wkt(0, pj, PJ_WKT2_2018, NULL);
    success = 1L;

  }
  if (fmt == 1L) {
    Rprintf("PROJ\n");
    //PJ_PROJ_4;
    //PJ_PROJ_5;
    outstring = proj_as_proj_string(0, pj, PJ_PROJ_5, NULL);
    success = 1L;

  }
  if (fmt ==  2L) {
    Rprintf("PROJJSON\n");
   outstring = proj_as_projjson(0, pj, NULL);
   success = 1L;

  }

//  if (success[0] == 0) {
//    SEXP bad = PROTECT(allocVector(STRSXP, 1));
//    SET_STRING_ELT(bad, 0, NA_STRING);
//    UNPROTECT(1);
//    return(bad);
//  }
#else

 success = 0L;

#endif
 SEXP out = PROTECT(allocVector(STRSXP, 1));
 SET_STRING_ELT(out, 0, mkChar(outstring));
 UNPROTECT(1);

return(out);
}
