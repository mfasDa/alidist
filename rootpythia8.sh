package: rootpythia8
version: "v1-0"
tag: master
requires:
  - ROOT
  - pythia
build_requires:
  - CMake
source: https://gitlab.cern.ch/mfasel/rootpythia8
prepend_path:
  ROOT_INCLUDE_PATH: "$ROOTPYTHIA8_ROOT/include"
incremental_recipe: |
  # Limit parallel builds to prevent OOM
  JOBS=$((${JOBS:-1}*3/5))
  [[ $JOBS -gt 0 ]] || JOBS=1
  cmake --build . -- ${JOBS:+-j$JOBS} install
  mkdir -p $INSTALLROOT/etc/modulefiles && rsync -a --delete etc/modulefiles/ $INSTALLROOT/etc/modulefiles
---
#!/bin/bash -ex


cmake $SOURCEDIR                                              \
      -DCMAKE_INSTALL_PREFIX=$INSTALLROOT                     \
      -DROOTSYS=$ROOTSYS                                      \
      -DPYTHIA8=$PYTHIA_ROOT

# Limit parallel builds to prevent OOM
JOBS=$((${JOBS:-1}*3/5))
[[ $JOBS -gt 0 ]] || JOBS=1
cmake --build . -- ${JOBS:+-j$JOBS} install

#ModuleFile
mkdir -p etc/modulefiles
alibuild-generate-module > etc/modulefiles/$PKGNAME
cat >> etc/modulefiles/$PKGNAME <<EoF
# Our environment
setenv ROOTPYTHIA8_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path LD_LIBRARY_PATH \$::env(ROOTPYTHIA8_ROOT)/lib
prepend-path LD_LIBRARY_PATH \$::env(ROOTPYTHIA8_ROOT)/lib64
prepend-path ROOT_INCLUDE_PATH \$::env(ROOTPYTHIA8_ROOT)/include
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(ROOTPYTHIA8_ROOT)/lib")
EoF
mkdir -p $INSTALLROOT/etc/modulefiles && rsync -a --delete etc/modulefiles/ $INSTALLROOT/etc/modulefiles