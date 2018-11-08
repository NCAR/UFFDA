#!/bin/csh
###############################################
#
# Oirg. Code: Ka Yee Wong (NOAA/GSD) Jun  2017
# Edit. Code: Ka Yee Wong (NOAA/GSD) Nov  2018
# Tested on Theia:                   Nov  2018
# Tested on cheyenne:                Nov  2018
# Tested on Hydra by Tracy:          Nov  2018
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
set repository = "https://vlab.ncep.noaa.gov/redmine/projects/emc-post"
else if ($source == 2)then
set FILE_NAME = "DTC_UPP_local_path_test"  # Your preferred directory name
set upppath = "/gpfs/fs1/work/kayee/UPP/UFFDA/UPPV3.2"  # Local path that you want to copy from (no tar file)
else if ($source == 3)then
set FILE_NAME = "DTC_UPP_github_crtm"  # Your preferred directory name
#set FILE_NAME = "DTC_UPP_github_v6f54859"  # Your preferred directory name
set repository = "https://github.com/NCAR/UPP"
endif
set COMPUTER_OPTION = "CHEYENNE" # theia/cheyenne/hydra for now 
set CONFIG_OPTION = (4 3 7 8) #1)PGI(serial) 2)PGI(dmpar) 3)Intel(serial) 4)Intel(dmpar) 7)GNU(serial) 8)GNU(dmpar) 11)GNU(serial) on Hydra 12)GNU(dmpar) on Hydra
#set CONFIG_OPTION = (1 2 4 3 7 8) #1)PGI(serial) 2)PGI(dmpar) 3)Intel(serial) 4)Intel(dmpar) 7)GNU(serial) 8)GNU(dmpar) 11)GNU(serial) on Hydra 12)GNU(dmpar) on Hydra
###############################################
###############################################
#!!!!!!!!!STOP User Define Here!!!!!!!!!!!!!!!#
###############################################
###############################################
set NUM_CONFIG = $#CONFIG_OPTION  # # of configurations
echo 'NUM_CONFIG = ' $NUM_CONFIG
echo 'CONFIG_OPTION = ' $CONFIG_OPTION
set UPP_CONFIGURE_COMMAND="./configure"

echo 'You are compiling the UPP code on' $COMPUTER_OPTION'.'
if ($source == 1)then
rm -rf $FILE_NAME
git clone $repository $FILE_NAME
else if ($source == 2)then
rm -rf $FILE_NAME
cp -ra $upppath $FILE_NAME
cd $FILE_NAME
./clean -a
cd ../
else if ($source == 3)then
git clone --recurse-submodules $repository $FILE_NAME
endif

set i = 1
while ($i <= $NUM_CONFIG)
if($CONFIG_OPTION[$i] == 4)then
rm -rf ${FILE_NAME}_Intel_dmpar
cp -ra ${FILE_NAME} ${FILE_NAME}_Intel_dmpar
cd ${FILE_NAME}_Intel_dmpar
if ($COMPUTER_OPTION == "theia" || $COMPUTER_OPTION == "THEIA") then
module purge
module load intel/16.1.150
module load impi
module load netcdf/3.6.3
set targetDir='/scratch3/BMC/wrf-chem/KaYee/PRECOMPILED_WRF/WRFV3.9_Intel_dmpar_large-file'
else if ($COMPUTER_OPTION == "cheyenne" || $COMPUTER_OPTION == "CHEYENNE") then
module purge
module load intel mpt netcdf ncarcompilers
set targetDir='/gpfs/fs1/p/ral/jntp/UPP/PRE_COMPILED_CODE/WRFV3.9_Intel_dmpar_large-file'
else if ($COMPUTER_OPTION == "hydra" || $COMPUTER_OPTION == "HYDRA") then
#source /home/hertneky/wheezy-intel.csh
echo 'Note: No WRF bulit on hydra with Intel!!'
endif
else if($CONFIG_OPTION[$i] == 3)then
rm -rf ${FILE_NAME}_Intel_serial
cp -ra ${FILE_NAME} ${FILE_NAME}_Intel_serial
cd ${FILE_NAME}_Intel_serial
if ($COMPUTER_OPTION == "theia" || $COMPUTER_OPTION == "THEIA") then
module purge
module load intel/16.1.150
module load netcdf/3.6.3
set targetDir='/scratch3/BMC/wrf-chem/KaYee/PRECOMPILED_WRF/WRFV3.9_Intel_serial_large-file/'
else if ($COMPUTER_OPTION == "cheyenne" || $COMPUTER_OPTION == "CHEYENNE") then
module purge
module load intel netcdf ncarcompilers
set targetDir='/gpfs/fs1/p/ral/jntp/UPP/PRE_COMPILED_CODE/WRFV3.9_Intel_serial_large-file'
else if ($COMPUTER_OPTION == "hydra" || $COMPUTER_OPTION == "HYDRA") then
#source /home/hertneky/wheezy-intel.csh
echo 'Note: No WRF bulit on hydra with Intel!!'
endif
else if($CONFIG_OPTION[$i] == 7 || $CONFIG_OPTION[$i] == 11)then
rm -rf ${FILE_NAME}_GNU_serial
cp -ra ${FILE_NAME} ${FILE_NAME}_GNU_serial
cd ${FILE_NAME}_GNU_serial
pwd
if ($COMPUTER_OPTION == "theia" || $COMPUTER_OPTION == "THEIA") then
echo 'Note: No WRF serial GNU bulit on Theia!!'
else if ($COMPUTER_OPTION == "cheyenne" || $COMPUTER_OPTION == "CHEYENNE") then
module purge
module load gnu netcdf ncarcompilers
set targetDir='/gpfs/fs1/p/ral/jntp/UPP/PRE_COMPILED_CODE/WRFV3.9_GNU_serial_large-file'
echo $targetDir
else if ($COMPUTER_OPTION == "hydra" || $COMPUTER_OPTION == "HYDRA") then
source /home/hertneky/wheezy-gf.csh
set targetDir='/d1/hertneky/wtf_upp/Builds/WRFV3.7.1.32/em_real/WRFV3'
endif
else if($CONFIG_OPTION[$i] == 8 || $CONFIG_OPTION[$i] == 12)then
rm -rf ${FILE_NAME}_GNU_dmpar
cp -ra ${FILE_NAME} ${FILE_NAME}_GNU_dmpar
cd ${FILE_NAME}_GNU_dmpar
if ($COMPUTER_OPTION == "theia" || $COMPUTER_OPTION == "THEIA") then
echo 'Note: No WRF parallel GNU bulit on Theia!!'
else if ($COMPUTER_OPTION == "cheyenne" || $COMPUTER_OPTION == "CHEYENNE") then
module purge
module load gnu mpt netcdf ncarcompilers
set targetDir='/gpfs/fs1/p/ral/jntp/UPP/PRE_COMPILED_CODE/WRFV3.9_GNU_dmpar_large-file'
else if ($COMPUTER_OPTION == "hydra" || $COMPUTER_OPTION == "HYDRA") then
source /home/hertneky/wheezy-gf.csh
set targetDir='/d1/hertneky/wtf_upp/Builds/WRFV3.7.1.34/em_real/WRFV3'
endif
else if($CONFIG_OPTION[$i] == 1)then
rm -rf ${FILE_NAME}_PGI_serial
cp -ra ${FILE_NAME} ${FILE_NAME}_PGI_serial
cd ${FILE_NAME}_PGI_serial
if ($COMPUTER_OPTION == "theia" || $COMPUTER_OPTION == "THEIA") then
module purge
module load pgi/17.1
module load netcdf/3.6.3
set targetDir='/scratch3/BMC/wrf-chem/KaYee/PRECOMPILED_WRF/WRFV3.9_PGI_serial_large-file/'
else if ($COMPUTER_OPTION == "cheyenne" || $COMPUTER_OPTION == "CHEYENNE") then
module purge
module load pgi netcdf ncarcompilers
set targetDir='/gpfs/fs1/p/ral/jntp/UPP/PRE_COMPILED_CODE/WRFV3.9_PGI_serial_large-file'
else if ($COMPUTER_OPTION == "hydra" || $COMPUTER_OPTION == "HYDRA") then
source /home/hertneky/wheezy-pgi.csh
set targetDir='/d1/hertneky/wtf_upp/Builds/WRFV3.7.1.1/em_real/WRFV3'
endif
else if($CONFIG_OPTION[$i] == 2)then
rm -rf ${FILE_NAME}_PGI_dmpar
cp -ra ${FILE_NAME} ${FILE_NAME}_PGI_dmpar
cd ${FILE_NAME}_PGI_dmpar
if ($COMPUTER_OPTION == "theia" || $COMPUTER_OPTION == "THEIA") then
module purge
module load pgi/17.1
module load mvapich2/2.1rc1
module load netcdf/3.6.3
set targetDir='/scratch3/BMC/wrf-chem/KaYee/PRECOMPILED_WRF/WRFV3.9_PGI_dmpar_large-file/'
else if ($COMPUTER_OPTION == "cheyenne" || $COMPUTER_OPTION == "CHEYENNE") then
module purge
module load pgi mpt netcdf ncarcompilers
set targetDir='/gpfs/fs1/p/ral/jntp/UPP/PRE_COMPILED_CODE/WRFV3.9_PGI_dmpar_large-file'
else if ($COMPUTER_OPTION == "hydra" || $COMPUTER_OPTION == "HYDRA") then
source /home/hertneky/wheezy-pgi.csh
set targetDir='/d1/hertneky/wtf_upp/Builds/WRFV3.7.1.3/em_real/WRFV3'
endif
endif
setenv WRF_DIR $targetDir
#pwd

#./clean

# Put interactive "configure" options in a file, then pass to configure.
cat > ./CONFIG_OPTIONS << EOF
$CONFIG_OPTION[$i]
EOF
#$UPP_CONFIG_OPTION
#EOF

$UPP_CONFIGURE_COMMAND < ./CONFIG_OPTIONS

if ($COMPUTER_OPTION == "theia" || $COMPUTER_OPTION == "THEIA") then
if($CONFIG_OPTION[$i] == 4)then
set newFC = 'mpiifort'
sed -i -e "/DM_FC  =/ s|= .*|= $newFC|" configure.upp
set newF90 = 'mpiifort -free'
sed -i -e "/DM_F90 =/ s|= .*|= $newF90|" configure.upp
set newCC = 'mpiicc'
sed -i -e "/DM_CC  =/ s|= .*|= $newCC|" configure.upp
endif
endif

date > StartTime.txt
./compile > compile.log 
date > EndTime.txt
if (-e bin/copygb.exe && -e bin/ndate.exe && -e bin/unipost.exe) then
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
