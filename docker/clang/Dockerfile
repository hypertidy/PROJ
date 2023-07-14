FROM tuxmake/clang-15

RUN apt-get update -y ;  apt-get install -y  --fix-missing --no-install-recommends curl valgrind \
    libc++abi-15-dev libc++-15-dev \
    build-essential ca-certificates nano git libxml2-dev git make cmake wget unzip libtool automake \
    zlib1g-dev libsqlite3-dev pkg-config sqlite3 libcurl4-gnutls-dev libtiff5-dev \
    libharfbuzz-dev libfribidi-dev libfontconfig1-dev libproj-dev



RUN curl -Ls https://github.com/r-lib/rig/releases/download/latest/rig-linux-latest.tar.gz | tar xz -C /usr/local

RUN rig add devel

RUN mkdir ~/.R

RUN printf 'CC = clang\nCXX = clang++ -stdlib=libc++\nCXX11 = clang++ -stdlib=libc++\nCXX14 = clang++ -stdlib=libc++\nCXX17 = clang++ -stdlib=libc++\nCXX20 = clang++ -stdlib=libc++\n' > ~/.R/Makevars

RUN flags="-O2 -g -Wunneeded-internal-declaration -Winvalid-utf8 -Wformat -Wsizeof-pointer-div -Wliteral-conversion -Wempty-body -Wreturn-stack-address -Wnon-c-typedef-for-linkage -Wstrict-prototypes"; \
    echo "CFLAGS=$flags" >> ~/.R/Makevars; \
    echo "CXXFLAGS=$flags" >> ~/.R/Makevars; \
    echo "CXX11FLAGS=$flags" >> ~/.R/Makevars; \
    echo "CXX14FLAGS=$flags" >> ~/.R/Makevars; \
    echo "CXX17FLAGS=$flags" >> ~/.R/Makevars; \
    echo "CXX20FLAGS=$flags" >> ~/.R/Makevars

RUN export MAKEFLAGS=-j30

RUN R -e 'options(Ncpus = 30);  pak::pkg_install(c("markdown", "spelling", "jsonlite",  "testthat", "rmarkdown", "devtools"), ask = FALSE, upgrade = TRUE);'

#docker build . -t hypertidy/clang
#docker run -it --rm -v $(pwd)../../..:/PROJ  hypertidy/clang

## now edit src/Makevars.in to put -Wconversion ito CPPFLAGS, and:
#R CMD build PROJ --no-build-vignettes
#R CMD INSTALL PROJ_0.4.5.tar.gz > PROJ/inst/ci/INSTALL.out 2>&1
#R CMD check PROJ_0.4.5.tar.gz --no-manual --no-build-vignettes --ignore-vignettes --no-vignettes > PROJ/inst/ci/CHECK.out 2>&1
#R -d valgrind --vanilla < "PROJ.Rcheck/PROJ-Ex.R"  > PROJ/inst/ci/VALGRIND.out 2>&1
#R -d "valgrind --tool=memcheck --leak-check=full --track-origins=yes --show-leak-kinds=definite" --vanilla > "PROJ.Rcheck/PROJ-Ex.R" > PROJ/inst/ci/VALGRINDfull.out 2>&1
#Rscript -e "devtools::test('PROJ')" > PROJ/inst/ci/TEST.out 2>&1
