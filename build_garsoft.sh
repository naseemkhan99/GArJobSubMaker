LANG="en_US.UTF-8"
source /cvmfs/dune.opensciencegrid.org/products/dune/setup_dune.sh
export UPS_OVERRIDE="-H Linux64bit+3.10-2.17"
cd garsoft
source localProducts*/setup
cd $MRB_BUILDDIR
mrbsetenv
mrb i -j4
mrbslp
cd ../../
