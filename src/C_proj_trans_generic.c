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

#ifdef HAVE_PROJ6_API
  // written by S. Urbanek in s-u/proj4
  /* Copyright (c) 2007,2019 Simon Urbanek
   Part of proj4 R package, license: GPL v2 */

  PJ *pj, *pj2;
  int N = *n; /* if we want to support large vectors we'd have to change type of n first */
  int r;
  //int in_rad2deg = 0, out_rad2deg = 0;

  if (!(pj = proj_create_crs_to_crs(0, *src_, *tgt_, 0)))
    error(proj_errno_string(proj_errno(0)));

 // this only in 6, not 5
  if (!(pj2 = proj_normalize_for_visualization(0, pj))) {
    int r = proj_errno(pj);
    proj_destroy(pj);
    error(proj_errno_string(r));
  }

  proj_destroy(pj);
  pj = pj2;
 // only in 6 end
 // end written S.Urbanek

 // we don't need radian input handling, always degrees
 proj_trans_generic(pj, PJ_FWD,
                   x_, sizeof(*x_), N,
                   y_, sizeof(*y_), N,
                   z_, sizeof(*z_), N,
                   t_, sizeof(*z_), N);

 // and we don't need radian output handling

 r = proj_errno(pj);

 proj_destroy(pj);

 if (r)
  error(proj_errno_string(r));
 int i1 = 1;
 success[0] = i1;

#else

 success[0] = 0;

#endif

}
