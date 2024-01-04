#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>
#include <proj.h>
#include "proj-context.h"

SEXP proj_context_xptr_create(PJ_CONTEXT* ctx) {
  SEXP ctx_xptr = PROTECT(R_MakeExternalPtr(ctx, R_NilValue, R_NilValue));
  R_RegisterCFinalizer(ctx_xptr, &proj_context_xptr_destroy);
  UNPROTECT(1);
  return ctx_xptr;
}

void proj_context_xptr_destroy(SEXP ctx_xptr) {
  if (TYPEOF(ctx_xptr) != EXTPTRSXP) {
    Rf_error("`ctx_xptr` must be an externalptr");
  }

  PJ_CONTEXT* ctx = (PJ_CONTEXT*) R_ExternalPtrAddr(ctx_xptr);
  if (ctx != NULL) proj_context_destroy(ctx);
}

#if PROJ_VERSION_MAJOR < 8
static const char* proj_context_errno_string(PJ_CONTEXT* ctx, int err) {
  // deprecated in proj 8
  return proj_errno_string(err);
}
#endif

void stop_proj_error(PJ_CONTEXT* ctx) {
  int err = proj_context_errno(ctx);
  const char* msg = proj_context_errno_string(ctx, err);

  Rf_error("%s", msg);
}

