#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>
#include <proj.h>
#include <math.h>

// Column names for the output matrix matching PJ_FACTORS struct fields
static const char* PJ_FACTORS_NAMES[] = {
    "meridional_scale",
    "parallel_scale",
    "areal_scale",
    "angular_distortion",
    "meridian_parallel_angle",
    "meridian_convergence",
    "tissot_semimajor",
    "tissot_semiminor",
    "dx_dlam",
    "dx_dphi",
    "dy_dlam",
    "dy_dphi"
};

#define N_FACTORS 12

// C_proj_factors(crs, lp)
// crs: character(1) - a PROJ CRS definition string
// lp: numeric matrix with 2 columns (longitude, latitude in degrees)
// returns: numeric matrix with N_FACTORS columns, nrow = nrow(lp)
SEXP C_proj_factors(SEXP crs_, SEXP lp_) {
    PJ_CONTEXT* ctx = proj_context_create();
    if (ctx == NULL) {
        Rf_error("Failed to create PROJ context");
    }

    const char* crs_str = Rf_translateCharUTF8(STRING_ELT(crs_, 0));
    PJ* pj = proj_create(ctx, crs_str);
    if (pj == NULL) {
        int err = proj_context_errno(ctx);
#if PROJ_VERSION_MAJOR < 8
        const char* msg = proj_errno_string(err);
#else
        const char* msg = proj_context_errno_string(ctx, err);
#endif
        proj_context_destroy(ctx);
        Rf_error("%s", msg);
    }

    R_xlen_t n = Rf_nrows(lp_);
    const double* lp = REAL_RO(lp_);

    SEXP out = PROTECT(Rf_allocMatrix(REALSXP, (int)n, N_FACTORS));
    double* out_ptr = REAL(out);

    for (R_xlen_t i = 0; i < n; i++) {
        double lon_deg = lp[i];          // column 1: longitude
        double lat_deg = lp[i + n];      // column 2: latitude
        PJ_COORD coord = proj_coord(
            lon_deg * M_PI / 180.0,
            lat_deg * M_PI / 180.0,
            0.0, 0.0
        );
        PJ_FACTORS f = proj_factors(pj, coord);

        out_ptr[i + n * 0]  = f.meridional_scale;
        out_ptr[i + n * 1]  = f.parallel_scale;
        out_ptr[i + n * 2]  = f.areal_scale;
        out_ptr[i + n * 3]  = f.angular_distortion;
        out_ptr[i + n * 4]  = f.meridian_parallel_angle;
        out_ptr[i + n * 5]  = f.meridian_convergence;
        out_ptr[i + n * 6]  = f.tissot_semimajor;
        out_ptr[i + n * 7]  = f.tissot_semiminor;
        out_ptr[i + n * 8]  = f.dx_dlam;
        out_ptr[i + n * 9]  = f.dx_dphi;
        out_ptr[i + n * 10] = f.dy_dlam;
        out_ptr[i + n * 11] = f.dy_dphi;
    }

    // set column names
    SEXP dimnames = PROTECT(Rf_allocVector(VECSXP, 2));
    SEXP colnames = PROTECT(Rf_allocVector(STRSXP, N_FACTORS));
    for (int j = 0; j < N_FACTORS; j++) {
        SET_STRING_ELT(colnames, j, Rf_mkChar(PJ_FACTORS_NAMES[j]));
    }
    SET_VECTOR_ELT(dimnames, 0, R_NilValue);
    SET_VECTOR_ELT(dimnames, 1, colnames);
    Rf_setAttrib(out, R_DimNamesSymbol, dimnames);

    UNPROTECT(3);

    proj_destroy(pj);
    proj_context_destroy(ctx);

    return out;
}
