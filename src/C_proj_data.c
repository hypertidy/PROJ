#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>
#include <proj.h>
#include <string.h>
#include <stdio.h>

/*
 * Management of the PROJ data directory (proj.db and friends).
 *
 * The package may ship a copy of the PROJ data directory in inst/proj:
 * always on Windows (copied from Rtools by src/Makevars.ucrt), on macOS
 * when CRAN builds with --with-data-copy, never by default on Linux.
 *
 * The search path is set on PROJ's default context with
 * proj_context_set_search_paths(NULL, ...). Every PJ_CONTEXT this package
 * creates with proj_context_create() is a copy of the default context, so
 * they all inherit it, and the setting is private to the libproj this
 * package is linked against. It does not touch PROJ_LIB / PROJ_DATA, so it
 * cannot leak into another package's libproj (and another package setting
 * those variables cannot be relied on to rescue this one).
 */

/* C_proj_set_search_paths(paths): character vector, length 0 resets to
 * the library defaults. */
SEXP C_proj_set_search_paths(SEXP paths_) {
  R_xlen_t n = Rf_xlength(paths_);
  if (n == 0) {
    proj_context_set_search_paths(NULL, 0, NULL);
    return Rf_ScalarLogical(1);
  }
  const char **paths = (const char **) R_alloc((size_t) n, sizeof(const char *));
  for (R_xlen_t i = 0; i < n; i++) {
    paths[i] = Rf_translateCharUTF8(STRING_ELT(paths_, i));
  }
  proj_context_set_search_paths(NULL, (int) n, paths);
  return Rf_ScalarLogical(1);
}

/* Capture PROJ's log output into a fixed buffer so a failed probe can
 * report *why* (e.g. "proj.db lacks DATABASE.LAYOUT.VERSION.MAJOR ...
 * It comes from another PROJ installation", or "DATABASE.LAYOUT.VERSION.MINOR
 * too old"). Distinct messages are joined; PROJ logs the same one several times. */
#define PROBE_MSG_LEN 1024
static void probe_log(void *app_data, int level, const char *msg) {
  char *buf = (char *) app_data;
  if (level != PJ_LOG_ERROR || msg == NULL) return;
  if (strstr(buf, msg) != NULL) return;   /* PROJ repeats itself */
  size_t used = strlen(buf);
  if (used > 0 && used + 3 < PROBE_MSG_LEN) {
    buf[used++] = ';'; buf[used++] = ' '; buf[used] = '\0';
  }
  snprintf(buf + used, PROBE_MSG_LEN - used, "%s", msg);
}

/* C_proj_probe_db(): force a database lookup on a fresh context.
 * PROJ validates proj.db lazily, on first database access, so setting a
 * search path to an unusable directory does not fail until a lookup.
 * Returns list(ok = logical, message = character, db_path = character). */
SEXP C_proj_probe_db(void) {
  char msg[PROBE_MSG_LEN];
  msg[0] = '\0';

  PJ_CONTEXT *ctx = proj_context_create();
  if (ctx == NULL) Rf_error("Failed to create PROJ context");
  proj_log_func(ctx, msg, probe_log);
  proj_log_level(ctx, PJ_LOG_ERROR);

  PJ *pj = proj_create(ctx, "EPSG:4326");
  int ok = (pj != NULL);
  const char *db = proj_context_get_database_path(ctx);

  SEXP out = PROTECT(Rf_allocVector(VECSXP, 3));
  SEXP nms = PROTECT(Rf_allocVector(STRSXP, 3));
  SET_VECTOR_ELT(out, 0, Rf_ScalarLogical(ok));
  SET_STRING_ELT(nms, 0, Rf_mkChar("ok"));
  SET_VECTOR_ELT(out, 1, Rf_mkString(msg));
  SET_STRING_ELT(nms, 1, Rf_mkChar("message"));
  SET_VECTOR_ELT(out, 2, db ? Rf_mkString(db) : Rf_ScalarString(NA_STRING));
  SET_STRING_ELT(nms, 2, Rf_mkChar("db_path"));
  Rf_setAttrib(out, R_NamesSymbol, nms);

  if (pj) proj_destroy(pj);
  proj_context_destroy(ctx);
  UNPROTECT(2);
  return out;
}

/* C_proj_db_info(): metadata of the proj.db a fresh context resolves to.
 * Returns a named character vector; NA values when the database is not
 * usable (the metadata call itself needs a valid database). */
SEXP C_proj_db_info(void) {
  static const char *keys[] = {
    "PROJ.VERSION", "DATABASE.LAYOUT.VERSION.MAJOR", "DATABASE.LAYOUT.VERSION.MINOR",
    "EPSG.VERSION", "EPSG.DATE", "PROJ_DATA.VERSION"
  };
  const int nkeys = (int) (sizeof(keys) / sizeof(keys[0]));

  PJ_CONTEXT *ctx = proj_context_create();
  if (ctx == NULL) Rf_error("Failed to create PROJ context");
  proj_log_level(ctx, PJ_LOG_NONE);

  SEXP out = PROTECT(Rf_allocVector(STRSXP, nkeys + 1));
  SEXP nms = PROTECT(Rf_allocVector(STRSXP, nkeys + 1));
  const char *db = proj_context_get_database_path(ctx);
  SET_STRING_ELT(out, 0, db ? Rf_mkChar(db) : NA_STRING);
  SET_STRING_ELT(nms, 0, Rf_mkChar("path"));
  for (int i = 0; i < nkeys; i++) {
    const char *v = db ? proj_context_get_database_metadata(ctx, keys[i]) : NULL;
    SET_STRING_ELT(out, i + 1, v ? Rf_mkChar(v) : NA_STRING);
    SET_STRING_ELT(nms, i + 1, Rf_mkChar(keys[i]));
  }
  Rf_setAttrib(out, R_NamesSymbol, nms);
  proj_context_destroy(ctx);
  UNPROTECT(2);
  return out;
}
