#!/bin/csh
###############################################
#
# Oirg. Code: Ka Yee Wong (NOAA/GSD) Jun  2017
# Edit. Code: Ka Yee Wong (NOAA/GSD) Oct  2020
# Tested on Hera:                    Mar  2020
# Tested on cheyenne:                Mar  2020
# Tested on puffling by Tracy(NCAR): Mar  2020
#
###############################################
# Run at background:
# # > compile.csh > & cshout &
# # Want to terminate/kill the job:
# # > jobs
# # > kill %1
# # or
# # > ps
# # > kill -9 PID
###############################################
#!!!!!!!!!!!!!!User Define Here!!!!!!!!!!!!!!!#
###############################################
set source = (3) # 1) source code from vlab 2) source code from local path 3) source code from github
if ($source == 1)then
  set FILE_NAME = "DTC_UPP_vlab"  # Your preferred directory name
  set repository = "https://vlab.ncep.noaa.gov/code-review/EMC_post"
  set branch = "dtc_post_v4.0.1"
else if ($source == 2)then
  set FILE_NAME = "DTC_post_v4.1"  # Your preferred directory name
  set upppath = "/glade/work/kayee/UPP/UFFDA/GITHUB/git_push/UFFDA" # Local path that you want to copy from (no tar file)
  #set upppath = "/glade/scratch/kayee/UPP/UFFDA/DTC_post_v4.1_ps12/DTC_post_v4.1/"  # Local path that you want to copy from (no tar file)
  #set upppath = "/glade/work/kavulich/UPP/UFFDA/EMC_post_mkavulich"  # Local path that you want to copy from (no tar file)
else if ($source == 3)then
  set FILE_NAME = "v4.1.0.beta02"  # Your preferred directory name
  #set FILE_NAME = "DTC_UPP_github_v6f54859"  # Your preferred directory name
  set repository = "https://github.com/NOAA-EMC/EMC_post"
  set branch = "v4.1.0.beta02"
  #set branch = "DTC_post"
endif
set COMPUTER_OPTION = "cheyenne" # hera/cheyenne/puffling for now 
set CONFIG_OPTION = (4 2 8) #1)PGI(serial) 2)PGI(dmpar) 3)Intel(serial) 4)Intel(dmpar) 7)GNU(serial) 8)GNU(dmpar)
set DEBUG = 0
###############################################
###############################################
#!!!!!!!!!STOP User Define Here!!!!!!!!!!!!!!!#
###############################################
###############################################
set NUM_CONFIG = $#CONFIG_OPTION  # # of configurations
echo 'NUM_CONFIG = ' $NUM_CONFIG
echo 'CONFIG_OPTION = ' $CONFIG_OPTION
if ($DEBUG == 1)then
  set UPP_CONFIGURE_COMMAND="./configure -d"
else
  set UPP_CONFIGURE_COMMAND="./configure"
endif

echo 'You are compiling the UPP code on' $COMPUTER_OPTION'.'
if ($source == 1)then
  rm -rf $FILE_NAME
  rm -rf EMC_post
  git clone -b $branch --recurse-submodules $repository 
  cp -ra EMC_post/comupp $FILE_NAME
else if ($source == 2)then
#  rm -rf $FILE_NAME
  cp -ra $upppath $FILE_NAME
  cd $FILE_NAME
  ./clean -a
  cd ../
else if ($source == 3)then
  git clone -b $branch --recurse-submodules $repository $FILE_NAME
endif
if ($? != 0)then
  echo "error cloning repository"
  exit
endif

set i = 1
while ($i <= $NUM_CONFIG)
if($CONFIG_OPTION[$i] == 4)then
  rm -rf ${FILE_NAME}_Intel_dmpar
  cp -ra ${FILE_NAME} ${FILE_NAME}_Intel_dmpar
  cd ${FILE_NAME}_Intel_dmpar
  if ($COMPUTER_OPTION == "hera" || $COMPUTER_OPTION == "HERA") then
    module purge
    module load intel/18.0.5.274  impi/2018.0.4  netcdf/4.7.0
    #module load intel/18.0.5.274  impi/2018.0.4  netcdf/4.6.1
    if (! $?NCEPLIBS_DIR_INTEL ) then
      setenv NCEPLIBS_DIR /scratch2/BMC/det/kavulich/UPP/NCEPlibs_intel_18.0.5.274
    else
      setenv NCEPLIBS_DIR $NCEPLIBS_DIR_INTEL
    endif
  else if ($COMPUTER_OPTION == "cheyenne" || $COMPUTER_OPTION == "CHEYENNE") then
    module purge
    #module load intel/17.0.1 mpt/2.19 netcdf-mpi/4.6.3 ncarcompilers/0.5.0 pnetcdf/1.11.1
    module load intel/18.0.5 mpt/2.19 netcdf-mpi/4.6.3 ncarcompilers/0.5.0 pnetcdf/1.11.1
    if (! $?NCEPLIBS_DIR_INTEL ) then
      setenv NCEPLIBS_DIR /glade/p/ral/jntp/UPP/pre-compiled_libraries/NCEPlibs_intel_18.0.5
    else
      setenv NCEPLIBS_DIR $NCEPLIBS_DIR_INTEL
    endif
    echo "Will use NCEPLIBS in $NCEPLIBS_DIR for INTEL"
  else if($COMPUTER_OPTION == "puffling" || $COMPUTER_OPTION == "PUFFLING") then
    echo 'Note: No Intel on puffling!'
  endif
else if($CONFIG_OPTION[$i] == 3)then
  rm -rf ${FILE_NAME}_Intel_serial
  cp -ra ${FILE_NAME} ${FILE_NAME}_Intel_serial
  cd ${FILE_NAME}_Intel_serial
  if ($COMPUTER_OPTION == "hera" || $COMPUTER_OPTION == "HERA") then
    module purge
    module load intel/18.0.5.274 netcdf/4.6.1
  else if ($COMPUTER_OPTION == "cheyenne" || $COMPUTER_OPTION == "CHEYENNE") then
    module purge
    module load intel/18.0.5 netcdf/4.6.3 ncarcompilers/0.5.0
    #module load intel/17.0.1 netcdf/4.6.3 ncarcompilers/0.5.0
    #set targetDir='/gpfs/fs1/p/ral/jntp/UPP/PRE_COMPILED_CODE/WRFV3.9_Intel_serial_large-file'
  else if($COMPUTER_OPTION == "puffling" || $COMPUTER_OPTION == "PUFFLING") then
    #source /home/hertneky/wheezy-intel.csh
    echo 'Note: No Intel on puffling!'
  endif
else if($CONFIG_OPTION[$i] == 7 || $CONFIG_OPTION[$i] == 11)then
  rm -rf ${FILE_NAME}_GNU_serial
  cp -ra ${FILE_NAME} ${FILE_NAME}_GNU_serial
  cd ${FILE_NAME}_GNU_serial
  if ($COMPUTER_OPTION == "cheyenne" || $COMPUTER_OPTION == "CHEYENNE") then
    module purge
    module load gnu/8.3.0 netcdf/4.6.3 ncarcompilers/0.5.0 
    #set targetDir='/gpfs/fs1/p/ral/jntp/UPP/PRE_COMPILED_CODE/WRFV3.9_GNU_serial_large-file'
  else if($COMPUTER_OPTION == "puffling" || $COMPUTER_OPTION == "PUFFLING") then
    #source /home/hertneky/wheezy-gf.csh
  endif
else if($CONFIG_OPTION[$i] == 8 || $CONFIG_OPTION[$i] == 12)then
  rm -rf ${FILE_NAME}_GNU_dmpar
  cp -ra ${FILE_NAME} ${FILE_NAME}_GNU_dmpar
  cd ${FILE_NAME}_GNU_dmpar
  if ($COMPUTER_OPTION == "cheyenne" || $COMPUTER_OPTION == "CHEYENNE") then
    module purge
    module load gnu/8.3.0 mpt/2.19 netcdf-mpi/4.6.3 ncarcompilers/0.5.0 pnetcdf/1.11.1
    if (! $?NCEPLIBS_DIR_GNU ) then
      setenv NCEPLIBS_DIR /glade/p/ral/jntp/UPP/pre-compiled_libraries/NCEPlibs_gnu_8.3.0
    else
      setenv NCEPLIBS_DIR $NCEPLIBS_DIR_GNU
    endif
    echo "Will use NCEPLIBS in $NCEPLIBS_DIR for GNU"
  else if($COMPUTER_OPTION == "puffling" || $COMPUTER_OPTION == "PUFFLING") then
    #source /home/hertneky/wheezy-gf.csh
    setenv NCEPLIBS_DIR /d1/hertneky/upp/NCEPlibs
  endif
else if($CONFIG_OPTION[$i] == 1)then
  rm -rf ${FILE_NAME}_PGI_serial
  cp -ra ${FILE_NAME} ${FILE_NAME}_PGI_serial
  cd ${FILE_NAME}_PGI_serial
  if ($COMPUTER_OPTION == "hera" || $COMPUTER_OPTION == "HERA") then
    module purge
    #module load pgi/18.10 netcdf/4.6.1
    module load pgi netcdf
  else if ($COMPUTER_OPTION == "cheyenne" || $COMPUTER_OPTION == "CHEYENNE") then
    module purge
    module load pgi/19.3 netcdf/4.6.3 ncarcompilers/0.5.0 
    #set targetDir='/gpfs/fs1/p/ral/jntp/UPP/PRE_COMPILED_CODE/WRFV3.9_PGI_serial_large-file'
  else if($COMPUTER_OPTION == "puffling" || $COMPUTER_OPTION == "PUFFLING") then
       echo 'Note: No PGI on puffling!'
  endif
else if($CONFIG_OPTION[$i] == 2)then
  rm -rf ${FILE_NAME}_PGI_dmpar
  cp -ra ${FILE_NAME} ${FILE_NAME}_PGI_dmpar
  cd ${FILE_NAME}_PGI_dmpar
  if ($COMPUTER_OPTION == "hera" || $COMPUTER_OPTION == "HERA") then
    module purge
    #module load pgi/18.10 impi netcdf/4.6.1
    module load pgi netcdf mpt
  else if ($COMPUTER_OPTION == "cheyenne" || $COMPUTER_OPTION == "CHEYENNE") then
    module purge
    module load pgi/19.3 mpt/2.19 netcdf-mpi/4.6.3 ncarcompilers/0.5.0 pnetcdf/1.11.1
    if (! $?NCEPLIBS_DIR_PGI ) then
      setenv NCEPLIBS_DIR /glade/p/ral/jntp/UPP/pre-compiled_libraries/NCEPlibs_pgi_19.3
    else
      setenv NCEPLIBS_DIR $NCEPLIBS_DIR_PGI
    endif
    echo "Will use NCEPLIBS in $NCEPLIBS_DIR for PGI"
  else if($COMPUTER_OPTION == "puffling" || $COMPUTER_OPTION == "PUFFLING") then
       echo 'Note: No PGI on puffling!'
  endif
endif
#setenv WRF_DIR $targetDir
#pwd
#./clean

# Put interactive "configure" options in a file, then pass to configure.
cat > ./CONFIG_OPTIONS << EOF
$CONFIG_OPTION[$i]
EOF
#$UPP_CONFIG_OPTION
#EOF

$UPP_CONFIGURE_COMMAND < ./CONFIG_OPTIONS

#if ($COMPUTER_OPTION == "theia" || $COMPUTER_OPTION == "THEIA") then
#  if($CONFIG_OPTION[$i] == 4)then
#    set newFC = 'mpiifort'
#    sed -i -e "/DM_FC  =/ s|= .*|= $newFC|" configure.upp
#    set newF90 = 'mpiifort -free'
#    sed -i -e "/DM_F90 =/ s|= .*|= $newF90|" configure.upp
#    set newCC = 'mpiicc'
#    sed -i -e "/DM_CC  =/ s|= .*|= $newCC|" configure.upp
#  endif
#endif

date > StartTime.txt
./compile >& compile.log 
date > EndTime.txt
if (-e bin/unipost.exe) then
cat > ./COMPILE_RESULT << EOF
All executable files exist
EOF
else
cat > ./COMPILE_RESULT << EOF
One or more is missing
EOF
endif
cd ../
@ i++
end

rm -rf ${FILE_NAME} 

echo 'Exit'
exit
