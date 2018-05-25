package: Eigen
version:  "3.3.4"
build_requires:
  - CMake
---
#/bin/sh
# download package
URL="https://bitbucket.org/eigen/eigen/get/3.3.4.tar.bz2"
file="eigen.tar.bz2"
#download if newer than local copy
if test -e "$file"
then
  #md5sum $file > $file".md5"
  curl -Lo $file "-z '$file'" "$URL"
else
  curl -Lo $file "$URL"
  #md5sum $file > $file".md5"
fi
# extract, but do'nt overwrite existing files
#if md5sum $file -c $file".md5"
#then
tar -xjf $file -C $SOURCEDIR --strip-components=1
#fi
cmake $SOURCEDIR \
  -DCMAKE_INSTALL_PREFIX:PATH="$INSTALLROOT"
make ${JOBS+-j $JOBS}
make install

#ModuleFile
mkdir -p etc/modulefiles
cat > etc/modulefiles/$PKGNAME <<EoF
#%Module1.0
proc ModulesHelp { } {
  global version
  puts stderr "Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PKGHASH@@"
}
set version $PKGVERSION-@@PKGREVISION@$PKGHASH@@
module-whatis "Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PKGHASH@@"
# Dependencies
module load BASE/1.0                                                                    \\
# Our environment
setenv EIGEN_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
EoF
MODULEDIR="$INSTALLROOT/etc/modulefiles"
mkdir -p $MODULEDIR && rsync -a --delete etc/modulefiles/ $MODULEDIR
