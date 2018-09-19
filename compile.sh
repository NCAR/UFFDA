#!/bin/csh
###############################################
#
# Oirg. Code: Ka Yee Wong (NOAA/GSD) Jun  2017
# Edit. Code: Ka Yee Wong (NOAA/GSD) Jul  2017
# Edit. Code: Ka Yee Wong (NOAA/GSD) Aug  2017
# Edit. Code: Ka Yee Wong (NOAA/GSD) Aug  2018
# Edit. Code: Ka Yee Wong (NOAA/GSD) Sep  2018
# Tested on Theia:                   Jun  2017
# Tested on cheyenne:                Sep  2018
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
set TAR_FILE_NAME = "DTC_upp_v3.2"
#set TAR_FILE_NAME = "prerelease-V3.2-betaB-20171113"
#set TAR_FILE_NAME = "prerelease-V3.2-beatA-20171106"
set TAR_FILE_EXT = ".tar"
set CONFIG_OPTION = (7) #1)PGI(serial) 2)PGI(dmpar) 4)Intel(dmpar) 3)Intel(serial) 7)GNU(serial) 8)GNU(dmpar)
#set CONFIG_OPTION = (4 3 8 7) #1)PGI(serial) 2)PGI(dmpar) 4)Intel(dmpar) 3)Intel(serial) 7)GNU(serial) 8)GNU(dmpar)
#set CONFIG_OPTION = (4 3 7 8) #1)PGI(serial) 2)PGI(dmpar) 4)Intel(dmpar) 3)Intel(serial) 7)GNU(serial) 8)GNU(dmpar)
#set CONFIG_OPTION = (1 2 4 3 7 8) #1)PGI(serial) 2)PGI(dmpar) 4)Intel(dmpar) 3)Intel(serial) 7)GNU(serial) 8)GNU(dmpar)
###############################################
###############################################
#!!!!!!!!!STOP User Define Here!!!!!!!!!!!!!!!#
###############################################
###############################################
set NUM_CONFIG = $#CONFIG_OPTION  # # of configurations
echo 'NUM_CONFIG = ' $NUM_CONFIG
set UPP_CONFIGURE_COMMAND="./configure"

set tarname = `tar --exclude="*/*" -tf $TAR_FILE_NAME$TAR_FILE_EXT`
#set tarname = `tar --exclude="*/*" -tf ${TAR_FILE_NAME}${TAR_FILE_EXT}`
set dirname = `echo $tarname | rev | cut -c 2- | rev`

set i = 1
while ($i <= $NUM_CONFIG)
if($CONFIG_OPTION[$i] == 4)then
rm -rf ${TAR_FILE_NAME}_Intel_dmpar
tar -xvf $TAR_FILE_NAME$TAR_FILE_EXT
mv $dirname ${TAR_FILE_NAME}_Intel_dmpar
cd ${TAR_FILE_NAME}_Intel_dmpar
module load intel
#cd UPPV3.1_config$CONFIG_OPTION[$i]
set targetDir='/gpfs/p/ral/jnt/UPP/PRE_COMPILED_CODE/WRFV3.9_Intel_dmpar_large-file'
else if($CONFIG_OPTION[$i] == 3)then
rm -rf ${TAR_FILE_NAME}_Intel_serial
tar -xvf $TAR_FILE_NAME$TAR_FILE_EXT
mv $dirname ${TAR_FILE_NAME}_Intel_serial
cd ${TAR_FILE_NAME}_Intel_serial
module load intel
set targetDir='/gpfs/p/ral/jnt/UPP/PRE_COMPILED_CODE/WRFV3.9_Intel_serial_large-file'
else if($CONFIG_OPTION[$i] == 7)then
rm -rf ${TAR_FILE_NAME}_GNU_serial
tar -xvf $TAR_FILE_NAME$TAR_FILE_EXT
mv $dirname ${TAR_FILE_NAME}_GNU_serial
cd ${TAR_FILE_NAME}_GNU_serial
module load gnu
set targetDir='/gpfs/p/ral/jnt/UPP/PRE_COMPILED_CODE/WRFV3.9_GNU_serial_large-file'
else if($CONFIG_OPTION[$i] == 8)then
rm -rf ${TAR_FILE_NAME}_GNU_dmpar
tar -xvf $TAR_FILE_NAME$TAR_FILE_EXT
mv $dirname ${TAR_FILE_NAME}_GNU_dmpar
cd ${TAR_FILE_NAME}_GNU_dmpar
module load gnu
set targetDir='/gpfs/p/ral/jnt/UPP/PRE_COMPILED_CODE/WRFV3.9_GNU_dmpar_large-file'
else if($CONFIG_OPTION[$i] == 1)then
rm -rf ${TAR_FILE_NAME}_PGI_serial
tar -xvf $TAR_FILE_NAME$TAR_FILE_EXT
mv $dirname ${TAR_FILE_NAME}_PGI_serial
cd ${TAR_FILE_NAME}_PGI_serial
module load pgi
set targetDir='/gpfs/p/ral/jnt/UPP/PRE_COMPILED_CODE/WRFV3.9_PGI_serial_large-file'
else if($CONFIG_OPTION[$i] == 2)then
rm -rf ${TAR_FILE_NAME}_PGI_dmpar
tar -xvf $TAR_FILE_NAME$TAR_FILE_EXT
mv $dirname ${TAR_FILE_NAME}_PGI_dmpar
cd ${TAR_FILE_NAME}_PGI_dmpar
module load pgi
set targetDir='/gpfs/p/ral/jnt/UPP/PRE_COMPILED_CODE/WRFV3.9_PGI_dmpar_large-file'
endif
setenv WRF_DIR $targetDir
#pwd

#./clean


#./configure
## THEIA #
##set newFC = 'mpiifort'
##sed -i -e "/DM_FC  =/ s|= .*|= $newFC|" configure.upp
##set newF90 = 'mpiifort -free'
#sed -i -e "/DM_F90 =/ s|= .*|= $newF90|" configure.upp
##set newCC = 'mpiicc'
##sed -i -e "/DM_CC  =/ s|= .*|= $newCC|" configure.upp

# Put interactive "configure" options in a file, then pass to configure.
cat > ./CONFIG_OPTIONS << EOF
$CONFIG_OPTION[$i]
EOF
#$UPP_CONFIG_OPTION
#EOF

$UPP_CONFIGURE_COMMAND < ./CONFIG_OPTIONS

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

echo 'Exit'
exit
