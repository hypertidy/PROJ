AC_INIT(PROJ, 0.0.1, mdsumner@gmail.com)
AC_CONFIG_SRCDIR(src/C_proj_trans_generic.c)

# find R home and set correct compiler + flags
: ${R_HOME=`R RHOME`}
if test -z "${R_HOME}"; then
  AC_MSG_ERROR([cannot determine R_HOME. Make sure you use R CMD INSTALL!])
fi
RBIN="${R_HOME}/bin/R"

# pick all flags for testing from R
: ${CC=`"${RBIN}" CMD config CC`}
: ${CFLAGS=`"${RBIN}" CMD config CFLAGS`}
: ${CPPFLAGS=`"${RBIN}" CMD config CPPFLAGS`}
: ${LDFLAGS=`"${RBIN}" CMD config LDFLAGS`}


# honor PKG_xx overrides
LIBS="${LIBS} ${PKG_LIBS}"
# for CPPFLAGS we will superfluously double R's flags
# since we'll set PKG_CPPFLAGS with this, but that shouldn't hurt
CPPFLAGS="${CPPFLAGS} ${PKG_CPPFLAGS}"

projok=yes
AC_CHECK_HEADERS(proj.h,,projok=no)
AC_CHECK_LIB(proj,proj_normalize_for_visualization,,projok=no)
#if test "${projok}" = no; then
#   AC_MSG_ERROR([libproj and/or proj.h not found in standard search locations.
#
#*** Install PROJ 6.0.0 or higher and if necessary set PKG_CPPFLAGS/PKG_LIBS accordingly.])
#fi


#undef HAVE_PROJ6_API
if test "${projok}" = yes; then
   CPPFLAGS="${PKG_CPPFLAGS} -DHAVE_PROJ6_API=1"
else
   CPPFLAGS="${PKG_CPPFLAGS}"
fi
AC_ARG_VAR([PKG_CPPFLAGS],[custom C preprocessor flags for packages compilation])
AC_ARG_VAR([PKG_LIBS],[custom libraries for package compilation])

AC_CONFIG_FILES(src/Makevars)
AC_OUTPUT

