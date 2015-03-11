#!/bin/bash
# This script makes a compressed archive of the current user's desktop of log files, system diagnostics, and other Citrix Online related items.
# Written by Brian Carter & Kyle Halversen
#cutthis if [ $@ = "GoToAssist_Corporate" ]; then

# Change the path or name of the files here:
FILEPATH=~/Desktop
DIRNAME=Citrix_Logs_G2ACorp_$(date +%s)
#
# Don't change this:
TEMPDIR=$FILEPATH/.$DIRNAME
ENDFILE=$FILEPATH/$DIRNAME.tgz
LOGFILE=~/Library/Logs/com.citrixonline.g2logfiles.log

# Trap to remove the temporary directory.
cleanup() {
	rm -rf $TEMPDIR
}
trap "cleanup" EXIT

# Begin log file
	echo "GoToLogFiles log started $(date)" > $LOGFILE
	echo "Product: GoToAssist Corporate" >> $LOGFILE

# Create a temporary folder if it does not already exist.
	if [ ! -d $TEMPDIR ]; then mkdir $TEMPDIR; fi

# Copy CrashReporter files to a temporary folder.
	rsync -aP --exclude="MobileDevice" ~/Library/Logs/CrashReporter/* $TEMPDIR/CrashReporterUser/ >> $LOGFILE
	rsync -aP /Library/Logs/DiagnosticReports/* $TEMPDIR/CrashReporterSystem/ >> $LOGFILE

# Copy the system log to the temporary folder.
	rsync -aP /Private/Var/Log/system.log* $TEMPDIR/SystemLog/ >> $LOGFILE

# Copy Endpoint Logs to the temporary folder.
	rsync -aP ~/Library/Logs/com.citrixonline.g2ac* $TEMPDIR/Endpoint_Logs/ >> $LOGFILE
	rsync -aP ~/Library/Logs/com.citrixonline.g2a.customer $TEMPDIR/Endpoint_Logs_Customer/ >> $LOGFILE

# Copy launcher logs
	rsync -aP ~/Library/Logs/com.citrixonline.WebDeployment/* $TEMPDIR/Launcher_Logs/ >> $LOGFILE

# Get a list of running applications and installed applications.
	ps aux > $TEMPDIR/Processes.txt
	system_profiler SPApplicationsDataType >> $TEMPDIR/System_Profiler.txt
	system_profiler SPSoftwareDataType >> $TEMPDIR/System_Profiler.txt
	system_profiler SPHardwareDataType >> $TEMPDIR/System_Profiler.txt
	system_profiler SPDisplaysDataType >> $TEMPDIR/System_Profiler.txt
	system_profiler SPPowerDataType >> $TEMPDIR/System_Profiler.txt
	system_profiler SPAudioDataType >> $TEMPDIR/System_Profiler.txt
	system_profiler SPSerialATADataType >> $TEMPDIR/System_Profiler.txt

# Create a compressed archive of everything grabbed.
	tar -czf $ENDFILE -C $TEMPDIR .

# Close log file
	echo "Closed $(date)." >> $LOGFILE
