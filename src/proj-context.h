#include <R.h>
#include <Rinternals.h>
#include <proj.h>

SEXP proj_context_xptr_create(PJ_CONTEXT* ctx);
void proj_context_xptr_destroy(SEXP ctx_xptr);
void stop_proj_error(PJ_CONTEXT* ctx);
