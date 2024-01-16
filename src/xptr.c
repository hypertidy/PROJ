#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>
#include <stdbool.h>

SEXP C_xptr_addr(SEXP xptr) {
  if (TYPEOF(xptr) != EXTPTRSXP) {
    Rf_error("`xptr` must be an external pointer");
  }

  char buf[19];
  snprintf(buf, sizeof(buf), "%p", R_ExternalPtrAddr(xptr));

  return Rf_mkString(buf);
}
