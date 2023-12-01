

#include <R.h>
#include <Rinternals.h>

#ifdef USE_PROJ6_API

#include <proj.h>

SEXP C_proj_crs_text(SEXP crs_, SEXP format)
{
  // unpack the input string
  const char*  crs_in[] = {CHAR(STRING_ELT(crs_, 0))};

  //unused flag
  int success;
  success = 0;
  // output string assigned by proj_as_*() below
  const char  *outstring;

  // which format to output
  int fmt;
  fmt = Rf_asInteger(format);

  // allocate the R output
  SEXP out = PROTECT(allocVector(STRSXP, 1));

  PJ *pj;
  int r;

  if (!(pj =   proj_create(PJ_DEFAULT_CTX, *crs_in))){
    r = proj_errno(pj);
    Rprintf("Error detected, fail create crs (error code: %i)\n\n", r);
    Rprintf("' %s\n\n '", proj_errno_string(r));
  }

  if (fmt == 0L) {
    // available types
    // PJ_WKT1_ESRI, PJ_WKT1_GDAL, PJ_WKT2_2015, PJ_WKT2_2015_SIMPLIFIED, PJ_WKT2_2018, PJ_WKT2_2018_SIMPLIFIED;
    outstring = proj_as_wkt(0, pj, PJ_WKT2_2019, NULL);
    success = 1L;
  }
  if (fmt == 1L) {
    //PJ_PROJ_4, PJ_PROJ_5;
    outstring = proj_as_proj_string(0, pj, PJ_PROJ_5, NULL);

    success = 1L;
  }
  if (fmt ==  2L) {
   outstring = proj_as_projjson(0, pj, NULL);
   success = 1L;
  }
  // form output as a character vector *before* destroying proj object
  // The returned string is valid while the input obj parameter is valid, and
  // until a next call to proj_as_*() with the same input object.
  // https://proj.org/development/reference/functions.html#_CPPv411proj_as_wktP1                                          0PJ_CONTEXTPK2PJ11PJ_WKT_TYPEPPCKc

  if (!success) {
    SET_STRING_ELT(out, 0, NA_STRING);
  } else {
    SET_STRING_ELT(out, 0, mkChar(outstring));
  }

  proj_destroy(pj);

  UNPROTECT(1);

  return(out);
}


#else

SEXP C_proj_crs_text(SEXP crs_, SEXP format)
{
 SEXP out = PROTECT(allocVector(STRSXP, 1));
 SET_STRING_ELT(out, 0, NA_STRING);
 UNPROTECT(1);
 return out;
}

#endif
