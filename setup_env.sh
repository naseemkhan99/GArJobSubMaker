LANG="en_US.UTF-8"
source /cvmfs/dune.opensciencegrid.org/products/dune/setup_dune.sh
export UPS_OVERRIDE="-H Linux64bit+3.10-2.17"
setup python v3_9_2
python scripts/make_jobsub.py configs/default/ --local_products=garsoft/localProducts_garsoft_develop_e26_prof/
tar -xvzf jobsub.tar.gz
cp jobsubdir_old/setup_grid_genie.sh jobsubdir/setup_grid_genie.sh
cp jobsubdir_old/setup_grid_global.sh jobsubdir/setup_grid_global.sh
cp jobsubdir_old/setup_grid_gsft.sh jobsubdir/setup_grid_gsft.sh
