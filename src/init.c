
#include <R.h>
#include <Rinternals.h>
#include <stdlib.h> // for NULL
#include <R_ext/Rdynload.h>

  /* .Call calls */
 extern SEXP PROJ_set_data_dir(SEXP);
 extern SEXP PROJ_proj_trans_generic(SEXP, SEXP, SEXP, SEXP, SEXP, SEXP, SEXP, SEXP);

  static const R_CallMethodDef CallEntries[] = {
    {"PROJ_set_data_dir", (DL_FUNC) &PROJ_set_data_dir, 1},
    {"PROJ_proj_trans_generic", (DL_FUNC) &PROJ_proj_trans_generic, 8},

    {NULL, NULL, 0}
  };

  void R_init_PROJ(DllInfo *dll)
  {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
  }
