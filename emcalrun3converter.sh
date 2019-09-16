package: EmcalRun3Converter
version: "v1-0"
tag: master
requires:
  - boost
  - "GCC-Toolchain:(?!osx)"
  - Common-O2
  - libInfoLogger
  - FairRoot
  - Monitoring
  - Configuration
  - O2
  - arrow
  - AliRoot
  - libjalienO2
build_requires:
  - CMake
  - CodingGuidelines
  - alibuild-recipe-tools
source: https://github.com/mfasDa/EmcalRun3Converter
prepend_path:
  ROOT_INCLUDE_PATH: "$EMCALRUN3CONVERTER_ROOT/include"
incremental_recipe: |
  # Limit parallel builds to prevent OOM
  JOBS=$((${JOBS:-1}*3/5))
  [[ $JOBS -gt 0 ]] || JOBS=1
  cmake --build . -- ${JOBS:+-j$JOBS} install
  mkdir -p $INSTALLROOT/etc/modulefiles && rsync -a --delete etc/modulefiles/ $INSTALLROOT/etc/modulefiles
---
#!/bin/bash -ex

case $ARCHITECTURE in
  osx*) [[ ! $BOOST_ROOT ]] && BOOST_ROOT=$(brew --prefix boost)
        [[ ! $LIBUV_ROOT ]] && LIBUV_ROOT=$(brew --prefix libuv)
        SONAME=dylib
        ;;
     *) 
        SONAME=so
  ;;
esac

# For the PR checkers (which sets ALIBUILD_O2_TESTS)
# we impose -Werror as a compiler flag
if [[ $ALIBUILD_O2_TESTS ]]; then
  CXXFLAGS="${CXXFLAGS} -Werror -Wno-error=deprecated-declarations"
fi

cmake $SOURCEDIR                                              \
      -DCMAKE_INSTALL_PREFIX=$INSTALLROOT                     \
      -DBOOST_ROOT=$BOOST_ROOT                                \
      -DROOTSYS=$ROOTSYS                                      \
      -DCommon_ROOT=$COMMON_O2_ROOT                           \
      -DConfiguration_ROOT=$CONFIGURATION_ROOT                \
      ${LIBINFOLOGGER_VERSION:+-DInfoLogger_ROOT=$LIBINFOLOGGER_ROOT}                       \
      -DALIROOT=$ALICE_ROOT                                   \
      -DO2_ROOT=$O2_ROOT                                      \
      -DFAIRROOTPATH=$FAIRROOT_ROOT                           \
      -DFairRoot_DIR=$FAIRROOT_ROOT                           \
      -DMS_GSL_INCLUDE_DIR=$MS_GSL_ROOT/include               \
      -DARROW_HOME=$ARROW_ROOT                                \
      ${LIBUV_ROOT:+-DLibUV_INCLUDE_DIR=$LIBUV_ROOT/include}             \
      ${LIBUV_ROOT:+-DLibUV_LIBRARY=$LIBUV_ROOT/lib/libuv.$SONAME}       \
      ${LIBJALIENO2_ROOT:+-DlibjalienO2_ROOT=$LIBJALIENO2_ROOT}          \
      ${CXXSTD:+-DCMAKE_CXX_STANDARD=$CXXSTD}                 \
      -DCMAKE_EXPORT_COMPILE_COMMANDS=ON

cp ${BUILDDIR}/compile_commands.json ${INSTALLROOT}

# Limit parallel builds to prevent OOM
JOBS=$((${JOBS:-1}*3/5))
[[ $JOBS -gt 0 ]] || JOBS=1
cmake --build . -- ${JOBS:+-j$JOBS} install

# Modulefile
mkdir -p etc/modulefiles
alibuild-generate-module --bin --lib > etc/modulefiles/$PKGNAME

# Our environment
cat >> etc/modulefiles/$PKGNAME <<EoF
setenv EMCALRUN3CONVERTER_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path PATH \$::env(EMCALRUN3CONVERTER_ROOT)/bin
prepend-path LD_LIBRARY_PATH \$::env(EMCALRUN3CONVERTER_ROOT)/lib
prepend-path LD_LIBRARY_PATH \$::env(EMCALRUN3CONVERTER_ROOT)/lib64
prepend-path ROOT_INCLUDE_PATH \$::env(EMCALRUN3CONVERTER_ROOT)/include
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(EMCALRUN3CONVERTER_ROOT)/lib" && echo "prepend-path DYLD_LIBRARY_PATH \$::env(EMCALRUN3CONVERTER_ROOT)/lib64")
EoF

mkdir -p $INSTALLROOT/etc/modulefiles && rsync -a --delete etc/modulefiles/ $INSTALLROOT/etc/modulefiles
