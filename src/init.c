#include <stdlib.h> // for NULL
#include <R_ext/Rdynload.h>

/* FIXME: 
   Check these declarations against the C/Fortran source code.
*/

/* .C calls */
extern void PROJ_proj_trans_generic(void *, void *, void *, void *, void *, void *, void *, void *);
extern void PROJ_set_data_dir(void *);

static const R_CMethodDef CEntries[] = {
    {"PROJ_proj_trans_generic", (DL_FUNC) &PROJ_proj_trans_generic, 8},
    {"PROJ_set_data_dir",       (DL_FUNC) &PROJ_set_data_dir,       1},
    {NULL, NULL, 0}
};

void R_init_PROJ(DllInfo *dll)
{
    R_registerRoutines(dll, CEntries, NULL, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
