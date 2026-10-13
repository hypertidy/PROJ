#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>

#include <proj.h>

// proj_crs_text(source, format): source as WKT2 (0), PROJ string (1) or
// PROJJSON (2). NA_character_ with a warning if PROJ cannot create the
// object or render it in that format; never an R error, so the R wrapper
// keeps its documented NA-on-failure behaviour.
SEXP C_proj_crs_text(SEXP crs_, SEXP format)
{
  const char* crs_in = Rf_translateCharUTF8(STRING_ELT(crs_, 0));
  int fmt = Rf_asInteger(format);

  SEXP out = PROTECT(Rf_allocVector(STRSXP, 1));
  SET_STRING_ELT(out, 0, NA_STRING);

  PJ_CONTEXT* ctx = proj_context_create();
  if (ctx == NULL) {
    UNPROTECT(1);
    Rf_error("Failed to create PROJ context");
  }

  PJ* pj = proj_create(ctx, crs_in);
  if (pj == NULL) {
    int err = proj_context_errno(ctx);
    const char* msg = proj_context_errno_string(ctx, err);
    const char* hint = proj_context_get_database_path(ctx) == NULL
        ? " (no usable proj.db found by the PROJ library, see proj_data_info())" : "";
    // copy before the context (which may own msg) is destroyed
    char buf[512];
    snprintf(buf, sizeof(buf), "%s%s", msg ? msg : "unknown PROJ error", hint);
    proj_context_destroy(ctx);
    UNPROTECT(1);
    Rf_warning("proj_crs_text(): cannot create object from '%s': %s", crs_in, buf);
    return out;
  }

  const char* outstring = NULL;
  switch (fmt) {
    case 0: outstring = proj_as_wkt(ctx, pj, PJ_WKT2_2019, NULL); break;
    case 1: outstring = proj_as_proj_string(ctx, pj, PJ_PROJ_5, NULL); break;
    case 2: outstring = proj_as_projjson(ctx, pj, NULL); break;
    default: break;
  }

  // the returned string is owned by pj: copy into R before destroying it
  if (outstring != NULL) {
    SET_STRING_ELT(out, 0, Rf_mkCharCE(outstring, CE_UTF8));
  }

  proj_destroy(pj);
  proj_context_destroy(ctx);

  if (outstring == NULL) {
    Rf_warning("proj_crs_text(): PROJ could not render '%s' in format %d", crs_in, fmt);
  }

  UNPROTECT(1);
  return out;
}
