package: FairRoot
version: "%(tag_basename)s"
tag: dev
source: https://github.com/FairRootGroup/FairRoot
requires:
  - FairSoft
env:
  VMCWORKDIR: "$FAIRROOT_ROOT/share/fairroot/examples"
  GEOMPATH:   "$FAIRROOT_ROOT/share/fairroot/examples/common/geometry"
  CONFIG_DIR: "$FAIRROOT_ROOT/share/fairroot/examples/common/gconfig"
prepend_path:
  ROOT_INCLUDE_PATH: "$FAIRROOT_ROOT/include"
incremental_recipe: |
  cmake --build . --target install ${JOBS:+-- -j$JOBS}
  mkdir -p $INSTALLROOT/etc/modulefiles && rsync -a --delete etc/modulefiles/ $INSTALLROOT/etc/modulefiles
---
#!/bin/sh

case $ARCHITECTURE in
  osx*)
    # If we preferred system tools, we need to make sure we can pick them up.
    [[ ! $BOOST_ROOT ]] && BOOST_ROOT=`brew --prefix boost`
    [[ ! $PROTOBUF_ROOT ]] && PROTOBUF_ROOT=`brew --prefix protobuf`
    [[ ! $GSL_ROOT ]] && GSL_ROOT=`brew --prefix gsl`
    SONAME=dylib
  ;;
  *) SONAME=so ;;
esac

unset SIMPATH

cmake                                                            \
      ${C_COMPILER:+-DCMAKE_C_COMPILER=$C_COMPILER}              \
      ${CXX_COMPILER:+-DCMAKE_CXX_COMPILER=$CXX_COMPILER}        \
      -DMACOSX_RPATH=OFF                                         \
      -DCMAKE_CXX_FLAGS="$CXXFLAGS -std=c++${CXX_STANDARD}"      \
      -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE                       \
      -DROOTSYS=$ROOTSYS                                         \
      -DROOT_CONFIG_SEARCHPATH=$ROOT_ROOT/bin                    \
      -DDISABLE_GO=ON                                            \
      -DBUILD_EXAMPLES=ON                                        \
      -DCMAKE_INSTALL_PREFIX=$INSTALLROOT                        \
      -DFAIRROOT_MODULAR_BUILD=ON                                \
      $SOURCEDIR

cmake --build . --target install ${JOBS:+-- -j$JOBS}

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
module load BASE/1.0                                                                            \\
            FairSoft/$FAIRSOFT_VERSION-$FAIRSOFT_REVISION}                                      \\
# Our environment
setenv FAIRROOT_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
setenv VMCWORKDIR \$::env(FAIRROOT_ROOT)/share/fairbase/examples
setenv GEOMPATH \$::env(VMCWORKDIR)/common/geometry
setenv CONFIG_DIR \$::env(VMCWORKDIR)/common/gconfig
prepend-path PATH \$::env(FAIRROOT_ROOT)/bin
prepend-path LD_LIBRARY_PATH \$::env(FAIRROOT_ROOT)/lib
prepend-path ROOT_INCLUDE_PATH \$::env(FAIRROOT_ROOT)/include
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(FAIRROOT_ROOT)/lib")
EoF
MODULEDIR="$INSTALLROOT/etc/modulefiles"
mkdir -p $MODULEDIR && rsync -a --delete etc/modulefiles/ $MODULEDIR
