#!/bin/csh
###############################################
#
# Oirg. Code: Ka Yee Wong  (NOAA/GSD) Jun  2017
# Edit. Code: Ka Yee Wong  (NOAA/GSD) Nov  2018
# Tested on Theia:                    Jun  2017
# Tested on cheyenne:                 Nov  2018
# Tested on Hydra by Tracy:           Nov  2018
#
###############################################
# Run at background:
# # > run.csh > & runout &
# # Want to terminate/kill the job:
# # > jobs
# # > kill %1
# # or
# # > ps
# # > kill -9 PID
###############################################
###############################################
#!!!!!!!!!!!!!!User Define Here!!!!!!!!!!!!!!!#
###############################################
 set FILE_NAME = "DTC_UPP_github_crtm"   # should match the FILE_NAME from compile.sh
 #set FILE_NAME = "DTC_UPP_local_path_test"
 set outFormat = 'grib2' # 'grib' or 'grib2'
 set RunPath = '/gpfs/fs1/work/kayee/tmp/' #Set your path for the test case results to be located
 set numR  = 2  # # of test cases
 set COMPUTER_OPTION = "cheyenne" # theia/cheyenne/hydra for now
 set CONFIG_OPTION = (3 4 7 8) #1)PGI(serial) 2)PGI(dmpar) 3)Intel(serial) 4)Intel(dmpar) 7)GNU(serial) 8)GNU(dmpar) 11)GNU(serial) on Hydra 12)GNU(dmpar) on Hydra
 set DataPath = '/gpfs/fs1/p/ral/jntp/UPP/data/wrf2008/'
 set ExtraPath = '/gpfs/fs1/p/ral/jntp/UPP/public/'
 set lastfhr  = 18
 #set lastfhr  = 24
 set sleepT = 5
#
###############################################
###############################################
#!!!!!!!!!STOP User Define Here!!!!!!!!!!!!!!!#
###############################################
###############################################
 set NUM_CONFIG = $#CONFIG_OPTION  # # of configurations
 set ii = 1
 while ($ii <= $NUM_CONFIG)
 if($CONFIG_OPTION[$ii] == 4)then
 rm -rf ${FILE_NAME}_test_cases_Intel_dmpar_${outFormat}
 mkdir ${FILE_NAME}_test_cases_Intel_dmpar_${outFormat}
 cd ${FILE_NAME}_test_cases_Intel_dmpar_${outFormat}
 eval set UPPPath = ${RunPath}\'${FILE_NAME}_Intel_dmpar/\'
 eval set CasesDir = ${RunPath}\'${FILE_NAME}_test_cases_Intel_dmpar_${outFormat}/\'
 echo $CasesDir
 if($COMPUTER_OPTION == "theia" || $COMPUTER_OPTION == "THEIA") then
 module purge
 module load intel/16.1.150
 module load impi
 module load netcdf/3.6.3
 set WRF_DIR='/scratch3/BMC/wrf-chem/KaYee/PRECOMPILED_WRF/WRFV3.9_Intel_dmpar_large-file'
 else if($COMPUTER_OPTION == "cheyenne" || $COMPUTER_OPTION == "CHEYENNE") then
 module purge
 module load intel mpt netcdf ncarcompilers
 #setenv LD_LIBRARY_PATH "${LD_LIBRARY_PATH}:/glade/u/apps/ch/opt/netcdf/4.6.1/intel/17.0.1/lib"
 set WRF_DIR='/gpfs/fs1/p/ral/jntp/UPP/PRE_COMPILED_CODE/WRFV3.9_Intel_dmpar_large-file'
 else if($COMPUTER_OPTION == "hydra" || $COMPUTER_OPTION == "HYDRA") then
#source /home/hertneky/wheezy-intel.csh
 echo 'Note: No WRF bulit on hydra with Intel!!'
 endif
 else if($CONFIG_OPTION[$ii] == 3)then
 rm -rf ${FILE_NAME}_test_cases_Intel_serial_${outFormat}
 mkdir ${FILE_NAME}_test_cases_Intel_serial_${outFormat}
 cd ${FILE_NAME}_test_cases_Intel_serial_${outFormat}
 eval set UPPPath = ${RunPath}\'${FILE_NAME}_Intel_serial/\'
 eval set CasesDir = ${RunPath}\'${FILE_NAME}_test_cases_Intel_serial_${outFormat}/\'
 if($COMPUTER_OPTION == "theia" || $COMPUTER_OPTION == "THEIA") then
 module purge
 module load intel/16.1.150
 module load netcdf/3.6.3
 set WRF_DIR='/scratch3/BMC/wrf-chem/KaYee/PRECOMPILED_WRF/WRFV3.9_Intel_serial_large-file/'
 else if($COMPUTER_OPTION == "cheyenne" || $COMPUTER_OPTION == "CHEYENNE") then
 module purge
 module load intel netcdf ncarcompilers
 set WRF_DIR='/gpfs/fs1/p/ral/jntp/UPP/PRE_COMPILED_CODE/WRFV3.9_Intel_serial_large-file'
 else if($COMPUTER_OPTION == "hydra" || $COMPUTER_OPTION == "HYDRA") then
 #source /home/hertneky/wheezy-intel.csh
 echo 'Note: No WRF bulit on hydra with Intel!!'
 endif
 else if($CONFIG_OPTION[$ii] == 7 || $CONFIG_OPTION[$ii] == 11)then
 rm -rf ${FILE_NAME}_test_cases_GNU_serial_${outFormat}
 mkdir ${FILE_NAME}_test_cases_GNU_serial_${outFormat}
 cd ${FILE_NAME}_test_cases_GNU_serial_${outFormat}
 eval set UPPPath = ${RunPath}\'${FILE_NAME}_GNU_serial/\'
 eval set CasesDir = ${RunPath}\'${FILE_NAME}_test_cases_GNU_serial_${outFormat}/\'
 if($COMPUTER_OPTION == "theia" || $COMPUTER_OPTION == "THEIA") then
 echo 'Note: No WRF serial GNU bulit on Theia!!'
 else if($COMPUTER_OPTION == "cheyenne" || $COMPUTER_OPTION == "CHEYENNE") then
 module purge
 module load gnu netcdf ncarcompilers
 set WRF_DIR='/gpfs/fs1/p/ral/jntp/UPP/PRE_COMPILED_CODE/WRFV3.9_GNU_serial_large-file'
 module load grads
 else if($COMPUTER_OPTION == "hydra" || $COMPUTER_OPTION == "HYDRA") then
 source /home/hertneky/wheezy-gf.csh
 set WRF_DIR='/d1/hertneky/wtf_upp/Builds/WRFV3.7.1.32/em_real/WRFV3'
 endif
 else if($CONFIG_OPTION[$ii] == 8 || $CONFIG_OPTION[$ii] == 12)then
 rm -rf ${FILE_NAME}_test_cases_GNU_dmpar_${outFormat}
 mkdir ${FILE_NAME}_test_cases_GNU_dmpar_${outFormat}
 cd ${FILE_NAME}_test_cases_GNU_dmpar_${outFormat}
 eval set UPPPath = ${RunPath}\'${FILE_NAME}_GNU_dmpar/\'
 eval set CasesDir = ${RunPath}\'${FILE_NAME}_test_cases_GNU_dmpar_${outFormat}/\'
 if($COMPUTER_OPTION == "theia" || $COMPUTER_OPTION == "THEIA") then
 echo 'Note: No WRF parallel GNU bulit on Theia!!'
 else if($COMPUTER_OPTION == "cheyenne" || $COMPUTER_OPTION == "CHEYENNE") then
 module purge
 module load gnu mpt netcdf ncarcompilers
 set WRF_DIR='/gpfs/fs1/p/ral/jntp/UPP/PRE_COMPILED_CODE/WRFV3.9_GNU_dmpar_large-file'
 module load grads
 module load mpt
 else if($COMPUTER_OPTION == "hydra" || $COMPUTER_OPTION == "HYDRA") then
 source /home/hertneky/wheezy-gf.csh
 set WRF_DIR='/d1/hertneky/wtf_upp/Builds/WRFV3.7.1.34/em_real/WRFV3'
 endif
 else if($CONFIG_OPTION[$ii] == 2)then
 rm -rf ${FILE_NAME}_test_cases_PGI_dmpar_${outFormat}
 mkdir ${FILE_NAME}_test_cases_PGI_dmpar_${outFormat}
 cd ${FILE_NAME}_test_cases_PGI_dmpar_${outFormat}
 eval set UPPPath = ${RunPath}\'${FILE_NAME}_PGI_dmpar/\'
 eval set CasesDir = ${RunPath}\'${FILE_NAME}_test_cases_PGI_dmpar_${outFormat}/\'
 if($COMPUTER_OPTION == "theia" || $COMPUTER_OPTION == "THEIA") then
 module purge
 module load pgi/17.1
 module load mvapich2/2.1rc1
 module load netcdf/3.6.3
 set WRF_DIR='/scratch3/BMC/wrf-chem/KaYee/PRECOMPILED_WRF/WRFV3.9_PGI_dmpar_large-file/'
 else if($COMPUTER_OPTION == "cheyenne" || $COMPUTER_OPTION == "CHEYENNE") then
 module purge
 module load pgi mpt netcdf ncarcompilers
 set WRF_DIR='/gpfs/fs1/p/ral/jntp/UPP/PRE_COMPILED_CODE/WRFV3.9_PGI_dmpar_large-file'
 module load grads
 module load mpt
 else if($COMPUTER_OPTION == "hydra" || $COMPUTER_OPTION == "HYDRA") then
 source /home/hertneky/wheezy-pgi.csh
 set WRF_DIR='/d1/hertneky/wtf_upp/Builds/WRFV3.7.1.3/em_real/WRFV3'
 endif
 else if($CONFIG_OPTION[$ii] == 1)then
 rm -rf ${FILE_NAME}_test_cases_PGI_serial_${outFormat}
 mkdir ${FILE_NAME}_test_cases_PGI_serial_${outFormat}
 cd ${FILE_NAME}_test_cases_PGI_serial_${outFormat}
 eval set UPPPath = ${RunPath}\'${FILE_NAME}_PGI_serial/\'
 eval set CasesDir = ${RunPath}\'${FILE_NAME}_test_cases_PGI_serial_${outFormat}/\'
 if($COMPUTER_OPTION == "theia" || $COMPUTER_OPTION == "THEIA") then
 module purge
 module load pgi/17.1
 module load netcdf/3.6.3
 set WRF_DIR='/scratch3/BMC/wrf-chem/KaYee/PRECOMPILED_WRF/WRFV3.9_PGI_serial_large-file/'
 else if($COMPUTER_OPTION == "cheyenne" || $COMPUTER_OPTION == "CHEYENNE") then
 module purge
 module load pgi netcdf ncarcompilers
 set WRF_DIR='/gpfs/fs1/p/ral/jntp/UPP/PRE_COMPILED_CODE/WRFV3.9_PGI_serial_large-file'
 module load grads
 else if($COMPUTER_OPTION == "hydra" || $COMPUTER_OPTION == "HYDRA") then
 source /home/hertneky/wheezy-pgi.csh
 set WRF_DIR='/d1/hertneky/wtf_upp/Builds/WRFV3.7.1.1/em_real/WRFV3'
 endif
 endif
 rm -rf case*
#
 set bb = 1
 while ($bb <= $numR)
 echo 'case '$bb
 echo 'CONFIG_OPTION ' $CONFIG_OPTION[$ii]
 if (( ($bb == 10 && $CONFIG_OPTION[$ii] == 3) ||\
       ($bb == 10 && $CONFIG_OPTION[$ii] == 7) ||\
       ($bb == 10 && $CONFIG_OPTION[$ii] == 1) )) then
 echo '\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!'
 echo '\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!'
 echo '\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!'
 echo '\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!'
 echo '\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!'
 echo '\!\!\!\!NOTE: No high resolution case (case '$bb') will be run with serial mode\!\!\!\!'
 echo '\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!'
 echo '\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!'
 echo '\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!'
 echo '\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!'
 echo '\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!'
 set bb = `echo $bb +1 | bc`
 continue
 else
 eval set case = \'case\'${bb}
 echo $case
 mkdir $case
 cd $case
 mkdir parm
 cd parm
 ln -svf $UPPPath/parm/postcntrl.xml .
 ln -svf $UPPPath/parm/wrf_cntrl.parm .
 ln -svf $UPPPath/parm/postxconfig-NT_WRF.txt .
 cd ..
 mkdir postprd
 cd postprd
 ln -svf $ExtraPath/*.pl .
 ln -svf $ExtraPath/wgrib2 .
 ln -svf $ExtraPath/wgrib .
 cp $UPPPath/scripts/run_unipostandgrads .
 ln -svf $ExtraPath/run_mpi.pbs .
 eval set DataCase = ${DataPath}\'ps\'${bb}
 echo $DataCase
 if($bb <= 6)then
 set startdate = '2008011100'
 else if($bb == 7)then
 set startdate = '2009121712'
 else if($bb == 8)then
 set startdate = '2012102900'
 else if($bb == 9)then
 set startdate = '2012102900'
 else if($bb == 10)then
 set startdate = '2016012200' #hi-res case
 rm run_mpi.pbs
 ln -svf $ExtraPath/run_mpi_hi.pbs run_mpi.pbs
 endif
 eval set DOMAINPATH = ${CasesDir}${case}
 eval set postexec = ${UPPPath}\'/bin\'
 echo $DOMAINPATH
 sed -i -e "/export/s|outFormat=[^ ]*|outFormat=$outFormat|" run_unipostandgrads
 sed -i -e "/export/s|TOP_DIR=[^ ]*|TOP_DIR=$RunPath|" run_unipostandgrads
 sed -i -e "/export/s|DOMAINPATH=[^ ]*|DOMAINPATH=$DOMAINPATH|" run_unipostandgrads
 sed -i -e "/export/s|WRFPATH=[^ ]*|WRFPATH=$WRF_DIR|" run_unipostandgrads
 sed -i -e "/export/s|UNIPOST_HOME=[^ ]*|UNIPOST_HOME=$UPPPath|" run_unipostandgrads
 sed -i -e "/export/s|POSTEXEC=[^ ]*|POSTEXEC=$postexec|" run_unipostandgrads
 sed -i -e "/export/s|modelDataPath=[^ ]*|modelDataPath=$DataCase|" run_unipostandgrads
 sed -i -e "/export/s|startdate=[^ ]*|startdate=$startdate|" run_unipostandgrads
 sed -i -e "/export/s|lastfhr=[^ ]*|lastfhr=$lastfhr|" run_unipostandgrads
 if($bb == 10)then
 set domain_list = 'd02'
 set incrementhr = '01'
 sed -i -e "/export/s|domain_list=[^ ]*|domain_list=$domain_list|" run_unipostandgrads
 sed -i -e "/export/s|incrementhr=[^ ]*|incrementhr=$incrementhr|" run_unipostandgrads
 endif

 if($CONFIG_OPTION[$ii] == 2 ||\
    $CONFIG_OPTION[$ii] == 4 ||\
    $CONFIG_OPTION[$ii] == 8 ||\
    $CONFIG_OPTION[$ii] == 12)then
 echo 'CONFIG_OPTION IS MPI ' $CONFIG_OPTION[$ii]
 if($COMPUTER_OPTION == "theia" || $COMPUTER_OPTION == "THEIA") then
 set run_line='"mpirun -np 4 '${postexec}'/unipost.exe'
 sed -i -e "/export/s|RUN_COMMAND=[^ ]*|RUN_COMMAND=$run_line|" run_unipostandgrads
 else if($COMPUTER_OPTION == "cheyenne" || $COMPUTER_OPTION == "CHEYENNE") then
 set run_line='"mpiexec_mpt '${postexec}'/unipost.exe'
 sed -i -e "/export/s|RUN_COMMAND=[^ ]*|RUN_COMMAND=$run_line|" run_unipostandgrads
 else if($COMPUTER_OPTION == "hydra" || $COMPUTER_OPTION == "HYDRA") then
 set run_line='"mpirun -machinefile machfile -np 6 '${postexec}'/unipost.exe'
 endif
 else
 echo 'CONFIG_OPTION IS SERIAL ' $CONFIG_OPTION[$ii]
 endif

 if($COMPUTER_OPTION == "theia" || $COMPUTER_OPTION == "THEIA" ||\
     $COMPUTER_OPTION == "cheyenne" || $COMPUTER_OPTION == "CHEYENNE") then
 qsub ./run_mpi.pbs
 echo 'submit jobs'
 else if($COMPUTER_OPTION == "hydra" || $COMPUTER_OPTION == "HYDRA") then
 ./run_unipostandgrads
 endif

 sleep $sleepT

 cd ../..

 endif #if ($bb!=10)
 @ bb++
 echo $bb
 end
 cd ..
 @ ii++
 echo $ii
 end
echo 'Exit'
exit

