#include <R.h>
#include <Rinternals.h>

#ifdef HAVE_PROJ6_API
#include <proj.h>
#endif

void PROJ_version(char **version) {
#ifdef PROJ_VERSION_MAJOR
  Rprintf("%i", PROJ_VERSION_MAJOR);
  Rprintf("%i", PROJ_VERSION_MINOR);
  Rprintf("%i", PROJ_VERSION_PATCH);
#endif

#ifdef PJ_VERSION
  Rprintf("%s", PJ_VERSION);
#endif
}
