#include <proj.h>
#include <R.h>
#include <Rinternals.h>

SEXP PROJ_set_data_dir(SEXP data_dir){
#if PROJ_VERSION_MAJOR >= 6
  //const char* str = CHAR(STRING_ELT(data_dir, 0));
  //const char* const* a = {"b"};
  const char* const paths[] = {CHAR(STRING_ELT(data_dir, 0))};
  proj_context_set_search_paths(PJ_DEFAULT_CTX, 1, paths);
#else
  Rf_error("Version of proj too old for proj_context_set_search_paths");
#endif
 return data_dir;
}
