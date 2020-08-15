
#ifdef HAVE_PROJ6_API
#include <proj.h>
#include <Rinternals.h>

SEXP PROJ_proj_set_data_dir(SEXP data_dir){
  const char* stra = CHAR(STRING_ELT(data_dir, 0));
  const char*  paths[] = {stra};
  proj_context_set_search_paths(PJ_DEFAULT_CTX, 1, paths);
  return data_dir;
}

#endif
