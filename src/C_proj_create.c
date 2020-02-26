#include <R.h>
#include <Rinternals.h>

#ifdef HAVE_PROJ6_API
#include <proj.h>
#endif

SEXP PROJ_proj_create(SEXP crs_, SEXP format)
{
  // unpack the input string
  const char*  crs_in[] = {CHAR(STRING_ELT(crs_, 0))};

  //unused flag
  int success = 0L;
  // output string assigned by proj_as_*() below
  const char  *outstring = {""};

  // which format to output
  int fmt;
  fmt = Rf_asInteger(format);

// there is no else
#ifdef HAVE_PROJ6_API
  PJ *pj;
  if (!(pj =   proj_create(0, *crs_in)))
    error(proj_errno_string(proj_errno(0)));
  if (fmt == 0L) {
    // available types
    // PJ_WKT1_ESRI, PJ_WKT1_GDAL, PJ_WKT2_2015, PJ_WKT2_2015_SIMPLIFIED, PJ_WKT2_2018, PJ_WKT2_2018_SIMPLIFIED;
    outstring = proj_as_wkt(0, pj, PJ_WKT2_2018, NULL);
    success = 1L;
  }
  if (fmt == 1L) {
    //PJ_PROJ_4, PJ_PROJ_5;
    outstring = proj_as_proj_string(0, pj, PJ_PROJ_5, NULL);
    success = 1L;
  }
 // if (fmt ==  2L) {
    // disabled for now 2010-02-26
    //outstring = proj_as_projjson(0, pj, NULL);
//    success = 0L;
//  }

  proj_destroy(pj);
#endif

  // form output as a character vector
  SEXP out = PROTECT(allocVector(STRSXP, 1));
  SET_STRING_ELT(out, 0, mkChar(outstring));
  UNPROTECT(1);
  return(out);
}
