#!/bin/csh
#
# This script builds the UPP code.
#
###############################################
#
# Oirg. Code: Ka Yee Wong (NOAA/GSD) Jun  2017
# Edit. Code: Ka Yee Wong (NOAA/GSD) Oct  2020
# Edit. Code: Ka Yee Wong (NOAA/GSD) Apr  2021
# Tested on Hera:                    Apr  2021
# Tested on cheyenne:                Apr  2021
#
###############################################
# Run script
# # > ./compile.sh
# # Want to terminate/kill the job:
# # > qstat -u username
# # > qdel job ID
###############################################
#!!!!!!!!!!!!!!User Define Here!!!!!!!!!!!!!!!#
###############################################
set source = (1) # 1) source code from github 2) source code from local path 
if ($source == 1)then
  set FILE_NAME = "UPP"  # Your preferred directory name
  set repository = "https://github.com/NOAA-EMC/UPP"
  #set branch = "release/public-v2"
  set branch = "develop"
else if ($source == 2)then
  set FILE_NAME = "UPP"  # Your preferred directory name
  set upppath = "/scratch2/BMC/det/KaYee/UPP/UFFDA/" # Local path that you want to copy from (no tar file)
endif
set COMPUTER_OPTION = "hera" # hera/cheyenne
set CONFIG_OPTION = (4) # 4)Intel(dmpar) 8)GNU(dmpar) for Cheyenne ONLY
###############################################
###############################################
#!!!!!!!!!STOP User Define Here!!!!!!!!!!!!!!!#
###############################################
###############################################
set NUM_CONFIG = $#CONFIG_OPTION  # # of configurations
echo 'NUM_CONFIG = ' $NUM_CONFIG
echo 'CONFIG_OPTION = ' $CONFIG_OPTION
echo 'You are compiling the UPP code on' $COMPUTER_OPTION'.'

# Clone the repository
if ($source == 1)then
  rm -rf $FILE_NAME
  git clone -b $branch $repository $FILE_NAME
# Copy local path and make clean
else if ($source == 2)then
  cp -ra $upppath $FILE_NAME
  cd $FILE_NAME
  ./clean -a
  cd ../
endif
if ($? != 0)then
  echo "error cloning repository"
  exit
endif

# Load modules and set environment based on system/configuration
set i = 1
while ($i <= $NUM_CONFIG)
if($CONFIG_OPTION[$i] == 4)then
  rm -rf ${FILE_NAME}_Intel_dmpar
  cp -ra ${FILE_NAME} ${FILE_NAME}_Intel_dmpar
  cd ${FILE_NAME}_Intel_dmpar
  if ($COMPUTER_OPTION == "hera" || $COMPUTER_OPTION == "HERA") then
    module purge
    module load intel/18.0.5.274  impi/2018.0.4  cmake/3.16.1
    module use -a /scratch1/BMC/gmtb/software/NCEPLIBS-ufs-v2.0.0/intel-18.0.5.274/impi-2018.0.4/
    setenv CXX icpc
    setenv CC icc
    setenv FC ifort
    mkdir build && cd build
    cmake .. -DCMAKE_INSTALL_PREFIX=.. -DCMAKE_PREFIX_PATH=/scratch1/BMC/gmtb/software/NCEPLIBS-ufs-v2.0.0/intel-18.0.5.274/impi-2018.0.4
  else if ($COMPUTER_OPTION == "cheyenne" || $COMPUTER_OPTION == "CHEYENNE") then
    module purge
    module load intel/19.1.1 cmake/3.16.4 mpt/2.19 ncarenv/1.3
    setenv CXX icpc
    setenv CC icc
    setenv FC ifort
    mkdir build && cd build
    cmake .. -DCMAKE_INSTALL_PREFIX=.. -DCMAKE_PREFIX_PATH=/glade/p/ral/jntp/GMTB/tools/NCEPLIBS-ufs-v2.0.0/intel-19.1.1/mpt-2.19/
  endif
else if($CONFIG_OPTION[$i] == 8)then
  rm -rf ${FILE_NAME}_GNU_dmpar
  cp -ra ${FILE_NAME} ${FILE_NAME}_GNU_dmpar
  cd ${FILE_NAME}_GNU_dmpar
  if ($COMPUTER_OPTION == "hera" || $COMPUTER_OPTION == "HERA") then
    echo 'Note: No GNU bulit on Hera!!'
    #module purge
    #module load gnu/9.2.0 cmake/3.16.1
    #module use -a /scratch1/BMC/gmtb/software/modulefiles/gnu-9.2.0/mpich-3.3.2
    #module load mpich/3.3.2
    #setenv CXX g++
    #setenv CC gcc
    #setenv FC gfortran
    #mkdir build && cd build
    #cmake .. -DCMAKE_INSTALL_PREFIX=.. -DCMAKE_PREFIX_PATH=/scratch1/BMC/gmtb/software/NCEPLIBS-ufs-v2.0.0/gnu-9.2.0/mpich-3.3.2
  else if ($COMPUTER_OPTION == "cheyenne" || $COMPUTER_OPTION == "CHEYENNE") then
    module purge
    module load ncarenv/1.3  gnu/10.1.0  ncarcompilers/0.5.0  mpt/2.19  cmake/3.18.2
    module use -a /glade/p/ral/jntp/GMTB/tools/NCEPLIBS-ufs-v2.0.0/gnu-10.1.0/mpt-2.19/modules
    module load NCEPLIBS/2.0.0
    setenv CXX g++
    setenv CC gcc
    setenv FC gfortran
    mkdir build && cd build
    cmake .. -DCMAKE_INSTALL_PREFIX=.. -DCMAKE_PREFIX_PATH=/glade/p/ral/jntp/GMTB/tools/NCEPLIBS-ufs-v2.0.0/gnu-10.1.0/mpt-2.19/
  endif
endif

# Build UPP
make install > compile.log

# Get the CRTM fix files
cd ../
mkdir crtm && cd crtm
wget https://github.com/NOAA-EMC/EMC_post/releases/download/upp_v9.0.0/fix.tar.gz
tar -xzf fix.tar.gz

cd ../..
@ i++
end

echo 'Exit'
exit
