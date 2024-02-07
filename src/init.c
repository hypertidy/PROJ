#define R_NO_REMAP
#include <R.h>
#include <R_ext/Rdynload.h>
#include <Rinternals.h>
#include <stdlib.h>  // for NULL

/* .Call calls */
extern SEXP C_proj_crs_text(void *, void *);
extern SEXP C_proj_trans_create(void *, void *, void *, void *);
extern SEXP C_proj_trans_info(void *);
extern SEXP C_proj_trans_inverse(void *);
extern SEXP C_proj_version(void);
extern SEXP C_xptr_addr(void *);

static const R_CallMethodDef CallEntries[] = {
    {"C_proj_crs_text",      (DL_FUNC) &C_proj_crs_text,      2},
    {"C_proj_trans_create",  (DL_FUNC) &C_proj_trans_create,  4},
    {"C_proj_trans_info",    (DL_FUNC) &C_proj_trans_info,    1},
    {"C_proj_trans_inverse", (DL_FUNC) &C_proj_trans_inverse, 1},
    {"C_proj_version",       (DL_FUNC) &C_proj_version,       0},
    {"C_xptr_addr",          (DL_FUNC) &C_xptr_addr,          1},
    {NULL, NULL, 0}
};

void R_init_PROJ(DllInfo* dll) {
  R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
}
