#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>
#include <proj.h>
#include <stdbool.h>
#include <stdio.h>
#include "wk-v1.h"

#include "proj-context.h"

typedef struct {
  PJ* pj;
  PJ* pj_norm;
  PJ_DIRECTION direction;
} proj_trans_t;

static int transform(R_xlen_t feature_id, const double* xyzm_in, double* xyzm_out,
                     void* trans_data) {
  proj_trans_t* data = (proj_trans_t*)trans_data;

  // PROJ >= 9.2: if any input xyzm are NaN, the entire output xyzm will be NaN.
  // This is unwanted behaviour for a wk-transform, as wk assigns z & m as NaN
  // when input coordinates don't contain those dimensions. A wk-trans object
  // isn't able to distinguish between NaN input and NaN due to missing
  // dimensions.

  // We workaround this by:
  // - Ensuring input z & m dimensions are never NaN
  // - If an input dimension is NaN, its output will be NaN
  // - Emulate 9.2 behaviour for NaN x or y dimensions

  bool is_nan[4];
  for (int i = 0; i < 4; i++) is_nan[i] = ISNAN(xyzm_in[i]);

  // emulating 9.2 behaviour for x,y dimensions
  if (is_nan[0] || is_nan[1]) {
    for (int i = 0; i < 4; i++) xyzm_out[i] = R_NaN;
    return WK_CONTINUE;
  }

  PJ_COORD coord_in = proj_coord(xyzm_in[0], xyzm_in[1],
                                 // ensure z,m not NaN
                                 is_nan[2] ? 0 : xyzm_in[2], is_nan[3] ? 0 : xyzm_in[3]);
  PJ_COORD coord_out = proj_trans(data->pj_norm, data->direction, coord_in);
  // FIXME: handle error

  xyzm_out[0] = coord_out.v[0];
  xyzm_out[1] = coord_out.v[1];
  // preserve NaN z,m
  xyzm_out[2] = is_nan[2] ? R_NaN : coord_out.v[2];
  xyzm_out[3] = is_nan[3] ? R_NaN : coord_out.v[3];

  return WK_CONTINUE;
}

static void finalize(void* trans_data) {
  if (trans_data == NULL) return;

  proj_trans_t* data = (proj_trans_t*)trans_data;
  if (data->pj != NULL) proj_destroy(data->pj);
  if (data->pj_norm != NULL) proj_destroy(data->pj_norm);
  free(data);
}

static wk_trans_t* wk_trans_from_xptr(SEXP trans_xptr) {
  if (TYPEOF(trans_xptr) != EXTPTRSXP || !Rf_inherits(trans_xptr, "proj_trans")) {
    Rf_error("`trans` must be a <proj_trans> object");
  }

  wk_trans_t* trans = (wk_trans_t*)R_ExternalPtrAddr(trans_xptr);
  if (trans == NULL) {
    Rf_error("`trans` is a null pointer");
  }

  return trans;
}

SEXP C_proj_trans_create(SEXP source_crs, SEXP target_crs, SEXP use_z, SEXP use_m) {
  wk_trans_t* trans = wk_trans_create();

  trans->trans = &transform;
  trans->finalizer = &finalize;
  trans->use_z = LOGICAL_RO(use_z)[0];
  trans->use_m = LOGICAL_RO(use_m)[0];

  proj_trans_t* data = (proj_trans_t*)calloc(1, sizeof(proj_trans_t));
  if (data == NULL) {
    wk_trans_destroy(trans);                  // # nocov
    Rf_error("Can't allocate proj_trans_t");  // # nocov
  }

  trans->trans_data = data;
  SEXP trans_xptr = PROTECT(wk_trans_create_xptr(trans, R_NilValue, R_NilValue));

  data->direction = PJ_FWD;

  data->pj = proj_create_crs_to_crs(
      PJ_DEFAULT_CTX, Rf_translateCharUTF8(STRING_ELT(source_crs, 0)),
      Rf_translateCharUTF8(STRING_ELT(target_crs, 0)), NULL);
  if (data->pj == NULL) {
    stop_proj_error(PJ_DEFAULT_CTX);
  }

  // always lon,lat
  data->pj_norm = proj_normalize_for_visualization(PJ_DEFAULT_CTX, data->pj);
  if (data->pj_norm == NULL) {
    stop_proj_error(PJ_DEFAULT_CTX);  // # nocov
  }

  // xptrs
  UNPROTECT(1);
  return trans_xptr;
}

SEXP C_proj_trans_fmt(SEXP trans_xptr) {
  wk_trans_t* trans = wk_trans_from_xptr(trans_xptr);
  proj_trans_t* data = (proj_trans_t*)trans->trans_data;

  PJ* source_crs = proj_get_source_crs(PJ_DEFAULT_CTX, data->pj);
  PJ* target_crs = proj_get_target_crs(PJ_DEFAULT_CTX, data->pj);
  if (source_crs == NULL || target_crs == NULL) {
    proj_destroy(source_crs);         // # nocov
    proj_destroy(target_crs);         // # nocov
    stop_proj_error(PJ_DEFAULT_CTX);  // # nocov
  }

  // inverse? swap
  if (data->direction == PJ_INV) {
    PJ* tmp = source_crs;
    source_crs = target_crs;
    target_crs = tmp;
  }

  char buf[1024];
  snprintf(buf, sizeof(buf),
           "<proj_trans at %p with source_crs=%s:%s target_crs=%s:%s>\n", (void*)trans,
           proj_get_id_auth_name(source_crs, 0), proj_get_id_code(source_crs, 0),
           proj_get_id_auth_name(target_crs, 0), proj_get_id_code(target_crs, 0));

  proj_destroy(source_crs);
  proj_destroy(target_crs);

  return Rf_mkString(buf);
}

SEXP C_proj_trans_inverse(SEXP trans_xptr) {
  wk_trans_t* trans_fwd = wk_trans_from_xptr(trans_xptr);
  proj_trans_t* data_fwd = (proj_trans_t*)trans_fwd->trans_data;

  // create reversed `trans`
  wk_trans_t* trans_inv = wk_trans_create();
  proj_trans_t* data_inv = (proj_trans_t*)calloc(1, sizeof(proj_trans_t));
  if (data_inv == NULL) {
    wk_trans_destroy(trans_inv);              // # nocov
    Rf_error("Can't allocate proj_trans_t");  // # nocov
  }

  // shallow copy trans, deep copy trans_data
  memcpy(trans_inv, trans_fwd, sizeof(wk_trans_t));
  trans_inv->trans_data = data_inv;

  SEXP trans_inv_xptr = PROTECT(wk_trans_create_xptr(trans_inv, R_NilValue, R_NilValue));

  // reverse
  data_inv->direction = -data_fwd->direction;

  data_inv->pj = proj_clone(PJ_DEFAULT_CTX, data_fwd->pj);
  if (data_inv->pj == NULL) {
    stop_proj_error(PJ_DEFAULT_CTX);  // # nocov
  }

  data_inv->pj_norm = proj_clone(PJ_DEFAULT_CTX, data_fwd->pj_norm);
  if (data_inv->pj_norm == NULL) {
    stop_proj_error(PJ_DEFAULT_CTX);  // # nocov
  }

  // xptr
  UNPROTECT(1);
  return trans_inv_xptr;
}
