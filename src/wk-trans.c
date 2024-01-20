#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>
#include <proj.h>
#include <stdbool.h>
#include <stdio.h>
#include "wk-v1.h"

#include "proj-utils.h"
#include "r-utils.h"

typedef struct {
  PJ_CONTEXT* context;
  PJ* transformer;
  PJ* source_crs;
  PJ* target_crs;
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
  PJ_COORD coord_out = proj_trans(data->transformer, data->direction, coord_in);
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
  if (data->transformer != NULL) proj_destroy(data->transformer);
  if (data->source_crs != NULL) proj_destroy(data->source_crs);
  if (data->target_crs != NULL) proj_destroy(data->target_crs);
  if (data->context != NULL) proj_context_destroy(data->context);

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
  data->context = proj_context_create();

  data->source_crs =
      proj_create(data->context, Rf_translateCharUTF8(STRING_ELT(source_crs, 0)));
  if (data->source_crs == NULL) {
    stop_proj_error(data->context);  // #nocov
  }

  data->target_crs =
      proj_create(data->context, Rf_translateCharUTF8(STRING_ELT(target_crs, 0)));
  if (data->target_crs == NULL) {
    stop_proj_error(data->context);  // #nocov
  }

  PJ* transformer = proj_create_crs_to_crs_from_pj(data->context, data->source_crs,
                                                   data->target_crs, NULL, NULL);
  if (transformer == NULL) {
    stop_proj_error(data->context);  // #nocov
  }

  // always lon,lat
  data->transformer = proj_normalize_for_visualization(data->context, transformer);
  proj_destroy(transformer);

  if (data->transformer == NULL) {
    stop_proj_error(data->context);  // # nocov
  }

  // xptrs
  UNPROTECT(1);
  return trans_xptr;
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

  data_inv->context = proj_context_create();

  data_inv->source_crs = proj_clone(data_inv->context, data_fwd->source_crs);
  if (data_inv->source_crs == NULL) {
    stop_proj_error(data_inv->context);  // # nocov
  }

  data_inv->target_crs = proj_clone(data_inv->context, data_fwd->target_crs);
  if (data_inv->target_crs == NULL) {
    stop_proj_error(data_inv->context);  // # nocov
  }

  data_inv->transformer = proj_clone(data_inv->context, data_fwd->transformer);
  if (data_inv->transformer == NULL) {
    stop_proj_error(data_inv->context);  // # nocov
  }

  // xptr
  UNPROTECT(1);
  return trans_inv_xptr;
}

static SEXP proj_area_of_use_info(PJ_CONTEXT* ctx, PJ* trans_or_crs) {
  double bounds[4] = {0, 0, 0, 0};
  const char* name = NULL;

  bool has_aoi = proj_get_area_of_use(ctx, trans_or_crs, &bounds[0], &bounds[1],
                                      &bounds[2], &bounds[3], &name);
  if (!has_aoi) return R_NilValue;

  const char* nms[] = {"name", "bounds", ""};
  SEXP res = PROTECT(Rf_mkNamed(VECSXP, nms));

  SET_VECTOR_ELT(res, 0, r_scalar_string(name));
  SEXP res_bounds = SET_VECTOR_ELT(res, 1, Rf_allocVector(REALSXP, 4));

  memcpy(REAL(res_bounds), bounds, sizeof(bounds));

  UNPROTECT(1);
  return res;
}

static SEXP proj_crs_info(PJ_CONTEXT* ctx, PJ* crs) {
  PJ_TYPE type = proj_get_type(crs);
  const char* name = proj_get_name(crs);
  const char* auth = proj_get_id_auth_name(crs, 0);
  const char* code = proj_get_id_code(crs, 0);

  const char* nms[] = {"type", "name", "authority", "code", "area_of_use", ""};
  SEXP res = PROTECT(Rf_mkNamed(VECSXP, nms));

  SET_VECTOR_ELT(res, 0, r_scalar_string(proj_type_name(type)));
  SET_VECTOR_ELT(res, 1, r_scalar_string(name));
  SET_VECTOR_ELT(res, 2, r_scalar_string(auth));
  SET_VECTOR_ELT(res, 3, r_scalar_string(code));
  SET_VECTOR_ELT(res, 4, proj_area_of_use_info(ctx, crs));

  UNPROTECT(1);
  return res;
}

SEXP C_proj_trans_info(SEXP trans_xptr) {
  wk_trans_t* trans = wk_trans_from_xptr(trans_xptr);
  proj_trans_t* data = (proj_trans_t*)trans->trans_data;

  // clang-format off
  const char* nms[] = {"type", "id", "description", "definition",
                       "area_of_use", "source_crs", "target_crs",  ""};
  // clang-format on
  SEXP res = PROTECT(Rf_mkNamed(VECSXP, nms));

  // ensure transformer is initialised
  proj_trans(data->transformer, data->direction, proj_coord(0, 0, 0, 0));
  PJ_PROJ_INFO info = proj_pj_info(data->transformer);
  PJ_TYPE type = proj_get_type(data->transformer);

  PJ* source_crs = data->direction != PJ_INV ? data->source_crs : data->target_crs;
  PJ* target_crs = data->direction != PJ_INV ? data->target_crs : data->source_crs;

  SET_VECTOR_ELT(res, 0, r_scalar_string(proj_type_name(type)));
  SET_VECTOR_ELT(res, 1, r_scalar_string(info.id));
  SET_VECTOR_ELT(res, 2, r_scalar_string(info.description));
  SET_VECTOR_ELT(res, 3, r_scalar_string(info.definition));
  SET_VECTOR_ELT(res, 4, proj_area_of_use_info(data->context, data->transformer));
  SET_VECTOR_ELT(res, 5, proj_crs_info(data->context, source_crs));
  SET_VECTOR_ELT(res, 6, proj_crs_info(data->context, target_crs));

  UNPROTECT(1);
  return res;
}
