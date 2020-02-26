#ifdef HAVE_PROJ6_API
#include <proj.h>
#endif

#include <R.h>
#include <Rinternals.h>

SEXP PROJ_set_data_dir(SEXP data_dir){
#ifdef HAVE_PROJ6_API
   const char* stra = CHAR(STRING_ELT(data_dir, 0));
   const char*  paths[] = {stra};
  proj_context_set_search_paths(PJ_DEFAULT_CTX, 1, paths);
#else
  Rf_error("Version of proj too old for proj_context_set_search_paths");
#endif
 return data_dir;
}
