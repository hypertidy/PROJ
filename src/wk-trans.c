#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>
#include <proj.h>
#include "wk-v1.h"

typedef struct {
  PJ* pj;
} proj_trans_t;

static int transform(R_xlen_t feature_id, const double* xyzm_in, double* xyzm_out,
                     void* trans_data) {
  proj_trans_t* data = (proj_trans_t*)trans_data;

  PJ_COORD coord_in = proj_coord(xyzm_in[0], xyzm_in[1], xyzm_in[2], xyzm_in[3]);
  PJ_COORD coord_out = proj_trans(data->pj, PJ_FWD, coord_in);
  // FIXME: handle error
  memcpy(xyzm_out, coord_out.v, 4 * sizeof(double));

  return WK_CONTINUE;
}

static void finalize(void* trans_data) {
  if (trans_data == NULL) return;

  proj_trans_t* data = (proj_trans_t*)trans_data;
  proj_destroy(data->pj);
  free(data);
}

static void ctx_xptr_destroy(SEXP ctx_xptr) {
  proj_context_destroy((PJ_CONTEXT*)R_ExternalPtrAddr(ctx_xptr));
}

#if PROJ_VERSION_MAJOR < 8
const char* proj_context_errno_string(PJ_CONTEXT*, int err) {
  // deprecated in proj 8
  return proj_errno_string(err);
}
#endif

static const char* stop_proj_error(PJ_CONTEXT* ctx) {
  int err = proj_context_errno(ctx);
  const char* msg = proj_context_errno_string(ctx, err);

  Rf_error("%s", msg);
}

SEXP C_proj_trans_new(SEXP source_crs, SEXP target_crs, SEXP use_z, SEXP use_m) {
  wk_trans_t* trans = wk_trans_create();

  trans->trans = &transform;
  trans->finalizer = &finalize;
  trans->use_z = LOGICAL_RO(use_z)[0];
  trans->use_m = LOGICAL_RO(use_m)[0];

  proj_trans_t* data = (proj_trans_t*)calloc(1, sizeof(proj_trans_t));
  if (data == NULL) {
    free(trans);
    Rf_error("Can't allocate proj_trans_t");
  }

  trans->trans_data = data;

  PJ_CONTEXT* ctx = proj_context_create();
  // ensure context is finalised
  SEXP ctx_xptr = PROTECT(R_MakeExternalPtr(ctx, R_NilValue, R_NilValue));
  R_RegisterCFinalizer(ctx_xptr, &ctx_xptr_destroy);

  PJ* pj = proj_create_crs_to_crs(ctx, CHAR(STRING_ELT(source_crs, 0)),
                                  CHAR(STRING_ELT(target_crs, 0)), NULL);
  if (pj == NULL) {
    wk_trans_destroy(trans);
    stop_proj_error(ctx);
  }

  // always lon,lat
  data->pj = proj_normalize_for_visualization(ctx, pj);
  proj_destroy(pj);
  if (data->pj == NULL) {
    wk_trans_destroy(trans);
    stop_proj_error(ctx);
  }

  UNPROTECT(1);
  // ensure context stays valid
  return wk_trans_create_xptr(trans, ctx_xptr, R_NilValue);
}
