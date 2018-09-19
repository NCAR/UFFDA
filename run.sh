#!/bin/csh
###############################################
#
# Oirg. Code: Ka Yee Wong  (NOAA/GSD) Jun  2017
# Edit. Code: Ka Yee Wong  (NOAA/GSD) Jul  2017
# Edit. Code: Ka Yee Wong  (NOAA/GSD) Aug  2017
# Edit. Code: Ka Yee Wong (NOAA/GSD) Aug  2018
# Edit. Code: Ka Yee Wong (NOAA/GSD) Sep  2018
# Tested on Theia:                    Jun  2017
# Tested on cheyenne:                 Sep  2018
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
 set TAR_FILE_NAME = "DTC_upp_v3.2"
 set outFormat = 'grib'
 set RunPath = 'your_path'
 set numR  = 10  # # of test cases
 #set CONFIG_OPTION = (4) # 4)Intel(dmpar) 3)Intel(serial) 7)GNU(serial) 8)GNU(dmpar) 1)PGI(serial) 2) PGI(dmpar)
 set CONFIG_OPTION = (3 4 7 8) # 4)Intel(dmpar) 3)Intel(serial) 7)GNU(serial) 8)GNU(dmpar) 1)PGI(serial) 2) PGI(dmpar)
 #set CONFIG_OPTION = (4 3 7 8 1 2) # 4)Intel(dmpar) 3)Intel(serial) 7)GNU(serial) 8)GNU(dmpar) 1)PGI(serial) 2) PGI(dmpar)
 set DataPath = '/gpfs/p/ral/jnt/UPP/data/wrf2008/'
 set ExtraPath = 'your_path'
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
 rm -rf ${TAR_FILE_NAME}_test_cases_Intel_dmpar_${outFormat}
 mkdir ${TAR_FILE_NAME}_test_cases_Intel_dmpar_${outFormat}
 cd ${TAR_FILE_NAME}_test_cases_Intel_dmpar_${outFormat}
 eval set UPPPath = ${RunPath}\'${TAR_FILE_NAME}_Intel_dmpar/\'
 eval set CasesDir = ${RunPath}\'${TAR_FILE_NAME}_test_cases_Intel_dmpar_${outFormat}/\'
 set WRF_DIR = '/gpfs/p/ral/jnt/UPP/PRE_COMPILED_CODE/WRFV3.9_Intel_dmpar_large-file'
 echo $CasesDir
 else if($CONFIG_OPTION[$ii] == 3)then
 rm -rf ${TAR_FILE_NAME}_test_cases_Intel_serial_${outFormat}
 mkdir ${TAR_FILE_NAME}_test_cases_Intel_serial_${outFormat}
 cd ${TAR_FILE_NAME}_test_cases_Intel_serial_${outFormat}
 eval set UPPPath = ${RunPath}\'${TAR_FILE_NAME}_Intel_serial/\'
 eval set CasesDir = ${RunPath}\'${TAR_FILE_NAME}_test_cases_Intel_serial_${outFormat}/\'
 set WRF_DIR = '/gpfs/p/ral/jnt/UPP/PRE_COMPILED_CODE/WRFV3.9_Intel_serial_large-file'
 else if($CONFIG_OPTION[$ii] == 7)then
 rm -rf ${TAR_FILE_NAME}_test_cases_GNU_serial_${outFormat}
 mkdir ${TAR_FILE_NAME}_test_cases_GNU_serial_${outFormat}
 cd ${TAR_FILE_NAME}_test_cases_GNU_serial_${outFormat}
 eval set UPPPath = ${RunPath}\'${TAR_FILE_NAME}_GNU_serial/\'
 eval set CasesDir = ${RunPath}\'${TAR_FILE_NAME}_test_cases_GNU_serial_${outFormat}/\'
 set WRF_DIR = '/gpfs/p/ral/jnt/UPP/PRE_COMPILED_CODE/WRFV3.9_GNU_serial_large-file'
 else if($CONFIG_OPTION[$ii] == 8)then
 rm -rf ${TAR_FILE_NAME}_test_cases_GNU_dmpar_${outFormat}
 mkdir ${TAR_FILE_NAME}_test_cases_GNU_dmpar_${outFormat}
 cd ${TAR_FILE_NAME}_test_cases_GNU_dmpar_${outFormat}
 eval set UPPPath = ${RunPath}\'${TAR_FILE_NAME}_GNU_dmpar/\'
 eval set CasesDir = ${RunPath}\'${TAR_FILE_NAME}_test_cases_GNU_dmpar_${outFormat}/\'
 set WRF_DIR = '/gpfs/p/ral/jnt/UPP/PRE_COMPILED_CODE/WRFV3.9_GNU_dmpar_large-file'
 else if($CONFIG_OPTION[$ii] == 2)then
 rm -rf ${TAR_FILE_NAME}_test_cases_PGI_dmpar_${outFormat}
 mkdir ${TAR_FILE_NAME}_test_cases_PGI_dmpar_${outFormat}
 cd ${TAR_FILE_NAME}_test_cases_PGI_dmpar_${outFormat}
 eval set UPPPath = ${RunPath}\'${TAR_FILE_NAME}_PGI_dmpar/\'
 eval set CasesDir = ${RunPath}\'${TAR_FILE_NAME}_test_cases_PGI_dmpar_${outFormat}/\'
 set WRF_DIR = '/gpfs/p/ral/jnt/UPP/PRE_COMPILED_CODE/WRFV3.9_PGI_dmpar_large-file'
 else if($CONFIG_OPTION[$ii] == 1)then
 rm -rf ${TAR_FILE_NAME}_test_cases_PGI_serial_${outFormat}
 mkdir ${TAR_FILE_NAME}_test_cases_PGI_serial_${outFormat}
 cd ${TAR_FILE_NAME}_test_cases_PGI_serial_${outFormat}
 eval set UPPPath = ${RunPath}\'${TAR_FILE_NAME}_PGI_serial/\'
 eval set CasesDir = ${RunPath}\'${TAR_FILE_NAME}_test_cases_PGI_serial_${outFormat}/\'
 set WRF_DIR = '/gpfs/p/ral/jnt/UPP/PRE_COMPILED_CODE/WRFV3.9_PGI_serial_large-file'
 endif
 rm -rf case*
 module load grads
 module load mpt
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

 if($CONFIG_OPTION[$ii] == 4 || $CONFIG_OPTION[$ii] == 8|| $CONFIG_OPTION[$ii] == 2)then
 echo 'CONFIG_OPTION IS MPI ' $CONFIG_OPTION[$ii]
 set run_line='"mpiexec_mpt '${postexec}'/unipost.exe'
 sed -i -e "/export/s|RUN_COMMAND=[^ ]*|RUN_COMMAND=$run_line|" run_unipostandgrads
 else
 echo 'CONFIG_OPTION IS SERIAL ' $CONFIG_OPTION[$ii]
 endif

 qsub ./run_mpi.pbs

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

