#include <R.h>
#include <Rinternals.h>

#ifdef HAVE_PROJ6_API
#include <proj.h>
#endif

void PROJ_proj_create(char **crs_, int *format,
                      int *success)
{

  success[0] = 0;

#ifdef HAVE_PROJ6_API
  PJ *pj;

  if (!(pj =   proj_create(0, *crs_)))
    error(proj_errno_string(proj_errno(0)));

  int fmt = *format;
  if (fmt == 0) {
    Rprintf("WKT2\n");
  //proj_as_wkt();
  // PJ_WKT1_ESRI;
  //  PJ_WKT1_GDAL;
  //  PJ_WKT2_2015;
  //  PJ_WKT2_2015_SIMPLIFIED;
  //  PJ_WKT2_2018;
  //  PJ_WKT2_2018_SIMPLIFIED;
    proj_as_wkt(0, pj, PJ_WKT2_2018, NULL);
    success[0] = 1;

  }
  if (fmt == 1) {
    Rprintf("PROJ\n");
    //PJ_PROJ_4;
    //PJ_PROJ_5;
    proj_as_proj_string(0, pj, PJ_PROJ_5, NULL);
    success[0] = 1;

  }
  if (fmt == 2) {
    Rprintf("PROJJSON\n");
   proj_as_projjson(0, pj, NULL);
   success[0] = 1;

  }


#else

 success[0] = 0;

#endif

}
