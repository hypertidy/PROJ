#include "libproj.h"

#include <Rinternals.h>
#include <R_ext/Rdynload.h>


SEXP libproj_c_init() {
    // load functions into the (currently NULL) function pointers in libgeos-impl.c
    libproj_init_api();

    return R_NilValue;
}

/* .Call calls */
extern SEXP libproj_c_init();
extern SEXP proj_trans_list(SEXP x, SEXP src_, SEXP tgt_);
extern SEXP proj_trans_xy(SEXP x_, SEXP y_, SEXP src_, SEXP tgt_);
extern SEXP proj_create_text(SEXP crs_, SEXP format_);
static const R_CallMethodDef CallEntries[] = {
    {"libproj_c_init",  (DL_FUNC) &libproj_c_init,  0},
    {"proj_trans_list",  (DL_FUNC) &proj_trans_list,  3},
    {"proj_trans_xy",  (DL_FUNC) &proj_trans_xy,  4},
    {"proj_create_text",  (DL_FUNC) &proj_create_text,  2},

    {NULL, NULL, 0}
};

void R_init_PROJ(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
