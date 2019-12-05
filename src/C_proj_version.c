#include <R.h>
#include <Rinternals.h>
#include <proj.h>


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
