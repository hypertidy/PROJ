
#include <libproj.h>
#include <Rinternals.h>


SEXP proj_create_text(SEXP crs_, SEXP format)
{
  // unpack the input string
  const char* crs_in = CHAR(STRING_ELT(crs_, 0));

  // output string assigned by proj_as_*() below
  const char  *outstring;

  // which format to output
  int fmt;
  fmt = Rf_asInteger(format);

  // allocate the R output
  SEXP out = PROTECT(allocVector(STRSXP, 1));

  PJ *pj = proj_create(PJ_DEFAULT_CTX, crs_in);
  if (pj == NULL) {
    Rf_error(
      "Error creating transformation: %s",
      proj_errno_string(proj_context_errno(PJ_DEFAULT_CTX))
    );
  }

  if (fmt == 0L) {
    // available types
    // PJ_WKT1_ESRI, PJ_WKT1_GDAL, PJ_WKT2_2015, PJ_WKT2_2015_SIMPLIFIED, PJ_WKT                                          2_2018, PJ_WKT2_2018_SIMPLIFIED;
    outstring = proj_as_wkt(PJ_DEFAULT_CTX, pj, PJ_WKT2_2018, NULL);
  } else if (fmt == 1L) {
    // PJ_PROJ_4, PJ_PROJ_5;
    outstring = proj_as_proj_string(PJ_DEFAULT_CTX, pj, PJ_PROJ_5, NULL);
  } else {
    proj_destroy(pj);
    Rf_error("Can't create output projection string with type %d", fmt);
  }

  // form output as a character vector *before* destroying proj object
  // The returned string is valid while the input obj parameter is valid, and
  // until a next call to proj_as_*() with the same input object.
  // https://proj.org/development/reference/functions.html#_CPPv411proj_as_wktP1                                          0PJ_CONTEXTPK2PJ11PJ_WKT_TYPEPPCKc
  SET_STRING_ELT(out, 0, Rf_mkChar(outstring));
  proj_destroy(pj);


  UNPROTECT(1);
  return out;
}
