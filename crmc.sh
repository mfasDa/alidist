package: CRMC
version: "%(tag_basename)s"
tag: alice/v1.5.4
source: https://github.com/alisw/crmc.git
requires:
  - boost
  - HepMC
build_requires:
  - CMake
---
#!/bin/bash -ex
case $ARCHITECTURE in
  osx*)
    # If we preferred system tools, we need to make sure we can pick them up.
    [[ ! $BOOST_ROOT ]] && BOOST_ROOT=`brew --prefix boost`
  ;;
esac

# In case root is available determine std
std=
if [ "x$(which root-config)" != "x" ]; then
  if [ $(root-config --has-cxx11) == "yes" ] ; then
    std="c++11"
  fi
  if [ $(root-config --has-cxx14) == "yes" ] ; then
    std="c++14"
  fi
fi

cmake $SOURCEDIR                               \
      ${BOOST_ROOT:+-DBOOST_ROOT=$BOOST_ROOT}  \
      -DCMAKE_INSTALL_PREFIX=$INSTALLROOT \
      ${std:+-DCMAKE_CXX_FLAGS="$(printf "\-std=%s" "$std")"} \
      ${FASTJET_ROOT:+-DFastjet_DIR=$FASTJET_ROOT}
make ${JOBS+-j $JOBS} all
make install

# Modulefile
MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
cat > "$MODULEFILE" <<EoF
#%Module1.0
proc ModulesHelp { } {
  global version
  puts stderr "ALICE Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PKGHASH@@"
}
set version $PKGVERSION-@@PKGREVISION@$PKGHASH@@
module-whatis "ALICE Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PKGHASH@@"
# Dependencies
module load BASE/1.0 ${BOOST_ROOT:+boost/$BOOST_VERSION-$BOOST_REVISION} HepMC/$HEPMC_VERSION-$HEPMC_REVISION
# Our environment
setenv CRMC_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path PATH $::env(CRMC_ROOT)/bin
prepend-path LD_LIBRARY_PATH $::env(CRMC_ROOT)/lib
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH $::env(CRMC_ROOT)/lib")
EoF
