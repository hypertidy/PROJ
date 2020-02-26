#include <R.h>
#include <Rinternals.h>

#ifdef HAVE_PROJ6_API
#include <proj.h>
#endif

void PROJ_proj_trans_generic(char **src_, char **tgt_,
                             int *n,
                             double *x_, double *y_, double *z_, double *t_,
                             int *success)
{

  // no ifdef else
  success[0] = 0;
#ifdef HAVE_PROJ6_API
  // Derived from code
  // written by S. Urbanek in s-u/proj4
  /* Copyright (c) 2020 Michael Sumner, license GPL-3 */
  /* Copyright (c) 2007,2019 Simon Urbanek
   Part of proj4 R package, license: GPL v2 */
  PJ *pj, *pj2;
  int N = *n; /* if we want to support large vectors we'd have to change type of n first */
  int r;
  pj = proj_create_crs_to_crs(PJ_DEFAULT_CTX, *src_, *tgt_, NULL);
  if (0 == pj) {
    error(proj_errno_string(proj_errno(0)));
  }

  // https://proj.org/development/quickstart.html  2020-02-26
  // If for the needs of your software, you want a uniform axis order (and thus
  // do not care about axis order mandated by the authority defining the CRS),
  // the proj_normalize_for_visualization() function can be used to modify the
  // PJ* object returned by proj_create_crs_to_crs() so that it accepts as input
  // and returns as output coordinates using the traditional GIS order, that is
  // longitude, latitude (followed by elevation, time) for geographic CRS and easting,
  // northing for most projected CRS.

  pj2 = proj_normalize_for_visualization(PJ_DEFAULT_CTX, pj);
  if (0 == pj2) {
    int r = proj_errno(pj);
    proj_destroy(pj);
    error(proj_errno_string(r));
  }
  proj_destroy(pj);
  pj = pj2;
  // end written S.Urbanek

  // since 6.0
  // we don't need radian input handling, always degrees
  // and we don't need radian output handling
  proj_trans_generic(pj, PJ_FWD,
                     x_, sizeof(*x_), N,
                     y_, sizeof(*y_), N,
                     z_, sizeof(*z_), N,
                     t_, sizeof(*z_), N);

  r = proj_errno(pj);
  proj_destroy(pj);
  if (r) {
    error(proj_errno_string(r));
  }
  success[0] = 1L;
#endif

}
