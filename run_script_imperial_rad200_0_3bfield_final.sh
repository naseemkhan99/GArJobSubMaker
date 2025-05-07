#!/bin/bash 

#echo "Running on $(hostname) at ${GLIDEIN_Site}. GLIDEIN_DUNESite = ${GLIDEIN_DUNESite}" 
LANG="en_US.UTF-8"
export UPS_OVERRIDE="-H Linux64bit+3.10-2.17"
CLUSTER=$1
PROCESS=$(($2))
linenumber=$(($2+1))
echo "Temp dir: $TMPDIR"
if [ ! -d "/vols/dune/nk3717/data/NDGAr_1MCAFs/ghep_files/rad200/bfield0_3/" ]
then
  mkdir /vols/dune/nk3717/data/NDGAr_1MCAFs/ghep_files/rad200/bfield0_3/
fi

export OUTDIR=/vols/dune/nk3717/data/NDGAr_1MCAFs/ghep_files/rad200/bfield0_3/ 
export INDIR=/vols/dune/nk3717/data/NDGAr_1MCAFs/ghep_files/rad200/
export INPUT_TAR_DIR_LOCAL=/vols/dune/nk3717/GArJobSubMaker/jobsubdir_rad200_0_3bfield/
export TFILESERVICE_OUTPUT=$_CONDOR_SCRATCH_DIR
echo $TFILESERVICE_OUTPUT
#export OUTFILE_EDEP=gar_edep_${CLUSTER}_${PROCESS}_$(date -u +%Y%m%d).root 
#export OUTFILE_ANA=gar_ana_${CLUSTER}_${PROCESS}_$(date -u +%Y%m%d).root 
#export ND_PRODUCTION_CONFIG=/cvmfs/dune.opensciencegrid.org/products/dune/ND_Production/v01_05_00/config_data/

#OUTFILE_GENIE=gar_genie_${CLUSTER}_${PROCESS}_$(date -u +%Y%m%d).root 
#OUTFILE_ANA=gar_ana_${CLUSTER}_${PROCESS}_$(date -u +%Y%m%d).root 

#OUTFILE_GENIE=gar_genie_${CLUSTER}_${PROCESS}_$(date -u +%Y%m%d).root 
INFILE_GHEP=ndgar_prod_ghep_$(printf "%05.0f" "${PROCESS}").root 
OUTFILE_ANA=ndgar_prod_ana_$(printf "%05.0f" "${PROCESS}").root 
neventsfile=/vols/dune/nk3717/data/NDGAr_1MCAFs/ghep_files/rad200/nevents.txt
INPUTFILEFULL=${INDIR}${INFILE_GHEP}
numevents=$(sed -n "${linenumber}p" "$neventsfile")
echo "num events ${numevents}"
if [ -e ${INPUT_TAR_DIR_LOCAL}/setup_grid_global.sh ]; then 
    . ${INPUT_TAR_DIR_LOCAL}/setup_grid_global.sh 
else 
  echo "Error, setup script not found. Exiting." 
  exit 1 
fi 

#cd ${_CONDOR_JOB_IWD}
echo $_CONDOR_JOB_IWD 
pwd 

#export IFDH_CP_MAXRETRIES=2 
#export XRD_CONNECTIONRETRY=32 
#export XRD_REQUESTTIMEOUT=14400 
#export XRD_REDIRECTLIMIT=255 
#export XRD_LOADBALANCERTTL=7200 
#export XRD_STREAMTIMEOUT=14400 

ifdh ls $OUTDIR 0 
if [ $? -ne 0 ]; then 
    ifdh mkdir_p $OUTDIR || { echo "Error creating or checking $OUTDIR"; exit 2; } 
fi 

if [ -e ${INPUT_TAR_DIR_LOCAL}/setup_grid_genie.sh ]; then 
    . ${INPUT_TAR_DIR_LOCAL}/setup_grid_genie.sh 
else 
  echo "Error, GENIE setup script not found. Exiting." 
  exit 1 
fi 
export GXMLPATH=/cvmfs/larsoft.opensciencegrid.org/products/genie/v3_04_00d/Linux64bit+3.10-2.17-e26-prof/GENIE-Generator/config/G18_02a/
#gevgen_fnal -f ${INPUT_TAR_DIR_LOCAL}/jobsubdir/flux_files/gsimple*,DUNEND -g ${INPUT_TAR_DIR_LOCAL}/jobsubdir/geometries/nd_hall_mpd_only_ECal12sides_42l_SPY_v3_wMuID.gdml -t volGArTPC -L cm -D g_cm3 -n 100 --seed 10000${PROCESS} -r ${RUN} -o neutrino_gar --message-thresholds ${ND_PRODUCTION_CONFIG}/Messenger_production.xml --event-record-print-level 0 --cross-sections $GENIEXSECFILETOUSE --tune $GENIE_XSEC_TUNE 

#GENIE_RESULT=$? 
#if [ $GENIE_RESULT -ne 0 ]; then 
#    echo "GENIE exited with abnormal status $GENIE_RESULT. See error outputs." 
#    exit $GENIE_RESULT 
#fi 

#pwd

#cp neutrino_gar.10000.ghep_rad200.root $OUTFILE_GENIE 
#ifdh cp -D $OUTFILE_GENIE $OUTDIR 

IFDH_RESULT=$? 
if [ $IFDH_RESULT -ne 0 ]; then 
    echo "Error during output copyback. See output logs." 
    exit $IFDH_RESULT 
fi 

#rm $OUTFILE_GENIE 

if [ -e ${INPUT_TAR_DIR_LOCAL}/setup_grid_gsft.sh ]; then 
    . ${INPUT_TAR_DIR_LOCAL}/setup_grid_gsft.sh 
else 
  echo "Error, GArSoft setup script not found. Exiting." 
  exit 1 
fi 

cp ${INPUT_TAR_DIR_LOCAL}/conversion_to_gsft.fcl ${_CONDOR_SCRATCH_DIR}/conversion_to_gsft_${PROCESS}.fcl 
sed -i 's\path_to_ghep\'"${INPUTFILEFULL}"'\' ${_CONDOR_SCRATCH_DIR}/conversion_to_gsft_${PROCESS}.fcl
sed -i 's\path_to_edep\\' ${_CONDOR_SCRATCH_DIR}/conversion_to_gsft_${PROCESS}.fcl
cat ${_CONDOR_SCRATCH_DIR}/conversion_to_gsft_${PROCESS}.fcl
art -c ${_CONDOR_SCRATCH_DIR}/conversion_to_gsft_${PROCESS}.fcl -n $numevents -o ${_CONDOR_SCRATCH_DIR}/genie_${PROCESS}.root 
RESULT=$? 
if [ $RESULT -ne 0 ]; then 
    echo "GArSoft (conversion) exited with abnormal status $RESULT. See error outputs." 
    exit $RESULT 
fi 

art -c rungeant4.fcl ${_CONDOR_SCRATCH_DIR}/genie_${PROCESS}.root -n -1 -o ${_CONDOR_SCRATCH_DIR}/genie_g4_${PROCESS}.root 
RESULT=$? 
if [ $RESULT -ne 0 ]; then 
    echo "GArSoft (GArG4) exited with abnormal status $RESULT. See error outputs." 
    exit $RESULT 
fi 

art -c readoutsimjob.fcl ${_CONDOR_SCRATCH_DIR}/genie_g4_${PROCESS}.root -n -1 -o ${_CONDOR_SCRATCH_DIR}/readoutsim_${PROCESS}.root 
RESULT=$? 
if [ $RESULT -ne 0 ]; then 
    echo "GArSoft (readoutsim) exited with abnormal status $RESULT. See error outputs." 
    exit $RESULT 
fi 

art -c recojob_trackecalassn2.fcl ${_CONDOR_SCRATCH_DIR}/readoutsim_${PROCESS}.root -n -1 -o ${_CONDOR_SCRATCH_DIR}/reco_${PROCESS}.root 
RESULT=$? 
if [ $RESULT -ne 0 ]; then 
    echo "GArSoft (reco) exited with abnormal status $RESULT. See error outputs." 
    exit $RESULT 
fi 

art -c recoparticlesjob.fcl ${_CONDOR_SCRATCH_DIR}/reco_${PROCESS}.root -n -1 -o ${_CONDOR_SCRATCH_DIR}/reco2_${PROCESS}.root 
RESULT=$? 
if [ $RESULT -ne 0 ]; then 
    echo "GArSoft (recoparticles) exited with abnormal status $RESULT. See error outputs." 
    exit $RESULT 
fi 

art -c anajob.fcl ${_CONDOR_SCRATCH_DIR}/reco2_${PROCESS}.root -n -1 
if [ -e ${INPUT_TAR_DIR_LOCAL}/setup_grid_global.sh ]; then 
    . ${INPUT_TAR_DIR_LOCAL}/setup_grid_global.sh 
else 
  echo "Error, setup script not found. Exiting." 
  exit 1 
fi 

cp anatree.root $OUTDIR/$OUTFILE_ANA 
#ifdh cp -D $OUTFILE_ANA $OUTDIR 

IFDH_RESULT=$? 
if [ $IFDH_RESULT -ne 0 ]; then 
    echo "Error during output copyback. See output logs." 
    exit $IFDH_RESULT 
fi 

echo "Completed successfully." 
exit 0 

