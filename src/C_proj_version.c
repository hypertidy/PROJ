#include <proj.h>


#include <R.h>
#include <Rinternals.h>

#define STR_HELPER(x) #x
#define STR(x) STR_HELPER(x)
#define PROJ_PROJ_VERSION STR(PROJ_VERSION_MAJOR) "." STR(PROJ_VERSION_MINOR) "." STR(PROJ_VERSION_PATCH)


SEXP C_proj_version()
{
  return Rf_mkString(PROJ_PROJ_VERSION);
}
