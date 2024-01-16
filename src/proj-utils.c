#include <proj.h>
#include <stdbool.h>

#include "proj-utils.h"

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
