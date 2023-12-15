#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>
#include <proj.h>
#include "wk-v1.h"

typedef struct {
  PJ_CONTEXT* ctx;
  PJ* proj;
} proj_trans_t;

int transform(R_xlen_t feature_id, const double* xyzm_in, double* xyzm_out,
              void* trans_data) {
  proj_trans_t* data = (proj_trans_t*)trans_data;

  PJ_COORD coord_in = proj_coord(xyzm_in[0], xyzm_in[1], xyzm_in[2], xyzm_in[3]);
  PJ_COORD coord_out = proj_trans(data->proj, PJ_FWD, coord_in);
  // FIXME: handle error
  memcpy(xyzm_out, coord_out.v, 4 * sizeof(double));

  return WK_CONTINUE;
}

void finalize(void* trans_data) {
  proj_trans_t* data = (proj_trans_t*)trans_data;
  proj_destroy(data->proj);
  proj_context_destroy(data->ctx);
  free(data);
}

#if PROJ_VERSION_MAJOR < 8
const char* proj_context_errno_string(PJ_CONTEXT*, int err) {
  // deprecated in proj 8
  return proj_errno_string(err);
}
#endif

const char* stop_proj_error(PJ_CONTEXT* ctx) {
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

  proj_trans_t* data = (proj_trans_t*)malloc(sizeof(proj_trans_t));
  if (data == NULL) {
    free(trans);
    Rf_error("Can't allocate proj_trans_t");
  }

  data->ctx = proj_context_create();
  PJ* pj = proj_create_crs_to_crs(data->ctx, CHAR(STRING_ELT(source_crs, 0)),
                                  CHAR(STRING_ELT(target_crs, 0)), NULL);
  if (pj == NULL) {
    stop_proj_error(data->ctx);
  }

  // always lon,lat
  data->proj = proj_normalize_for_visualization(data->ctx, pj);
  if (data->proj == NULL) {
    stop_proj_error(data->ctx);
  }

  proj_destroy(pj);
  trans->trans_data = data;

  return wk_trans_create_xptr(trans, R_NilValue, R_NilValue);
}
