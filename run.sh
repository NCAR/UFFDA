#!/bin/csh
set echo
#
# This script runs the UPP code for select cases
# and generates regression test results using
# baseline case data.
#
###############################################
#
# Oirg. Code: Ka Yee Wong  (NOAA/GSD) Jun  2017
# Edit. Code: Ka Yee Wong  (NOAA/GSD) Mar  2020
# Edit. Code: Ka Yee Wong  (NOAA/GSD) Apr  2021
# Tested on Hera:                     Apr  2021
# Tested on cheyenne:                 Apr  2021
#
###############################################
# Run script
# # > ./run.sh
# # Want to terminate/kill the job:
# # > qstat -u username
# # > qdel job ID
###############################################
###############################################
#!!!!!!!!!!!!!!User Define Here!!!!!!!!!!!!!!!#
###############################################
 set FILE_NAME = "UPP_release"   # should match the FILE_NAME from compile.sh
 set exec_name = "upp.x" # upp.x for develop branch
 #set exec_name = "ncep_post" # ncep_post for release/public-v2 branch
 set account = "P48503002" # project account to charge on the machine
 set RunPath = '/glade/scratch/your_run_directory_path/' # where you want to run the regression test
 set numR  = 6 # # of test cases (please reference the README for case descriptions)
 set COMPUTER_OPTION = "hera" # hera/cheyenne
 set CONFIG_OPTION = (4) # 4)Intel(dmpar) 8)GNU(dmpar) for Cheyenne ONLY
#
###############################################
###############################################
#!!!!!!!!!STOP User Define Here!!!!!!!!!!!!!!!#
###############################################
###############################################
 set outFormat = 'grib2' # 'grib2' only
 set gribtype = 'wgrib2'
 set run_script = "run_upp"

# Path settings for data, benchmarks, and scripts
 if ($COMPUTER_OPTION == "hera" || $COMPUTER_OPTION == "HERA") then
    set DataPath = '/scratch1/BMC/dtc/UPP/UPPdata/fv3_2021/' # settings on Hera
    set CNTLPath='/scratch1/BMC/dtc/UPP/UFFDA/bench_mark/'
    set ExtraPath = '/scratch1/BMC/dtc/KaYee/UPP/GITHUB_push/UFFDA/'
 else if ($COMPUTER_OPTION == "cheyenne" || $COMPUTER_OPTION == "CHEYENNE") then
    set DataPath = '/gpfs/fs1/p/ral/jntp/UPP/data/fv3_2021/' # settings on Cheyenne
    set ExtraPath = '/gpfs/fs1/p/ral/jntp/UPP/Extra'
    set CNTLPath='/gpfs/fs1/p/ral/jntp/UPP/UFFDA/bench_mark'
 endif

# Set environment settings based on system configuration
 set NUM_CONFIG = $#CONFIG_OPTION  # # of configurations
 set ii = 1
 while ($ii <= $NUM_CONFIG)
   if($CONFIG_OPTION[$ii] == 4)then # Intel
     rm -rf ${FILE_NAME}_test_cases_Intel_dmpar_${outFormat}
     mkdir ${FILE_NAME}_test_cases_Intel_dmpar_${outFormat}
     cd ${FILE_NAME}_test_cases_Intel_dmpar_${outFormat}
     eval set UPPPath = ${RunPath}\'/${FILE_NAME}_Intel_dmpar/\'
     eval set CasesDir = ${RunPath}\'/${FILE_NAME}_test_cases_Intel_dmpar_${outFormat}/\'
     echo $CasesDir
     if ($COMPUTER_OPTION == "hera" || $COMPUTER_OPTION == "HERA") then
       module purge
       module load cmake/3.16.1

       module use /scratch2/NCEPDEV/nwprod/hpc-stack/libs/hpc-stack/modulefiles/stack
       module load hpc/1.1.0
       module load hpc-intel/18.0.5.274
       module load hpc-impi/2018.0.4
       
       module load jasper/2.0.22
       module load zlib/1.2.11
       module load png/1.6.35

       module load hdf5/1.10.6
       module load netcdf/4.7.4

       module load bacio/2.4.1
       module load crtm/2.3.0
       module load g2/3.4.1
       module load g2tmpl/1.10.0
       module load ip/3.3.3
       module load nemsio/2.5.2
       module load sfcio/1.4.1
       module load sigio/2.3.2
       module load sp/2.3.3
       module load w3nco/2.4.1
       module load w3emc/2.7.3
       module load wrf_io/1.1.1

     else if($COMPUTER_OPTION == "cheyenne" || $COMPUTER_OPTION == "CHEYENNE") then
       module purge
       module load intel/19.1.1 cmake/3.16.4 mpt/2.19 ncarenv/1.3
     endif
   else if($CONFIG_OPTION[$ii] == 8)then # GNU
     rm -rf ${FILE_NAME}_test_cases_GNU_dmpar_${outFormat}
     mkdir ${FILE_NAME}_test_cases_GNU_dmpar_${outFormat}
     cd ${FILE_NAME}_test_cases_GNU_dmpar_${outFormat}
     eval set UPPPath = ${RunPath}\'/${FILE_NAME}_GNU_dmpar/\'
     eval set CasesDir = ${RunPath}\'/${FILE_NAME}_test_cases_GNU_dmpar_${outFormat}/\'
     if($COMPUTER_OPTION == "hera" || $COMPUTER_OPTION == "HERA") then
       echo 'Note: No parallel GNU bulit on Hera!!'
       #module purge
       #module load gnu/9.2.0 cmake/3.16.1
       #module use -a /scratch1/BMC/gmtb/software/modulefiles/gnu-9.2.0/mpich-3.3.2/
       #module load mpich/3.3.2
       #module load NCEPlibs
       #setenv CXX g++
       #setenv CC gcc
       #setenv FC gfortran
     else if($COMPUTER_OPTION == "cheyenne" || $COMPUTER_OPTION == "CHEYENNE") then
       module purge
       module load ncarenv/1.3  gnu/10.1.0  ncarcompilers/0.5.0  mpt/2.19  cmake/3.18.2
       module use -a /glade/p/ral/jntp/GMTB/tools/NCEPLIBS-ufs-v2.0.0/gnu-10.1.0/mpt-2.19/modules
       module load NCEPLIBS/2.0.0
     endif
   endif

   # Run the cases and regression tests
   set bb = 1
   while ($bb <= $numR)
     echo 'case '$bb
     echo 'CONFIG_OPTION ' $CONFIG_OPTION[$ii]
     eval set case = \'case\'${bb}
     echo $case
     mkdir $case
     cd $case

     # Create and link the parameter files to the /parm directory  
     mkdir parm
     cd parm
     ln -svf $UPPPath/parm/postcntrl.xml .
     ln -svf $UPPPath/parm/postxconfig-NT-GFS.txt .
     ln -svf $UPPPath/parm/postxconfig-NT-fv3lam.txt .

     # Create case run directory and link/copy necessary files
     cd ..
     mkdir postprd
     cd postprd
     ln -svf $ExtraPath/*.pl .
     if($COMPUTER_OPTION == "cheyenne" || $COMPUTER_OPTION == "CHEYENNE")then
       module load grib-bins
       set flag=""
     else if($COMPUTER_OPTION == "hera" || $COMPUTER_OPTION == "HERA")then
       #module load intel/18.0.5.274
       #module load wgrib2/2.0.8
       set flag=".hera"
     else
       set flag=""
     endif
       
     # Copy the run_upp script into the case dir and set some paths
     cp $UPPPath/scripts/$run_script .
     eval set DataCase = ${DataPath}\'ps\'${bb}
     echo $DataCase
     eval set DOMAINPATH = ${CasesDir}${case}
     #eval set postexec = ${UPPPath}\'/exec\'
     eval set postexec = ${UPPPath}\'/exec\'
     echo $DOMAINPATH

     # Case setings for run_upp script
     if($bb == 1)then
       set dyncore = 'FV3'
       set model = 'GFS'
       set inFormat = 'netcdfpara'
       set txtCntrlFile = 'postxconfig-NT-GFS.txt'
       set startdate = '2021021600'
       set tag = 'GFSPRS'
       set fhr  = '06'
       set lastfhr  = 6
     else if($bb == 2)then
       set dyncore = 'FV3'
       set model = 'GFS'
       set inFormat = 'netcdfpara'
       set txtCntrlFile = 'postxconfig-NT-GFS.txt'
       set startdate = '2020020400'
       set tag = 'GFSPRS'
       set fhr  = '06'
       set lastfhr  = 6
     else if($bb == 3)then
       set dyncore = 'LAM'
       set model = 'LAM'
       set inFormat = 'netcdfpara'
       set txtCntrlFile = 'postxconfig-NT-fv3lam.txt'
       set startdate = '2019101112'
       set tag = 'BGRD3D'
       if($exec_name == "upp.x") set tag = 'PRSLEV'
       set fhr  = '04'
       set lastfhr  = 4
     else if($bb == 4)then
       set dyncore = 'LAM'
       set model = 'LAM'
       set inFormat = 'netcdfpara'
       set txtCntrlFile = 'postxconfig-NT-fv3lam.txt'
       set startdate = '2019111112'
       set tag = 'BGRD3D'
       if($exec_name == "upp.x") set tag = 'PRSLEV'
       set fhr  = '00'
       set lastfhr  = 12
     else if($bb == 5)then
       set dyncore = 'LAM'
       set model = 'LAM'
       set inFormat = 'netcdfpara'
       set txtCntrlFile = 'postxconfig-NT-fv3lam.txt'
       set startdate = '2019061512'
       set tag = 'BGRD3D'
       if($exec_name == "upp.x") set tag = 'PRSLEV'
       set fhr  = '00'
       set lastfhr  = 12
     else if($bb == 6)then
       set dyncore = 'FV3'
       set model = 'GFS'
       set inFormat = 'netcdfpara'
       set txtCntrlFile = 'postxconfig-NT-GFS.txt'
       set startdate = '2019082900'
       set tag = 'GFSPRS'
       set fhr  = '00'
       set lastfhr  = 12
     endif
     set incrementhr = 1
     
     # Set run command and link batch scripts depending on system/configuration
     echo '$COMPUTER_OPTION' $COMPUTER_OPTION
     if($COMPUTER_OPTION == "hera" || $COMPUTER_OPTION == "HERA")then
       #if($bb == 1 || $bb == 4)then
       if($bb == 1 )then
         set run_line = '"mpirun '${postexec}'/'$exec_name'"'
         ln -svf $ExtraPath/run_mpi_para.pbs$flag run_mpi.pbs
       else if($bb == 4 )then
         #set run_line = '"mpiexec '${postexec}'/'$exec_name'"'
         set run_line = '"mpirun '${postexec}'/'$exec_name'"'
         ln -svf $ExtraPath/run_mpi.pbs$flag run_mpi.pbs
       #else if($bb == 2 || $bb == 3 || $bb == 5 || $bb == 6 || $bb == 7)then
       else if($bb == 2 || $bb == 3 || $bb == 5 || $bb == 6)then
         set run_line = '"mpirun '${postexec}'/'$exec_name'"'
         ln -svf $ExtraPath/run_mpi_hi.pbs$flag run_mpi.pbs
       else
         set run_line = '"mpirun '${postexec}'/'$exec_name'"'
         ln -svf $ExtraPath/run_mpi.pbs$flag run_mpi.pbs
       endif
     endif
     if($COMPUTER_OPTION == "cheyenne" || $COMPUTER_OPTION == "CHEYENNE")then
       set run_line = '"mpiexec_mpt '${postexec}'/'$exec_name'"'
       if($bb == 1 || $bb == 4)then
         ln -svf $ExtraPath/run_mpi_rt_hi.pbs$flag run_mpi.pbs
       else if($bb == 2 || $bb == 3 || $bb == 5 || $bb == 6)then
         ln -svf $ExtraPath/run_mpi_fv3.pbs$flag run_mpi.pbs
       endif
     endif

     # Set parameters within the run_upp script
     sed -i -e "/export/s|txtCntrlFile=[^ ]*|txtCntrlFile=$UPPPath/parm/$txtCntrlFile|" $run_script
     sed -i -e "/export/s|dyncore=[^ ]*|dyncore=$dyncore|" $run_script
     sed -i -e "/export/s|model=[^ ]*|model=$model|" $run_script
     sed -i -e "/export/s|inFormat=[^ ]*|inFormat=$inFormat|" $run_script
     sed -i -e "/export/s|outFormat=[^ ]*|outFormat=$outFormat|" $run_script
     sed -i -e "/export/s|TOP_DIR=[^ ]*|TOP_DIR=$RunPath|" $run_script
     sed -i -e "/export/s|DOMAINPATH=[^ ]*|DOMAINPATH=$DOMAINPATH|" $run_script
     sed -i -e "/export/s|UNIPOST_HOME=[^ ]*|UNIPOST_HOME=$UPPPath|" $run_script
     sed -i -e "/export/s|POSTEXEC=[^ ]*|POSTEXEC=$postexec|" $run_script
     sed -i -e "/export/s|modelDataPath=[^ ]*|modelDataPath=$DataCase|" $run_script
     sed -i -e "/export/s|startdate=[^ ]*|startdate=$startdate|" $run_script
     sed -i -e "/export/s|fhr=[^ ]*|fhr=$fhr|" $run_script
     sed -i -e "/export/s|lastfhr=[^ ]*|lastfhr=$lastfhr|" $run_script
     sed -i -e "/export/s|incrementhr=[^ ]*|incrementhr=$incrementhr|" $run_script
     sed -i '/#export RUN_COMMAND=/d' $run_script
     sed -i "/export RUN_COMMAND=/c\export RUN_COMMAND=${run_line}" $run_script

     # Add regression commands to run_rt.pbs script
     # Submit batch scripts to run UPP and regression tests
     cp $ExtraPath/run_rt.pbs$flag .
     if($CONFIG_OPTION[$ii] == 4)then
       eval set CNTLCase = ${CNTLPath}/Intel_dmpar/\'ps\'${bb}
       if($exec_name == "upp.x") eval set CNTLCase = ${CNTLPath}/Intel_dmpar/EMC/\'ps\'${bb}
     else if($CONFIG_OPTION[$ii] == 8)then
       eval set CNTLCase = ${CNTLPath}/GNU_dmpar/\'ps\'${bb}
       if($exec_name == "upp.x") eval set CNTLCase = ${CNTLPath}/GNU_dmpar/EMC/\'ps\'${bb}
     endif
     echo 'CNTLCase =' $CNTLCase
     ln -svf $CNTLCase/* .
     set cc = 0
     while ($cc <= 18)
       echo 'cc=' $cc
       if($cc <= 9 )then
         eval set ending = \'00\'${cc}
       else if($cc > 9)then
         eval set ending = \'0\'${cc}
       endif
       eval set cmp_line='$gribtype\ $CNTLCase/CNTL_$tag\.${ending}\ -var\ -lev\ -rpn\ sto_1\ -import_grib\ $DOMAINPATH/postprd/$tag\.${ending}\ -rpn\ rcl_1:print_corr:print_rms\ \>\ reg_test\.${ending}\.txt'
       if(($cc == 6 && $bb == 2))then
         if($cc >= 7)break
           echo $cmp_line >> add.txt
       else if($cc == 6 && $bb == 1)then
         if($cc >= 7)break
           echo $cmp_line >> add.txt
       else if(($cc == 4 && $bb == 3))then
         if($cc >= 5)break
           echo $cmp_line >> add.txt
       else if($bb == 4 || $bb == 5 || $bb == 6)then
         if($cc >= 13)break
           echo $cmp_line >> add.txt
       endif
         @ cc ++
         echo 'cc=' $cc
     end
     sed -i '/#wgrib2/r add.txt' run_rt.pbs$flag
     sed -i "0,/run_/{s/run_.*/${run_script}/}" run_mpi.pbs

     if($COMPUTER_OPTION == "hera" || $COMPUTER_OPTION == "HERA")then
       sed -i '/#wgrib2/r add.txt' run_mpi.pbs
       sed -i "0,/account=/{s/account=.*/account=${account}/}" run_mpi.pbs
       sed -i 's;^cd .*;cd '"$DOMAINPATH/postprd/"';' run_mpi.pbs
       if($bb == 5) sed -i "0,/time=/{s/time=.*/time=00:59:00/}" run_mpi.pbs
         sbatch ./run_mpi.pbs
       else if($COMPUTER_OPTION == "cheyenne" || $COMPUTER_OPTION == "CHEYENNE")then
         if($bb == 5) sed -i "0,/walltime=/{s/walltime=.*/walltime=00:50:00/}" run_rt.pbs
         sed -i "0,/-A /{s/-A .*/-A ${account}/}" run_mpi.pbs
         qsub ./run_mpi.pbs
         echo 'submit jobs'
       endif

       cd ../..

     endif
     @ bb++
     echo $bb
   end
   cd ..
   @ ii++
   echo $ii
 end
 echo 'Exit'
 exit
