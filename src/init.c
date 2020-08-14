
#include <Rinternals.h>
#include <R_ext/Rdynload.h>

/* .Call calls */
extern SEXP PROJ_proj_create(SEXP, SEXP);
extern SEXP PROJ_proj_set_data_dir(SEXP);
extern SEXP PROJ_proj_trans_xy(SEXP, SEXP, SEXP, SEXP);
extern SEXP PROJ_proj_trans_list(SEXP, SEXP, SEXP);

static const R_CallMethodDef CallEntries[] = {
    {"PROJ_proj_create",  (DL_FUNC) &PROJ_proj_create,  2},
    {"PROJ_proj_set_data_dir", (DL_FUNC) &PROJ_proj_set_data_dir, 1},
    {"PROJ_proj_trans_xy",           (DL_FUNC) &PROJ_proj_trans_xy, 4},
    {"PROJ_proj_trans_list",           (DL_FUNC) &PROJ_proj_trans_list, 3},
    {NULL, NULL, 0}
};

void R_init_PROJ(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
