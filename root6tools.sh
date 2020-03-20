package: root6tools
version: "v1-0"
tag: master
requires:
  - ROOT
build_requires:
  - CMake
source: https://github.com/mfasDa/ROOT6tools.git
prepend_path:
  ROOT_INCLUDE_PATH: "$ROOT6TOOLS_ROOT/include"
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
      -DROOTSYS=$ROOTSYS

# Limit parallel builds to prevent OOM
JOBS=$((${JOBS:-1}*3/5))
[[ $JOBS -gt 0 ]] || JOBS=1
cmake --build . -- ${JOBS:+-j$JOBS} install

# Modulefile
mkdir -p etc/modulefiles
cat > etc/modulefiles/$PKGNAME <<EoF
#%Module1.0
proc ModulesHelp { } {
  global version
  puts stderr "ALICE Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PKGHASH@@"
}
set version $PKGVERSION-@@PKGREVISION@$PKGHASH@@
module-whatis "ALICE Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PKGHASH@@"
# Dependencies
module load BASE/1.0  \\
            ROOT/$ROOT_VERSION-$ROOT_REVISION

# Our environment
setenv ROOT6TOOLS_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path PATH \$::env(ROOT6TOOLS_ROOT)/bin
prepend-path LD_LIBRARY_PATH \$::env(ROOT6TOOLS_ROOT)/lib
prepend-path LD_LIBRARY_PATH \$::env(ROOT6TOOLS_ROOT)/lib64
prepend-path ROOT_INCLUDE_PATH \$::env(ROOT6TOOLS_ROOT)/include
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(ROOT6TOOLS_ROOT)/lib")
EoF
mkdir -p $INSTALLROOT/etc/modulefiles && rsync -a --delete etc/modulefiles/ $INSTALLROOT/etc/modulefiles
