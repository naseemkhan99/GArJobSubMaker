source /cvmfs/larsoft.opensciencegrid.org/spack-packages/setup-env.sh

# Source this file to set the basic configuration needed by LArSoft 
# and for the DUNE-specific software that interfaces to LArSoft.

# location of the common UPS database

CVMFS_COMMON_DIR="/cvmfs/fermilab.opensciencegrid.org/products/common/db/"

# current location of larsoft in CVMFS

CVMFS_LARSOFT_DIR="/cvmfs/larsoft.opensciencegrid.org"

CVMFS_DUNE_DIR="/cvmfs/dune.opensciencegrid.org/products/dune/"

# Set up ups for LArSoft

for dir in $CVMFS_LARSOFT_DIR;
do
  if [[ -f $dir/setup_larsoft.sh ]]; then
    echo "Setting up larsoft UPS area... ${dir}"
    source $dir/setup_larsoft.sh
    break
  fi
done

# need also the common db in $PRODUCTS

for dir in $CVMFS_COMMON_DIR
do
  if [[ -d $CVMFS_COMMON_DIR ]]; then
    export PRODUCTS=`dropit -p $PRODUCTS common/db`:${CVMFS_COMMON_DIR}
    break
  fi
done

# Set up ups for DUNE.  Remove /grid/fermiapp fallback

for dir in $CVMFS_DUNE_DIR;
do
  if [[ -f $dir/setup ]]; then
    echo "Setting up DUNE UPS area... ${dir}"
    source $dir/setup
    break
  fi
done

# Add current working directory (".") to FW_SEARCH_PATH
#
if [[ -n "${FW_SEARCH_PATH}" ]]; then
  export FW_SEARCH_PATH=.:`dropit -e -p $FW_SEARCH_PATH .`
else
  export FW_SEARCH_PATH=.
fi

# Set up the basic tools that will be needed
#
if [ `uname` != Darwin ]; then

  # Work around git table file bugs.

  export PATH=`dropit git`
  export LD_LIBRARY_PATH=`dropit -p $LD_LIBRARY_PATH git`
  spack load git
fi

spack load gitflow
spack load mrb

# this is now setup by jobsub_client. setup pycurl

# Define the value of MRB_PROJECT. This can be used
# to drive other set-ups. 
# We need to set this to 'larsoft' for now.

export MRB_PROJECT=larsoft

# Define environment variables that store the standard experiment name.

#export JOBSUB_GROUP=dune
#export EXPERIMENT=dune     # Used by ifdhc
#export SAM_EXPERIMENT=dune

# For Art workbook

export ART_WORKBOOK_OUTPUT_BASE=/vols/dune/nk3717/GArJobSubMaker
export ART_WORKBOOK_WORKING_BASE=/vols/dune/nk3717/GArJobSubMaker
export ART_WORKBOOK_QUAL="s2:e5:nu"

# For database

#export DBIWSPWDFILE=/dune/experts/path/to/proddbpwd/for/writes
#export DBIWSURL=http://dbdata0vm.fnal.gov:8116/LBNE35tCon/app/
#export DBIWSURLINT=http://dbdata0vm.fnal.gov:8116/LBNE35tCon/app/
#export DBIWSURLPUT=http://dbdata0vm.fnal.gov:8117/LBNE35tCon/app/
#export DBIQEURL=http://dbdata0vm.fnal.gov:8122/QE/dune35t/prod/app/SQ/
#export DBIHOST=ifdbprod.fnal.gov
#export DBINAME=dune35t_prod
#export DBIPORT=5442
#export DBIUSER=dune_reader
#export DBIPWDFILE='~jpaley/dune/db/proddbpwd'

# set up gdb and ninja out of ups

spack load gdb
spack load ninja
