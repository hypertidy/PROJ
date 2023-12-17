#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>
#include <proj.h>
#include <stdio.h>
#include "wk-v1.h"
#include "proj-context.h"

typedef struct {
  PJ* pj;
  PJ* pj_norm;
} proj_trans_t;

static int transform(R_xlen_t feature_id, const double* xyzm_in, double* xyzm_out,
                     void* trans_data) {
  proj_trans_t* data = (proj_trans_t*)trans_data;

  PJ_COORD coord_in = proj_coord(xyzm_in[0], xyzm_in[1], xyzm_in[2], xyzm_in[3]);
  PJ_COORD coord_out = proj_trans(data->pj_norm, PJ_FWD, coord_in);
  // FIXME: handle error
  memcpy(xyzm_out, coord_out.v, 4 * sizeof(double));

  return WK_CONTINUE;
}

static void finalize(void* trans_data) {
  if (trans_data == NULL) return;

  proj_trans_t* data = (proj_trans_t*)trans_data;
  if (data->pj != NULL) proj_destroy(data->pj);
  if (data->pj_norm != NULL) proj_destroy(data->pj_norm);
  free(data);
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
  SEXP ctx_xptr = PROTECT(proj_context_xptr_create(ctx));
  // ensure context stays valid
  SEXP trans_xptr = PROTECT(wk_trans_create_xptr(trans, ctx_xptr, R_NilValue));

  data->pj =
      proj_create_crs_to_crs(ctx, Rf_translateCharUTF8(STRING_ELT(source_crs, 0)),
                             Rf_translateCharUTF8(STRING_ELT(target_crs, 0)), NULL);
  if (data->pj == NULL) {
    stop_proj_error(ctx);
  }

  // always lon,lat
  data->pj_norm = proj_normalize_for_visualization(ctx, data->pj);
  if (data->pj_norm == NULL) {
    stop_proj_error(ctx);
  }

  // xptrs
  UNPROTECT(2);
  return trans_xptr;
}

SEXP C_proj_trans_fmt(SEXP trans_xptr) {
  if (TYPEOF(trans_xptr) != EXTPTRSXP || !Rf_inherits(trans_xptr, "proj_trans")) {
    Rf_error("`trans` must be a <proj_trans> object");
  }

  wk_trans_t* trans = (wk_trans_t*)R_ExternalPtrAddr(trans_xptr);
  PJ_CONTEXT* ctx = (PJ_CONTEXT*)R_ExternalPtrAddr(R_ExternalPtrTag(trans_xptr));
  proj_trans_t* data = (proj_trans_t*)trans->trans_data;

  PJ* source_crs = proj_get_source_crs(ctx, data->pj);
  PJ* target_crs = proj_get_target_crs(ctx, data->pj);
  if (source_crs == NULL || target_crs == NULL) {
    proj_destroy(source_crs);
    proj_destroy(target_crs);
    stop_proj_error(ctx);
  }

  char buf[1024];
  snprintf(buf, sizeof(buf),
           "<proj_trans at %p with source_crs=%s:%s target_crs:%s:%s>\n", (void*)trans,
           proj_get_id_auth_name(source_crs, 0), proj_get_id_code(source_crs, 0),
           proj_get_id_auth_name(target_crs, 0), proj_get_id_code(target_crs, 0));

  proj_destroy(source_crs);
  proj_destroy(target_crs);

  return Rf_mkString(buf);
}
