#!/bin/csh
set echo
###############################################
#
# Oirg. Code: Ka Yee Wong  (NOAA/GSD) Jun  2017
# Edit. Code: Ka Yee Wong  (NOAA/GSD) Mar  2020
# Tested on Hera:                     Mar  2020
# Tested on cheyenne:                 Mar  2020
# Tested on puffling by Tracy(NCAR):  Mar  2020
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
 set FILE_NAME = "v4.1.0.beta02"   # should match the FILE_NAME from compile.sh
 #set FILE_NAME = "DTC_UPP_github_crtm"   # should match the FILE_NAME from compile.sh
 set outFormat = 'grib2' # 'grib' or 'grib2'
 #set RunPath = '/scratch2/BMC/det/KaYee/UPP/UFFDA/tmp'
 set RunPath = '/glade/work/kayee/UPP/UFFDA/GITHUB/git_push/UFFDA'
 #set RunPath = '/scratch3/BMC/det/KaYee/UFFDA/' #Set your path for the test case results to be located
 set numR  = 12 # # of test cases
 set COMPUTER_OPTION = "cheyenne" # hera/cheyenne/puffling
 set CONFIG_OPTION = (4 2 8) #1)PGI(serial) 2)PGI(dmpar) 3)Intel(serial) 4)Intel(dmpar) 7)GNU(serial) 8)GNU(dmpar) 
 set DataPath = '/gpfs/fs1/p/ral/jntp/UPP/data/wrf2008/' # settings on Cheyenne
 #set ExtraPath = '/glade/work/kayee/UPP/UFFDA/GITHUB/git_push/UFFDA'
 set ExtraPath = '/gpfs/fs1/p/ral/jntp/UPP/public/'
 set CNTLPath='/gpfs/fs1/p/ral/jntp/UPP/UFFDA/bench_mark'
 #set DataPath = '/scratch1/BMC/dtc/UPP/UPPdata/wrf2008/' # settings on Hera
 #set ExtraPath = '/scratch2/BMC/det/KaYee/UPP/UFFDA/tmp'
 ##set ExtraPath = '/scratch1/BMC/dtc/UPP/public/'
 #set CNTLPath='/scratch1/BMC/dtc/UPP/UFFDA/bench_mark'
 #set DataPath = '/d1/hertneky/upp/data/' # settings on puffling
 #set ExtraPath = $DataPath
 #set CNTLPath=$DataPath/benchmark
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
     eval set UPPPath = ${RunPath}\'/${FILE_NAME}_Intel_dmpar/\'
     eval set CasesDir = ${RunPath}\'/${FILE_NAME}_test_cases_Intel_dmpar_${outFormat}/\'
     echo $CasesDir
     if ($COMPUTER_OPTION == "hera" || $COMPUTER_OPTION == "HERA") then
       module purge
       module load intel/18.0.5.274  impi/2018.0.4  netcdf/4.7.0
       module load grads
     else if($COMPUTER_OPTION == "cheyenne" || $COMPUTER_OPTION == "CHEYENNE") then
       module purge
       module load intel/18.0.5 mpt/2.19 netcdf-mpi/4.6.3 ncarcompilers/0.5.0 pnetcdf/1.11.1
       #module load intel/17.0.1 mpt/2.19 netcdf-mpi/4.6.3 ncarcompilers/0.5.0 pnetcdf/1.11.1
       #setenv LD_LIBRARY_PATH "${LD_LIBRARY_PATH}:/glade/u/apps/ch/opt/netcdf/4.6.1/intel/17.0.1/lib"
     else if($COMPUTER_OPTION == "puffling" || $COMPUTER_OPTION == "PUFFLING") then
       echo 'Note: No Intel on puffling!'
     endif
   else if($CONFIG_OPTION[$ii] == 3)then
     rm -rf ${FILE_NAME}_test_cases_Intel_serial_${outFormat}
     mkdir ${FILE_NAME}_test_cases_Intel_serial_${outFormat}
     cd ${FILE_NAME}_test_cases_Intel_serial_${outFormat}
     eval set UPPPath = ${RunPath}\'/${FILE_NAME}_Intel_serial/\'
     eval set CasesDir = ${RunPath}\'/${FILE_NAME}_test_cases_Intel_serial_${outFormat}/\'
     if ($COMPUTER_OPTION == "hera" || $COMPUTER_OPTION == "HERA") then
       module purge
       module load intel/18.0.5.274  impi/2018.0.4  netcdf/4.6.1
       module load grads
     else if($COMPUTER_OPTION == "cheyenne" || $COMPUTER_OPTION == "CHEYENNE") then
       module purge
       module load intel/18.0.5 netcdf/4.6.3 ncarcompilers/0.5.0
       #module load intel/17.0.1 netcdf/4.6.3 ncarcompilers/0.5.0  
     else if($COMPUTER_OPTION == "puffling" || $COMPUTER_OPTION == "PUFFLING") then
       echo 'Note: No Intel on puffling!'
     endif
   else if($CONFIG_OPTION[$ii] == 7 || $CONFIG_OPTION[$ii] == 11)then
     rm -rf ${FILE_NAME}_test_cases_GNU_serial_${outFormat}
     mkdir ${FILE_NAME}_test_cases_GNU_serial_${outFormat}
     cd ${FILE_NAME}_test_cases_GNU_serial_${outFormat}
     eval set UPPPath = ${RunPath}\'/${FILE_NAME}_GNU_serial/\'
     eval set CasesDir = ${RunPath}\'/${FILE_NAME}_test_cases_GNU_serial_${outFormat}/\'
     if($COMPUTER_OPTION == "hera" || $COMPUTER_OPTION == "HERA") then
       echo 'Note: No serial GNU bulit on hera!!'
     else if($COMPUTER_OPTION == "cheyenne" || $COMPUTER_OPTION == "CHEYENNE") then
       module purge
       module load gnu/8.3.0 netcdf/4.6.3 ncarcompilers/0.5.0
       module load grads
     else if($COMPUTER_OPTION == "puffling" || $COMPUTER_OPTION == "PUFFLING") then
       #source /home/hertneky/wheezy-gf.csh
     endif
   else if($CONFIG_OPTION[$ii] == 8 || $CONFIG_OPTION[$ii] == 12)then
     rm -rf ${FILE_NAME}_test_cases_GNU_dmpar_${outFormat}
     mkdir ${FILE_NAME}_test_cases_GNU_dmpar_${outFormat}
     cd ${FILE_NAME}_test_cases_GNU_dmpar_${outFormat}
     eval set UPPPath = ${RunPath}\'/${FILE_NAME}_GNU_dmpar/\'
     eval set CasesDir = ${RunPath}\'/${FILE_NAME}_test_cases_GNU_dmpar_${outFormat}/\'
     if($COMPUTER_OPTION == "hera" || $COMPUTER_OPTION == "HERA") then
       echo 'Note: No parallel GNU bulit on Hera!!'
     else if($COMPUTER_OPTION == "cheyenne" || $COMPUTER_OPTION == "CHEYENNE") then
       module purge
       module load gnu/8.3.0 mpt/2.19 netcdf-mpi/4.6.3 ncarcompilers/0.5.0 pnetcdf/1.11.1
       module load grads
     else if($COMPUTER_OPTION == "puffling" || $COMPUTER_OPTION == "PUFFLING") then
       #source /home/hertneky/wheezy-gf.csh
     endif
   else if($CONFIG_OPTION[$ii] == 2)then
     rm -rf ${FILE_NAME}_test_cases_PGI_dmpar_${outFormat}
     mkdir ${FILE_NAME}_test_cases_PGI_dmpar_${outFormat}
     cd ${FILE_NAME}_test_cases_PGI_dmpar_${outFormat}
     eval set UPPPath = ${RunPath}\'/${FILE_NAME}_PGI_dmpar/\'
     eval set CasesDir = ${RunPath}\'/${FILE_NAME}_test_cases_PGI_dmpar_${outFormat}/\'
     if($COMPUTER_OPTION == "hera" || $COMPUTER_OPTION == "HERA") then
       echo 'Note: No parallel PGI bulit on Hera!!'
     else if($COMPUTER_OPTION == "cheyenne" || $COMPUTER_OPTION == "CHEYENNE") then
       module purge
       module load pgi/19.3 mpt/2.19 netcdf-mpi/4.6.3 ncarcompilers/0.5.0 pnetcdf/1.11.1
       module load grads
     else if($COMPUTER_OPTION == "puffling" || $COMPUTER_OPTION == "PUFFLING") then
       echo 'Note: No PGI on puffling!'
     endif
   else if($CONFIG_OPTION[$ii] == 1)then
     rm -rf ${FILE_NAME}_test_cases_PGI_serial_${outFormat}
     mkdir ${FILE_NAME}_test_cases_PGI_serial_${outFormat}
     cd ${FILE_NAME}_test_cases_PGI_serial_${outFormat}
     eval set UPPPath = ${RunPath}\'/${FILE_NAME}_PGI_serial/\'
     eval set CasesDir = ${RunPath}\'/${FILE_NAME}_test_cases_PGI_serial_${outFormat}/\'
     if($COMPUTER_OPTION == "hera" || $COMPUTER_OPTION == "HERA") then
       echo 'Note: No parallel PGI bulit on Hera!!'
     else if($COMPUTER_OPTION == "cheyenne" || $COMPUTER_OPTION == "CHEYENNE") then
       module purge
       module load pgi netcdf ncarcompilers
       module load grads
     else if($COMPUTER_OPTION == "puffling" || $COMPUTER_OPTION == "PUFFLING") then
       echo 'Note: No PGI on puffling!'
     endif
   endif
   rm -rf case*

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
       else if (($COMPUTER_OPTION == "puffling" || $COMPUTER_OPTION == "PUFFLING") && ${bb} == 10) then
       echo 'No high resolution case (ps'${bb}') will be run on '${COMPUTER_OPTION} 
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
       if($COMPUTER_OPTION == "cheyenne" || $COMPUTER_OPTION == "CHEYENNE")then
         ln -svf $ExtraPath/wgrib2 .
         ln -svf $ExtraPath/wgrib .
         set flag=""
       else if($COMPUTER_OPTION == "hera" || $COMPUTER_OPTION == "HERA")then
         module load wgrib wgrib2/2.0.8
         #rm run_mpi.pbs run_mpi_rt.pbs
         set flag=".hera"
         #ln -svf $ExtraPath/run_mpi.pbs$flag run_mpi.pbs
         #ln -svf $ExtraPath/run_mpi_rt.pbs$flag run_mpi_rt.pbs
         #cp $ExtraPath/run_mpi.pbs.theia run_mpi.pbs
         #cp $ExtraPath/run_mpi_rt.pbs.theia run_mpi_rt.pbs
       else        
         set flag=""
       endif
       cp $UPPPath/scripts/run_unipost .
       ln -svf $ExtraPath/run_mpi.pbs$flag run_mpi.pbs
       ln -svf $ExtraPath/run_mpi_rt.pbs$flag run_mpi_rt.pbs
       eval set DataCase = ${DataPath}\'ps\'${bb}
       echo $DataCase
       set lastfhr  = 18
       if($bb <= 10)then
         set dyncore = 'ARW'
         set inFormat = 'netcdf'
         #set txtCntrlFile = 'postxconfig-NT_WRF.txt'
         set txtCntrlFile = 'postxconfig-NT-WRF.txt'
       else if($bb == 11)then
         #rm postxconfig-NT-WRF.txt
         #ln -svf postxconfig-NT-GFS.txt postxconfig-NT-WRF.txt
         set dyncore = 'FV3'
         set inFormat = 'binarynemsiompiio'
         #set inFormat = 'binarynemsio'
         set txtCntrlFile = 'postxconfig-NT-GFS.txt'
       else if($bb == 12)then
         set dyncore = 'FV3'
         set inFormat = 'netcdf'
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
         ln -svf $ExtraPath/run_mpi_hi.pbs$flag run_mpi.pbs
       else if($bb == 11)then
         set startdate = '2016100300' #hi-res case
         set tag = 'GFSPRS'
         set lastfhr  = 6
         rm run_mpi.pbs
         #if($outFormat == "grib")then
         ln -svf $ExtraPath/run_mpi_hi.pbs$flag run_mpi.pbs
         #endif
       else if($bb == 12)then
         set startdate = '2020020400' #hi-res case
         set tag = 'GFSPRS'
         set lastfhr  = 6
         rm run_mpi.pbs
         ln -svf $ExtraPath/run_mpi_hi.pbs$flag run_mpi.pbs
       if ($COMPUTER_OPTION == "hera" || $COMPUTER_OPTION == "HERA") then
           module purge
           module load intel/18.0.5.274
           module load impi/2018.0.4
           module use -a /scratch2/NCEPDEV/nwprod/NCEPLIBS/modulefiles
           module load prod_util/1.1.0
           module load grib_util/1.1.1
           module load crtm/2.2.5
           module load hdf5_parallel/1.10.6
           module load netcdf_parallel/4.7.4
           module load grads
           module list
       endif
         ln -svf $UPPPath/parm/params_grib2_tbl_new .
       endif
       eval set DOMAINPATH = ${CasesDir}${case}
       eval set postexec = ${UPPPath}\'/exec\'
       echo $DOMAINPATH
       sed -i -e "/export/s|txtCntrlFile=[^ ]*|txtCntrlFile=$UPPPath/parm/$txtCntrlFile|" run_unipost
       sed -i -e "/export/s|dyncore=[^ ]*|dyncore=$dyncore|" run_unipost
       sed -i -e "/export/s|inFormat=[^ ]*|inFormat=$inFormat|" run_unipost
       sed -i -e "/export/s|outFormat=[^ ]*|outFormat=$outFormat|" run_unipost
       sed -i -e "/export/s|TOP_DIR=[^ ]*|TOP_DIR=$RunPath|" run_unipost
       sed -i -e "/export/s|DOMAINPATH=[^ ]*|DOMAINPATH=$DOMAINPATH|" run_unipost
       sed -i -e "/export/s|UNIPOST_HOME=[^ ]*|UNIPOST_HOME=$UPPPath|" run_unipost
       sed -i -e "/export/s|POSTEXEC=[^ ]*|POSTEXEC=$postexec|" run_unipost
       sed -i -e "/export/s|modelDataPath=[^ ]*|modelDataPath=$DataCase|" run_unipost
       sed -i -e "/export/s|startdate=[^ ]*|startdate=$startdate|" run_unipost
       sed -i -e "/export/s|lastfhr=[^ ]*|lastfhr=$lastfhr|" run_unipost
       if($bb == 10 || $bb == 11)then
         #set domain_list = 'd02'
         set incrementhr = '01'
         #sed -i -e "/export/s|domain_list=[^ ]*|domain_list=$domain_list|" run_unipost
         sed -i -e "/export/s|incrementhr=[^ ]*|incrementhr=$incrementhr|" run_unipost
         #set dom = 'd02'
         #else
         #set dom = 'd01'
       endif
      
       set dom = 'd01'
      
       if($outFormat == 'grib2')then     
       set gribtype = 'wgrib2'
       else if($outFormat == 'grib')then     
       set gribtype = 'wgrib'
       endif

       if($CONFIG_OPTION[$ii] == 2 || \
          $CONFIG_OPTION[$ii] == 4 || \
          $CONFIG_OPTION[$ii] == 8 || \
          $CONFIG_OPTION[$ii] == 12)then
         echo 'CONFIG_OPTION IS MPI ' $CONFIG_OPTION[$ii]
         if($COMPUTER_OPTION == "hera" || $COMPUTER_OPTION == "HERA")then
           set run_line='"mpirun '${postexec}'/unipost.exe'
         else if($COMPUTER_OPTION == "cheyenne" || $COMPUTER_OPTION == "CHEYENNE")then
           set run_line='"mpirun '${postexec}'/unipost.exe'
         else if($COMPUTER_OPTION == "puffling" || $COMPUTER_OPTION == "PUFFLING")then
           ln -sf /d1/hertneky/upp/data/machfile .
           set run_line='"mpirun -machinefile machfile -np 4 '${postexec}'/unipost.exe'
         endif
       endif
      
       if($CONFIG_OPTION[$ii] == 1 || \
          $CONFIG_OPTION[$ii] == 3 || \
          $CONFIG_OPTION[$ii] == 7 || \
          $CONFIG_OPTION[$ii] == 11)then
         echo 'CONFIG_OPTION IS SERIAL ' $CONFIG_OPTION[$ii]
         set run_line='"'${postexec}'/unipost.exe'
       endif
      
       sed -i -e "/export/s|RUN_COMMAND=[^ ]*|RUN_COMMAND=$run_line|" run_unipost
       #cp $ExtraPath/run_rt.pbs .
      
       #sleep $sleepT
       
       if($outFormat == "grib2")then
         if($bb <= 9)then
           ln -svf $ExtraPath/run_mpi_rt.pbs$flag run_mpi.pbs
         else if($bb == 11)then
           ln -svf $ExtraPath/run_mpi_rt_hi.pbs$flag run_mpi.pbs
         else if($bb == 10 || $bb == 12)then
           ln -svf $ExtraPath/run_mpi_fv3.pbs$flag run_mpi.pbs
         endif
         #ln -svf $ExtraPath/cmp_grib2_grib2.sh .
         cp $ExtraPath/run_rt.pbs$flag .
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
           echo 'cc=' $cc
           if(( ($cc <= 9 && $bb == 11) || ($cc <= 9 && $bb == 12) ))then
             eval set ending = \'0\'${cc}
             eval set cmp_line='$gribtype\ $CNTLCase/CNTL_$tag\.${ending}\ -var\ -lev\ -rpn\ sto_1\ -import_grib\ $DOMAINPATH/postprd/$tag\.${ending}\ -rpn\ rcl_1:print_corr:print_rms\ \>\ reg_test\.${ending}\.txt'
           else if(( ($cc <= 9 && $bb != 11) || ($cc <= 9 && $bb != 12) ))then
             eval set ending = \'0\'${cc}
             eval set cmp_line='$gribtype\ $CNTLCase/CNTL_WRFPRS_$dom\.${ending}\ -var\ -lev\ -rpn\ sto_1\ -import_grib\ $DOMAINPATH/postprd/WRFPRS_$dom\.${ending}\ -rpn\ rcl_1:print_corr:print_rms\ \>\ reg_test\.${ending}\.txt'
           endif
           if(( ($cc > 9 && $bb == 11) || ($cc > 9 && $bb == 12) ))then
             eval set cmp_line='$gribtype\ $CNTLCase/CNTL_$tag\.${cc}\ -var\ -lev\ -rpn\ sto_1\ -import_grib\ $DOMAINPATH/postprd/$tag\.${cc}\ -rpn\ rcl_1:print_corr:print_rms\ \>\ reg_test\.${cc}\.txt'
           else if(( ($cc > 9 && $bb != 11) || ($cc > 9 && $bb != 12) ))then
             eval set cmp_line='$gribtype\ $CNTLCase/CNTL_WRFPRS_$dom\.${cc}\ -var\ -lev\ -rpn\ sto_1\ -import_grib\ $DOMAINPATH/postprd/WRFPRS_$dom\.${cc}\ -rpn\ rcl_1:print_corr:print_rms\ \>\ reg_test\.${cc}\.txt'
           endif
           #sed -i '/wgrib2/c\'"$cmp_line" run_rt.pbs
           echo $cmp_line >> add.txt
           #sleep $sleepT
           #qsub ./run_rt.pbs
           if($bb == 12)then
             if($cc >= 1)break
             @ cc ++
           else if($bb == 10 || $bb == 11)then
             if($cc >= 6)break
             @ cc ++
           else
             @ cc += 3
           endif
           echo 'cc=' $cc
         end
         sed -i '/#wgrib2/r add.txt' run_rt.pbs$flag
       endif #if grib
  
       if($COMPUTER_OPTION == "hera" || $COMPUTER_OPTION == "HERA")then
         sed -i 's;^cd .*;cd '"$DOMAINPATH/postprd/"';' run_mpi.pbs
         sed -i 's;^cd .*;cd '"$DOMAINPATH/postprd/"';' run_rt.pbs$flag
         sbatch ./run_mpi.pbs
       else if($COMPUTER_OPTION == "cheyenne" || $COMPUTER_OPTION == "CHEYENNE")then
         qsub ./run_mpi.pbs
         echo 'submit jobs'
       else if($COMPUTER_OPTION == "puffling" || $COMPUTER_OPTION == "PUFFLING")then
         ./run_unipost
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
