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
set source = (2) # 1) source code from vlab 2) source code from local path 3) source code from github
if ($source == 1)then
  set FILE_NAME = "DTC_UPP_vlab"  # Your preferred directory name
  set repository = "https://vlab.ncep.noaa.gov/code-review/EMC_post"
  set branch = "dtc_post_v4.0.1"
else if ($source == 2)then
  set FILE_NAME = "v9.0.0"  # Your preferred directory name
  set upppath = "/glade/scratch/kayee/UPP/UFFDA/UPPv9.0.0/EMC_post"
  #set upppath = "/glade/scratch/kayee/UPP/UFFDA/DTC_post_v4.1_ps12/DTC_post_v4.1/"  # Local path that you want to copy from (no tar file)
  #set upppath = "/glade/work/kavulich/UPP/UFFDA/EMC_post_mkavulich"  # Local path that you want to copy from (no tar file)
else if ($source == 3)then
  set FILE_NAME = "v9.0.0"  # Your preferred directory name
  #set FILE_NAME = "DTC_UPP_github_v6f54859"  # Your preferred directory name
  set repository = "https://github.com/NOAA-EMC/EMC_post"
  #set branch = "release/public-v2"
  set branch = "upp_v9.0.0"
endif
set COMPUTER_OPTION = "cheyenne" # hera/cheyenne/puffling for now 
set CONFIG_OPTION = (8) #1)PGI(serial) 2)PGI(dmpar) 3)Intel(serial) 4)Intel(dmpar) 7)GNU(serial) 8)GNU(dmpar)
set DEBUG = 0
###############################################
###############################################
#!!!!!!!!!STOP User Define Here!!!!!!!!!!!!!!!#
###############################################
###############################################
set NUM_CONFIG = $#CONFIG_OPTION  # # of configurations
echo 'NUM_CONFIG = ' $NUM_CONFIG
echo 'CONFIG_OPTION = ' $CONFIG_OPTION
echo 'You are compiling the UPP code on' $COMPUTER_OPTION'.'
if ($source == 1)then
  rm -rf $FILE_NAME
  rm -rf EMC_post
  git clone -b $branch --recurse-submodules $repository 
  cp -ra EMC_post/comupp $FILE_NAME
else if ($source == 2)then
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
else if($CONFIG_OPTION[$i] == 8 || $CONFIG_OPTION[$i] == 12)then
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
    module load ncarenv/1.3
    module load gnu/10.1.0
    module load  ncarcompilers/0.5.0
    module load mpt/2.19
    module load cmake/3.18.2
    module use -a /glade/p/ral/jntp/GMTB/tools/NCEPLIBS-ufs-v2.0.0/gnu-10.1.0/mpt-2.19/modules
    module load NCEPLIBS/2.0.0
    setenv CXX g++
    setenv CC gcc
    setenv FC gfortran
    mkdir build && cd build
    cmake .. -DCMAKE_INSTALL_PREFIX=.. -DCMAKE_PREFIX_PATH=/glade/p/ral/jntp/GMTB/tools/NCEPLIBS-ufs-v2.0.0/gnu-10.1.0/mpt-2.19/
  endif
endif
make install > compile.log

cd ../
mkdir crtm && cd crtm
wget https://github.com/NOAA-EMC/EMC_post/releases/download/upp-v9.0.0/fix.tar.gz
tar -xzf fix.tar.gz

cd ../..
@ i++
end

echo 'Exit'
exit

