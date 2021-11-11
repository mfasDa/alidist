package: emcalworkflowrunner
version: "%(tag_basename)s"
tag: "v1.0.0"
source: https://github.com/mfasDa/emcalworkflowrunner
---
#!/bin/bash -e

rsync -a --exclude='**/.git' --delete --delete-excluded $SOURCEDIR/ $INSTALLROOT/

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
module load BASE/1.0
# Our environment
set EMCALWORKFLOWRUNNER_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
setenv EMCALWORKFLOWRUNNER_ROOT \$EMCALWORKFLOWRUNNER_ROOT
prepend-path PATH \$EMCALWORKFLOWRUNNER_ROOT
prepend-path PYTHONPATH \$EMCALWORKFLOWRUNNER_ROOT
EoF
