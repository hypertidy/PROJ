#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>
#include <proj.h>
#include <stdbool.h>

#include "proj-utils.h"

// polyfill PJ_TYPE enums introduced in 7.2
#if (PROJ_VERSION_MAJOR * 100 + PROJ_VERSION_MINOR) < 702
#define PJ_TYPE_TEMPORAL_DATUM 25
#define PJ_TYPE_ENGINEERING_DATUM 26
#define PJ_TYPE_PARAMETRIC_DATUM 27
#endif

const char* proj_type_name(PJ_TYPE type) {
  // clang-format off
  switch (type) {
    case PJ_TYPE_UNKNOWN: return "Unknown";
    case PJ_TYPE_ELLIPSOID: return "Ellipsoid";
    case PJ_TYPE_PRIME_MERIDIAN: return "Prime Meridian";

    case PJ_TYPE_GEODETIC_REFERENCE_FRAME: return "Geodetic Reference Frame";
    case PJ_TYPE_DYNAMIC_GEODETIC_REFERENCE_FRAME: return "Dynamic Geodetic Reference Frame";
    case PJ_TYPE_VERTICAL_REFERENCE_FRAME: return "Vertical Reference Frame";
    case PJ_TYPE_DYNAMIC_VERTICAL_REFERENCE_FRAME: return "Dynamic Vertical Reference Frame";
    case PJ_TYPE_DATUM_ENSEMBLE: return "Datum Ensemble";

    /** Abstract type, not returned by proj_get_type() */
    case PJ_TYPE_CRS: return "CRS";

    case PJ_TYPE_GEODETIC_CRS: return "Geodetic CRS";
    case PJ_TYPE_GEOCENTRIC_CRS: return "Geocentric CRS";

    /** proj_get_type() will never return that type, but
     * PJ_TYPE_GEOGRAPHIC_2D_CRS or PJ_TYPE_GEOGRAPHIC_3D_CRS. */
    case PJ_TYPE_GEOGRAPHIC_CRS: return "Geographic CRS";

    case PJ_TYPE_GEOGRAPHIC_2D_CRS: return "Geographic 2D CRS";
    case PJ_TYPE_GEOGRAPHIC_3D_CRS: return "GEOGRAPHIC 3D CRS";
    case PJ_TYPE_VERTICAL_CRS: return "Vertical CRS";
    case PJ_TYPE_PROJECTED_CRS: return "Projected CRS";
    case PJ_TYPE_COMPOUND_CRS: return "Compound CRS";
    case PJ_TYPE_TEMPORAL_CRS: return "Temporal CRS";
    case PJ_TYPE_ENGINEERING_CRS: return "Engineering CRS";
    case PJ_TYPE_BOUND_CRS: return "Bound CRS";
    case PJ_TYPE_OTHER_CRS: return "Other CRS";

    case PJ_TYPE_CONVERSION: return "Conversion";
    case PJ_TYPE_TRANSFORMATION: return "Transformation";
    case PJ_TYPE_CONCATENATED_OPERATION: return "Concatenated Operation";
    case PJ_TYPE_OTHER_COORDINATE_OPERATION: return "Other Coordinate Operation";

    case PJ_TYPE_TEMPORAL_DATUM: return "Temporal Datum";
    case PJ_TYPE_ENGINEERING_DATUM: return "Engineering Datum";
    case PJ_TYPE_PARAMETRIC_DATUM: return "Parametric Datum";

    default: return "Unknown";
  }
  // clang-format on
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
