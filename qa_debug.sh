#! /bin/bash

# Clear screen
clear

REINSTALL=$1
CLEAN_BUILD=$2

BUILD_COMMAND="assembleQaDebug"
CLEAN_BUILD_COMMAND="clean assembleQaDebug"
FLAVOR_NAME="QA DEBUG"
PACKAGE_NAME="com.pcsalt.example"
FILE_NAME="tatasky-stage-arm-debug.apk"
LAUNCHER_NAME="com.pcsalt.example.splash.SplashActivity"

# display start time
start_time=$(date)

echo
echo -e "\t\t\e[1;42mBuild started at: $start_time\e[0m"

# move to Project directory
cd ..
echo -e '\e[1;31m==============================================================\e[0m'
echo -e '\t\t\e[1;42mRunning '$BUILD_COMMAND'\e[0m'
echo -e '\e[1;31m==============================================================\e[0m'

if [ ! -z $CLEAN_BUILD ]; then
	clean_build=$CLEAN_BUILD
else
	echo -n "Clean before building (y/n) > "
	read -n1 -t 5 clean_build
fi

if [ ! -z $clean_build ] && [ $clean_build = "y" ]; then
	./gradlew $CLEAN_BUILD_COMMAND
else
	./gradlew --no-rebuild $BUILD_COMMAND
fi

retval=$?


if [ $retval -eq 0 ]; then
	echo -e '\t\t\e[1;42mBuild Created : ' $FLAVOR_NAME '\e[0m'
	echo $REINSTALL;

	if [ ! -z $REINSTALL ]; then
		fresh_install=$REINSTALL
	else
		echo -n "Install fresh build (y/n, any other key for no) > "
		read -n1 -t 5 fresh_install
	fi

	echo
	echo
	echo -e '\e[1;31m==============================================================\e[0m'
	echo -e '\t\t\e[1;42mWaiting for device to come online\e[0m'
	adb wait-for-device
	echo -e '\e[1;31m==============================================================\e[0m'
	echo -e '\t\t\e[1;42mList of devices\e[0m'
	echo -e '\e[1;31m==============================================================\e[0m'
	adb devices
	echo -e '\e[1;31m==============================================================\e[0m'
	if [ ! -z $fresh_install ] && [ $fresh_install = "y" ]; then
		echo -e '\e[1;42mUninstalling previous build\e[0m'
		adb uninstall $PACKAGE_NAME
	fi

	cd app/build/outputs/apk/stage/debug/
	echo -e '\e[1;42minstalling ' $FLAVOR_NAME '\e[0m'
	adb install -r $FILE_NAME
	
	echo -e '\e[1;42mStarting ' $FLAVOR_NAME '\e[0m'
	
	if [ $? -eq 0 ]; then
		adb shell am start -n $PACKAGE_NAME"/"$LAUNCHER_NAME -a android.intent.action.MAIN -c android.intent.category.LAUNCHER
	else
		echo -e '\e[1;42merror while starting \e[0m'
	fi
elif [ $retval -eq 130 ]; then
	echo -e '\e[1;42mBuild process stopped\e[0m'
else
	echo -e '\e[1;42merror while building project\e[0m'
fi

# display end time
end_time=$(date)

echo
echo -e "\t\t\e[1;42mBuild ended at: $end_time\e[0m"
