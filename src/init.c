#include <R.h>
#include <Rinternals.h>
#include <stdlib.h> // for NULL
#include <R_ext/Rdynload.h>

/* FIXME: 
   Check these declarations against the C/Fortran source code.
*/

/* .Call calls */
extern SEXP _PROJ_proj_trans_cpp(SEXP, SEXP, SEXP, SEXP, SEXP);
extern SEXP R_proj_trans_FWD(SEXP, SEXP, SEXP, SEXP);

static const R_CallMethodDef CallEntries[] = {
    {"_PROJ_proj_trans_cpp", (DL_FUNC) &_PROJ_proj_trans_cpp, 5},
    {"R_proj_trans_FWD",     (DL_FUNC) &R_proj_trans_FWD,     4},
    {NULL, NULL, 0}
};

void R_init_PROJ(DllInfo *dll)
{
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
