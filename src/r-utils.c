#define R_NO_REMAP
#include "r-utils.h"

SEXP r_scalar_string(const char* str) {
  return str != NULL ? Rf_ScalarString(Rf_mkCharCE(str, CE_UTF8))
                     : Rf_ScalarString(NA_STRING);
}
