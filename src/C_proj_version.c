#include <R.h>
#include <Rinternals.h>

#ifdef USE_PROJ6_API

#include <proj.h>

#define STR_HELPER(x) #x
#define STR(x) STR_HELPER(x)
#define PROJ_PROJ_VERSION STR(PROJ_VERSION_MAJOR) "." STR(PROJ_VERSION_MINOR) "." STR(PROJ_VERSION_PATCH)


SEXP C_proj_version(void)
{
  return Rf_mkString(PROJ_PROJ_VERSION);
}

#else

SEXP C_proj_version(void)
{
  SEXP out = PROTECT(allocVector(STRSXP, 1));
  SET_STRING_ELT(out, 0, NA_STRING);
  UNPROTECT(1);
  return out;
}

#endif
