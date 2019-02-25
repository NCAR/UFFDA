#!/bin/csh
###############################################
#
# Oirg. Code: Ka Yee Wong  (NOAA/GSD) Jun  2017
# Edit. Code: Ka Yee Wong  (NOAA/GSD) Feb  2019
# Tested on Theia:                    Feb  2019
# Tested on cheyenne:                 Feb  2019
# Tested on Hydra by Tracy:           Feb  2019
#
###############################################
# Run at background:
# # > qsub run.pbs
# # Want to terminate/kill the job:
# # > qstat
# # or
# # > ps
# # > qdel job ID
###############################################
###############################################
#!!!!!!!!!!!!!!User Define Here!!!!!!!!!!!!!!!#
###############################################
 set FILE_NAME = "DTC_UPP_vlab"   # should match the FILE_NAME from compile.sh
 #set FILE_NAME = "DTC_UPP_github_crtm"   # should match the FILE_NAME from compile.sh
 #set FILE_NAME = "DTC_UPP_local_path_test"
 set outFormat = 'grib2' # 'grib' or 'grib2'
 set RunPath = '/gpfs/fs1/work/kayee/UPP/UFFDA/GITHUB/fv3/' #Set your path for the test case results to be located
 #set RunPath = '/scratch3/BMC/det/KaYee/UFFDA/' #Set your path for the test case results to be located
 set numR  = 11 # # of test cases
 set COMPUTER_OPTION = "cheyenne" # theia/cheyenne/hydra for now
 set CONFIG_OPTION = (3 4 7 8) #1)PGI(serial) 2)PGI(dmpar) 3)Intel(serial) 4)Intel(dmpar) 7)GNU(serial) 8)GNU(dmpar) 11)GNU(serial) on Hydra 12)GNU(dmpar) on Hydra
 set DataPath = '/gpfs/fs1/p/ral/jntp/UPP/data/wrf2008/'
 set ExtraPath = '/gpfs/fs1/p/ral/jntp/UPP/public/'
 set CNTLPath='/gpfs/fs1/p/ral/jntp/UPP/UFFDA/bench_mark'
 #set DataPath = '/scratch4/BMC/dtc/KaYee/UPP/UPPdata/wrf2008/'
 #set ExtraPath = '/scratch4/BMC/dtc/KaYee/UPP/public/'
 #set CNTLPath='/scratch3/BMC/det/KaYee/UFFDA/bench_mark'
 #set lastfhr  = 24
 #set sleepT = 5
 #set sleepR = 60
 #set sleepRlong = 600
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
 eval set postexec = ${UPPPath}\'/bin\'
 echo $CasesDir
 if($COMPUTER_OPTION == "theia" || $COMPUTER_OPTION == "THEIA") then
 module purge
 module load intel/16.1.150
 module load impi
 module load netcdf/3.6.3
 module load grads
 echo 'CONFIG_OPTION IS MPI ' $CONFIG_OPTION[$ii]
 set run_line='"mpirun -np 4  '${postexec}'/unipost.exe'
 sed -i -e "/export/s|RUN_COMMAND=[^ ]*|RUN_COMMAND=$run_line|" run_unipostandgrads
 else if($COMPUTER_OPTION == "cheyenne" || $COMPUTER_OPTION == "CHEYENNE") then
 module purge
 module load intel mpt netcdf ncarcompilers
 #setenv LD_LIBRARY_PATH "${LD_LIBRARY_PATH}:/glade/u/apps/ch/opt/netcdf/4.6.1/intel/17.0.1/lib"
 echo 'CONFIG_OPTION IS MPI ' $CONFIG_OPTION[$ii]
 set run_line='"mpiexec_mpt '${postexec}'/unipost.exe'
 else if($COMPUTER_OPTION == "hydra" || $COMPUTER_OPTION == "HYDRA") then
# source /home/hertneky/wheezy-intel.csh
# echo 'Note: No WRF bulit on hydra with Intel!!'
 echo 'CONFIG_OPTION IS MPI ' $CONFIG_OPTION[$ii]
 set run_line='"mpirun -machinefile machfile -np 6 '${postexec}'/unipost.exe'
 endif
 else if($CONFIG_OPTION[$ii] == 3)then
 rm -rf ${FILE_NAME}_test_cases_Intel_serial_${outFormat}
 mkdir ${FILE_NAME}_test_cases_Intel_serial_${outFormat}
 cd ${FILE_NAME}_test_cases_Intel_serial_${outFormat}
 eval set UPPPath = ${RunPath}\'${FILE_NAME}_Intel_serial/\'
 eval set CasesDir = ${RunPath}\'${FILE_NAME}_test_cases_Intel_serial_${outFormat}/\'
 eval set postexec = ${UPPPath}\'/bin\'
 set run_line='" '${postexec}'/unipost.exe'
 echo 'CONFIG_OPTION IS SERIAL ' $CONFIG_OPTION[$ii]
 if($COMPUTER_OPTION == "theia" || $COMPUTER_OPTION == "THEIA") then
 module purge
 module load intel/16.1.150
 module load netcdf/3.6.3
 module load grads
 else if($COMPUTER_OPTION == "cheyenne" || $COMPUTER_OPTION == "CHEYENNE") then
 module purge
 module load intel netcdf ncarcompilers
 else if($COMPUTER_OPTION == "hydra" || $COMPUTER_OPTION == "HYDRA") then
# source /home/hertneky/wheezy-intel.csh
#echo 'Note: No WRF bulit on hydra with Intel!!'
 endif
 else if($CONFIG_OPTION[$ii] == 7 || $CONFIG_OPTION[$ii] == 11)then
 rm -rf ${FILE_NAME}_test_cases_GNU_serial_${outFormat}
 mkdir ${FILE_NAME}_test_cases_GNU_serial_${outFormat}
 cd ${FILE_NAME}_test_cases_GNU_serial_${outFormat}
 eval set UPPPath = ${RunPath}\'${FILE_NAME}_GNU_serial/\'
 eval set CasesDir = ${RunPath}\'${FILE_NAME}_test_cases_GNU_serial_${outFormat}/\'
 eval set postexec = ${UPPPath}\'/bin\'
 set run_line='" '${postexec}'/unipost.exe'
 echo 'CONFIG_OPTION IS SERIAL ' $CONFIG_OPTION[$ii]
 if($COMPUTER_OPTION == "theia" || $COMPUTER_OPTION == "THEIA") then
# echo 'Note: No WRF serial GNU bulit on Theia!!'
 module purge
 module load gnu netcdf 
 module load grads
 else if($COMPUTER_OPTION == "cheyenne" || $COMPUTER_OPTION == "CHEYENNE") then
 module purge
 module load gnu netcdf ncarcompilers
 module load grads
 else if($COMPUTER_OPTION == "hydra" || $COMPUTER_OPTION == "HYDRA") then
# source /home/hertneky/wheezy-gf.csh
 endif
 else if($CONFIG_OPTION[$ii] == 8 || $CONFIG_OPTION[$ii] == 12)then
 rm -rf ${FILE_NAME}_test_cases_GNU_dmpar_${outFormat}
 mkdir ${FILE_NAME}_test_cases_GNU_dmpar_${outFormat}
 cd ${FILE_NAME}_test_cases_GNU_dmpar_${outFormat}
 eval set UPPPath = ${RunPath}\'${FILE_NAME}_GNU_dmpar/\'
 eval set CasesDir = ${RunPath}\'${FILE_NAME}_test_cases_GNU_dmpar_${outFormat}/\'
 eval set postexec = ${UPPPath}\'/bin\'
 echo 'CONFIG_OPTION IS MPI ' $CONFIG_OPTION[$ii]
 if($COMPUTER_OPTION == "theia" || $COMPUTER_OPTION == "THEIA") then
 echo 'Note: No WRF parallel GNU bulit on Theia!!'
 module purge
 module load gnu mpi netcdf 
 module load grads
 else if($COMPUTER_OPTION == "cheyenne" || $COMPUTER_OPTION == "CHEYENNE") then
 module purge
 module load gnu mpt netcdf ncarcompilers
 module load grads
 module load mpt
 set run_line='"mpiexec_mpt '${postexec}'/unipost.exe'
 else if($COMPUTER_OPTION == "hydra" || $COMPUTER_OPTION == "HYDRA") then
# source /home/hertneky/wheezy-gf.csh
 set run_line='"mpirun -machinefile machfile -np 6 '${postexec}'/unipost.exe'
 endif
 else if($CONFIG_OPTION[$ii] == 2)then
 rm -rf ${FILE_NAME}_test_cases_PGI_dmpar_${outFormat}
 mkdir ${FILE_NAME}_test_cases_PGI_dmpar_${outFormat}
 cd ${FILE_NAME}_test_cases_PGI_dmpar_${outFormat}
 eval set UPPPath = ${RunPath}\'${FILE_NAME}_PGI_dmpar/\'
 eval set CasesDir = ${RunPath}\'${FILE_NAME}_test_cases_PGI_dmpar_${outFormat}/\'
 eval set postexec = ${UPPPath}\'/bin\'
 echo 'CONFIG_OPTION IS MPI ' $CONFIG_OPTION[$ii]
 if($COMPUTER_OPTION == "theia" || $COMPUTER_OPTION == "THEIA") then
 module purge
 module load pgi/17.1
 module load mvapich2/2.1rc1
 module load netcdf/3.6.3
 module load grads
 set run_line='"mpirun -np 4  '${postexec}'/unipost.exe'
 else if($COMPUTER_OPTION == "cheyenne" || $COMPUTER_OPTION == "CHEYENNE") then
 module purge
 module load pgi mpt netcdf ncarcompilers
 module load grads
 module load mpt
 set run_line='"mpiexec_mpt '${postexec}'/unipost.exe'
 else if($COMPUTER_OPTION == "hydra" || $COMPUTER_OPTION == "HYDRA") then
# source /home/hertneky/wheezy-pgi.csh
 set run_line='"mpirun -machinefile machfile -np 6 '${postexec}'/unipost.exe'
 endif
 else if($CONFIG_OPTION[$ii] == 1)then
 rm -rf ${FILE_NAME}_test_cases_PGI_serial_${outFormat}
 mkdir ${FILE_NAME}_test_cases_PGI_serial_${outFormat}
 cd ${FILE_NAME}_test_cases_PGI_serial_${outFormat}
 eval set UPPPath = ${RunPath}\'${FILE_NAME}_PGI_serial/\'
 eval set CasesDir = ${RunPath}\'${FILE_NAME}_test_cases_PGI_serial_${outFormat}/\'
 eval set postexec = ${UPPPath}\'/bin\'
 set run_line='" '${postexec}'/unipost.exe'
 echo 'CONFIG_OPTION IS SERIAL ' $CONFIG_OPTION[$ii]
 if($COMPUTER_OPTION == "theia" || $COMPUTER_OPTION == "THEIA") then
 module purge
 module load pgi/17.1
 module load netcdf/3.6.3
 module load grads
 else if($COMPUTER_OPTION == "cheyenne" || $COMPUTER_OPTION == "CHEYENNE") then
 module purge
 module load pgi netcdf ncarcompilers
 module load grads
 else if($COMPUTER_OPTION == "hydra" || $COMPUTER_OPTION == "HYDRA") then
# source /home/hertneky/wheezy-pgi.csh
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
       ($bb == 10 && $CONFIG_OPTION[$ii] == 1) ||\
       ($bb == 11 && $CONFIG_OPTION[$ii] == 3) ||\
       ($bb == 11 && $CONFIG_OPTION[$ii] == 7) ||\
       ($bb == 11 && $CONFIG_OPTION[$ii] == 1) )) then
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
 #ln -svf $UPPPath/parm/postxconfig-NT_WRF.txt .
 ln -svf $UPPPath/parm/postxconfig-NT-WRF.txt .
 ln -svf $UPPPath/parm/postxconfig-NT-GFS.txt .
 cd ..
 mkdir postprd
 cd postprd
 ln -svf $ExtraPath/*.pl .
 if($COMPUTER_OPTION == "cheyenne" || $COMPUTER_OPTION == "CHEYENNE" ||\
    $COMPUTER_OPTION == "hydra"    || $COMPUTER_OPTION == "HYDRA" ) then
 ln -svf $ExtraPath/wgrib2 .
 ln -svf $ExtraPath/wgrib .  
 else if($COMPUTER_OPTION == "theia" || $COMPUTER_OPTION == "THEIA") then
 module load wgrib wgrib2/0.2.0.6c
 #cp $ExtraPath/run_mpi.pbs.theia run_mpi.pbs
 #cp $ExtraPath/run_mpi_rt.pbs.theia run_mpi_rt.pbs
 endif
 cp $UPPPath/scripts/run_unipostandgrads .
 ln -svf $ExtraPath/run_mpi.pbs .
 ln -svf $ExtraPath/run_mpi_rt.pbs .
 eval set DataCase = ${DataPath}\'ps\'${bb}
 echo $DataCase
 set lastfhr  = 18
 set dom = 'd01'
 eval set tag = 'WRFPRS_'${dom}
 if($bb <= 10)then
 set dyncore = 'ARW'
 set inFormat = 'netcdf'
 #set txtCntrlFile = 'postxconfig-NT_WRF.txt'
 set txtCntrlFile = 'postxconfig-NT-WRF.txt'
 else if($bb == 11)then
 #rm postxconfig-NT-WRF.txt
 #ln -svf postxconfig-NT-GFS.txt postxconfig-NT-WRF.txt
 set dyncore = 'FV3'
 set inFormat = 'binarynemsio'
 set txtCntrlFile = 'postxconfig-NT-GFS.txt'
 endif
 if($bb <= 6)then
 set startdate = '2008011100'
 else if($bb == 7)then
 set startdate = '2009121712'
 else if($bb == 8)then
 set startdate = '2012102900'
 else if($bb == 9)then
 set startdate = '2012102900'
 else if($bb == 10)then
 set startdate = '2018010700' #hi-res case
 set lastfhr  = 6
 rm run_mpi.pbs
 ln -svf $ExtraPath/run_mpi_hi.pbs run_mpi.pbs
 else if($bb == 11)then
 set startdate = '2016100300' #hi-res case
 set tag = 'GFSPRS'
 set lastfhr  = 6
 rm run_mpi.pbs
 #if($outFormat == "grib")then
 ln -svf $ExtraPath/run_mpi_hi.pbs run_mpi.pbs
 #endif
 endif
 eval set DOMAINPATH = ${CasesDir}${case}
 echo $DOMAINPATH
 sed -i -e "/export/s|RUN_COMMAND=[^ ]*|RUN_COMMAND=$run_line|" run_unipostandgrads
 sed -i -e "/export/s|txtCntrlFile=[^ ]*|txtCntrlFile=$UPPPath/parm/$txtCntrlFile|" run_unipostandgrads
 sed -i -e "/export/s|dyncore=[^ ]*|dyncore=$dyncore|" run_unipostandgrads
 sed -i -e "/export/s|inFormat=[^ ]*|inFormat=$inFormat|" run_unipostandgrads
 sed -i -e "/export/s|outFormat=[^ ]*|outFormat=$outFormat|" run_unipostandgrads
 sed -i -e "/export/s|TOP_DIR=[^ ]*|TOP_DIR=$RunPath|" run_unipostandgrads
 sed -i -e "/export/s|DOMAINPATH=[^ ]*|DOMAINPATH=$DOMAINPATH|" run_unipostandgrads
 sed -i -e "/export/s|UNIPOST_HOME=[^ ]*|UNIPOST_HOME=$UPPPath|" run_unipostandgrads
 sed -i -e "/export/s|POSTEXEC=[^ ]*|POSTEXEC=$postexec|" run_unipostandgrads
 sed -i -e "/export/s|modelDataPath=[^ ]*|modelDataPath=$DataCase|" run_unipostandgrads
 sed -i -e "/export/s|startdate=[^ ]*|startdate=$startdate|" run_unipostandgrads
 sed -i -e "/export/s|lastfhr=[^ ]*|lastfhr=$lastfhr|" run_unipostandgrads
 if($bb == 10 || $bb == 11)then
 #set domain_list = 'd02'
 set incrementhr = '01'
 #sed -i -e "/export/s|domain_list=[^ ]*|domain_list=$domain_list|" run_unipostandgrads
 sed -i -e "/export/s|incrementhr=[^ ]*|incrementhr=$incrementhr|" run_unipostandgrads
 #set dom = 'd02'
 #else
 #set dom = 'd01'
 endif

 #cp $ExtraPath/run_rt.pbs .

 #sleep $sleepT
 
 if($outFormat == "grib2")then
 if($bb <= 9)then
 ln -svf $ExtraPath/run_mpi_rt.pbs run_mpi.pbs
 else if($bb == 10 || $bb == 11)then
 ln -svf $ExtraPath/run_mpi_rt_hi.pbs run_mpi.pbs
 endif
 #ln -svf $ExtraPath/cmp_grib2_grib2.sh .
 cp $ExtraPath/run_rt.pbs .
 if($CONFIG_OPTION[$ii] == 3)then
 eval set CNTLCase = ${CNTLPath}/Intel_serial/\'ps\'${bb}
 else if($CONFIG_OPTION[$ii] == 4)then
 eval set CNTLCase = ${CNTLPath}/Intel_dmpar/\'ps\'${bb}
 else if($CONFIG_OPTION[$ii] == 7 || $CONFIG_OPTION[$ii] == 11)then
 eval set CNTLCase = ${CNTLPath}/GNU_serial/\'ps\'${bb}
 else if($CONFIG_OPTION[$ii] == 8 || $CONFIG_OPTION[$ii] == 12)then
 eval set CNTLCase = ${CNTLPath}/GNU_dmpar/\'ps\'${bb}
 else if($CONFIG_OPTION[$ii] == 1)then
 eval set CNTLCase = ${CNTLPath}/PGI_serial/\'ps\'${bb}
 else if($CONFIG_OPTION[$ii] == 2)then
 eval set CNTLCase = ${CNTLPath}/PGI_dmpar/\'ps\'${bb}
 endif
 echo 'CNTLCase =' $CNTLCase
 ln -svf $CNTLCase/* .
 #if($bb == 10)then
 #sleep $sleepRlong
 #else
 #sleep $sleepR
 #endif
 set cc = 0
 while ($cc <= 18)
 eval set cmp_line='\.\/wgrib2\ $CNTLCase/CNTL_$tag\.${cc}\ -var\ -lev\ -rpn\ sto_1\ -import_grib\ $DOMAINPATH/postprd/$tag\.${cc}\ -rpn\ rcl_1:print_corr:print_rms\ \>\ reg_test\.${cc}\.txt'
 if($COMPUTER_OPTION == "theia" || $COMPUTER_OPTION == "THEIA")then
 eval set cmp_line='wgrib2\ $CNTLCase/CNTL_$tag\.${cc}\ -var\ -lev\ -rpn\ sto_1\ -import_grib\ $DOMAINPATH/postprd/$tag\.${cc}\ -rpn\ rcl_1:print_corr:print_rms\ \>\ reg_test\.${cc}\.txt'
 endif #COMPUTER_OPTION
 if($cc <= 9)then
 eval set ending = \'0\'${cc}
 eval set cmp_line='\.\/wgrib2\ $CNTLCase/CNTL_$tag\.${ending}\ -var\ -lev\ -rpn\ sto_1\ -import_grib\ $DOMAINPATH/postprd/$tag\.${ending}\ -rpn\ rcl_1:print_corr:print_rms\ \>\ reg_test\.${ending}\.txt'
 if($COMPUTER_OPTION == "theia" || $COMPUTER_OPTION == "THEIA")then
 eval set cmp_line='wgrib2\ $CNTLCase/CNTL_$tag\.${ending}\ -var\ -lev\ -rpn\ sto_1\ -import_grib\ $DOMAINPATH/postprd/$tag\.${ending}\ -rpn\ rcl_1:print_corr:print_rms\ \>\ reg_test\.${ending}\.txt'
 endif #if computer_option
 endif
 #sed -i '/wgrib2/c\'"$cmp_line" run_rt.pbs
 echo $cmp_line >> add.txt
 #sleep $sleepT
 #qsub ./run_rt.pbs
 if($bb == 10 || $bb == 11)then
  if($cc >= 6)break
 @ cc ++
 else
 @ cc += 3
 endif #if $bb == 10 || $bb == 11
 end #while loop
 sed -i '/#wgrib2/r add.txt' run_rt.pbs
 endif #if grib

 if($COMPUTER_OPTION == "theia" || $COMPUTER_OPTION == "THEIA")then
 sed -i 's;^cd .*;cd '"$DOMAINPATH/postprd/"';' run_mpi.pbs
 sed -i 's;^cd .*;cd '"$DOMAINPATH/postprd/"';' run_rt.pbs
 qsub ./run_mpi.pbs
 #qsub ./run_rt.pbs
 else if($COMPUTER_OPTION == "cheyenne" || $COMPUTER_OPTION == "CHEYENNE")then
 qsub ./run_mpi.pbs
 echo 'submit jobs'
 else if($COMPUTER_OPTION == "hydra" || $COMPUTER_OPTION == "HYDRA")then
 ./run_unipostandgrads
 endif

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

