
#include <Rinternals.h>
#include <R_ext/Rdynload.h>



/* .Call calls */
extern SEXP C_proj_trans_list(SEXP x, SEXP src_, SEXP tgt_);
extern SEXP C_proj_trans_xy(SEXP x_, SEXP y_, SEXP src_, SEXP tgt_);
extern SEXP C_proj_crs_text(SEXP crs_, SEXP format_);
extern SEXP C_proj_version(void);

static const R_CallMethodDef CallEntries[] = {
    {"C_proj_version", (DL_FUNC) &C_proj_version, 0},
    {"C_proj_trans_list",  (DL_FUNC) &C_proj_trans_list,  3},
    {"C_proj_trans_xy",  (DL_FUNC) &C_proj_trans_xy,  4},
    {"C_proj_crs_text",  (DL_FUNC) &C_proj_crs_text,  2},

    {NULL, NULL, 0}
};

void R_init_PROJ(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
