#include <R.h>
#include <Rinternals.h>
#include <stdlib.h> // for NULL
#include <R_ext/Rdynload.h>

/* FIXME:
   Check these declarations against the C/Fortran source code.
*/

/* .C calls */
extern void PROJ_proj_trans_generic(void *, void *, void *, void *, void *, void *, void *, void *);

/* .Call calls */
extern SEXP PROJ_proj_create(SEXP, SEXP);
extern SEXP PROJ_set_data_dir(SEXP);
extern SEXP PROJ_proj_trans_xy(SEXP, SEXP, SEXP, SEXP);
static const R_CMethodDef CEntries[] = {
    {"PROJ_proj_trans_generic", (DL_FUNC) &PROJ_proj_trans_generic, 8},
    {NULL, NULL, 0}
};

static const R_CallMethodDef CallEntries[] = {
    {"PROJ_proj_create",  (DL_FUNC) &PROJ_proj_create,  2},
    {"PROJ_set_data_dir", (DL_FUNC) &PROJ_set_data_dir, 1},
    {"PROJ_proj_trans_xy",           (DL_FUNC) &PROJ_proj_trans_xy, 4},
    {NULL, NULL, 0}
};

void R_init_PROJ(DllInfo *dll)
{
    R_registerRoutines(dll, CEntries, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
