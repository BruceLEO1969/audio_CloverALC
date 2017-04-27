#!/bin/sh
# Maintained by: toleda for: github.com/toleda/audio_cloverALC
gFile="audio_cloverALC-120.command_v1.0d"
# gFile="audio_pikeralphaALC-120.command_v1.0d"
# Credit: bcc9, RevoGirl, PikeRAlpha, SJ_UnderWater, RehabMan, TimeWalker75a, lisai9093
#
# OS X Clover Realtek ALC Onboard Audio
#
# Enables OS X Realtek ALC onboard audio in 10.12, 10.11, 10.10, 10.9 and 10.8, all versions
# 1. Supports Realtek ALC885, 887, 888, 889, 892, 898 and 1150
# 2. Clover patched native AppleHDA.kext installed in System/Library/Extensions
#
# Requirements
# 1. OS X: 10.12/10.11/10.10/10.9/10.8, all versions
# 2. Native AppleHDA.kext (if not installed, run 10.x installer)
# 3. Supported Realtek ALC on board audio codec (see above)
# 4. Audio ID: 1, 2 or 3 Injection, see https://github.com/toleda/audio_ALCinjection
#
# Installation
# 1. Double click audio_cloverALC-120.command
# 2. Enter password at prompt
# 3. For Clover/EFI, EFI partition must be mounted before running script
# 4. For Clover/Legacy, answer y to Confirm Clover Legacy Install (y/n)
# 5. Confirm Realtek ALCxxx (y/n): (885, 887, 888, 889, 892, 898, 1150)
# 6. Clover Audio ID Injection (y/n):
#    If y:
# 7. Use Audio ID: x (y/n):
#    If n:
#    Audio IDs:
#    1 - 3/5/6 port Realtek ALCxxx audio
#    2 - 3 port (5.1) Realtek ALCxxx audio (n/a 885)
#    3 - HD3000/HD4000 HDMI audio w/Realtek ALCxxx audio (n/a 885/1150 & 887/888 Legacy)
# 8. Select Audio ID (1, 2 or 3)
# 9. Restart
#
# Change log:
# v1.0a - 7/15/16: Initial 10.12 support
# v1.0b0 - 8/7/16: KextTo Patch fix
# v1.0c0 - 8/16/16: Clean up
# v1.0d0 - 8/24/16: Clean up, synch with realtekALC and pikeralphaALC

echo " "
echo "Agreement"
echo "The audio_cloverALC script is for personal use only. Do not distribute"
echo "the patch, any or all of the files or the resulting patched AppleHDA.kext" 
echo "for any reason without permission. The audio_cloverALC script is"
echo "provided as is and without any kind of warranty."
echo " "

# debug=0 - normal install,
# debug=1 - test drive: copy config.plist to Desktop, edited config.plist, realtekALC.kext, layout_.xml and Platforms files copied to Desktop/codec

# set initial variables
gDebug=0
gSysVer=`sw_vers -productVersion`
gSysName="Mavericks"
gStartupDisk=EFI
gCloverDirectory=/Volumes/$gStartupDisk/EFI/CLOVER
gDesktopDirectory=/Users/$(whoami)/Desktop/
gLibraryDirectory=/Library/Extensions
gExtensionsDirectory=/System/Library/Extensions
gHDAContentsDirectory=$gExtensionsDirectory/AppleHDA.kext/Contents
gHDAHardwarConfigDirectory=$gHDAContentsDirectory/Plugins/AppleHDAHardwareConfigDriver.kext/Contents
gHDAControllerbinaryDirectory=$gHDAContentsDirectory/Plugins/AppleHDAController.kext/Contents/MacOS
gAudioid=1
gLayoutid=1
gPatch="-toledaALC"
gCodec=892
gLegacy=n
gController=n
gMake=0
gMB=0
# gCodecsinstalled
# gCodecVendor
# gCodecDevice
# gCodecName
# gCodec
gCloverALC=1
gPikerAlphaALC=0
gRealtekALC=0
gAudioidvalid=n
gCodecvalid=n
gtestALC=0

# debug
if [ $gDebug = 2 ]; then
    echo "gDebug = $gDebug - ${gDebugMode[$gDebug]}"
    echo "gMake = $gMake"
    echo "gCloverALC = $gCloverALC"
    echo "gPikerAlphaALC = $gPikerAlphaALC"
    echo "gRealtekALC = $gRealtekALC"
    echo "gtestALC = $gtestALC"

# while true
# do
# read -p "OK (y/n): " choice3
# case "$choice3" in
# 	[yY]* ) break;;
# 	[nN]* ) exit;;
# 	* ) echo "Try again...";;
# esac
# done
fi

# verify system version
case ${gSysVer} in

    10.12* ) gSysName="Sierra"
    gSysFolder=kexts/10.12
    gSID=$(csrutil status)
    ;;

    10.11* ) gSysName="El Capitan"
    gSysFolder=kexts/10.11
    gSID=$(csrutil status)
    ;;

    10.10* ) gSysName="Yosemite"
    gSysFolder=kexts/10.10
    ;;

    10.9* ) gSysName="Mavericks"
    gSysFolder=kexts/10.9
    ;;

    10.8* ) gSysName="Mountain Lion"
    gSysFolder=kexts/10.8
    ;;

    * )
    echo "OS X Version: $gSysVer is not supported"
    echo "No system files were changed"
    echo "To save a Copy of this Terminal session: Terminal/Shell/Export Text As ..."
    exit 1
    ;;

esac

# debug
if [ $gDebug = 2 ]; then
    # gSysVer=10.9
    echo "System version: supported"
    echo "gSysVer = $gSysVer"
fi

gDebugMode[0]=Release
gDebugMode[1]=TestDrive
gDebugMode[2]=Debug

echo "File: $gFile"
echo "${gDebugMode[$gDebug]} Mode"

# debug
if [ $gMake = 1 ]; then
    if [ -d "$gDesktopDirectory/AppleHDA.kext" ]; then
        sudo rm -R "$gExtensionsDirectory/AppleHDA.kext"
    case $gSysName in

    "Sierra"|"El Capitan" )
    sudo cp -X $gDesktopDirectory/AppleHDA.kext $gExtensionsDirectory/AppleHDA.kext
    ;;

    "Yosemite"|"Mavericks"|"Mountain Lion" )
    sudo cp -R $gDesktopDirectory/AppleHDA.kext $gExtensionsDirectory/AppleHDA.kext
    ;;

    esac

    else
        echo "Error, no Desktop/AppleHDA.kext (native)"
        echo "No system files were changed"
        echo "To save a Copy of this Terminal session: Terminal/Shell/Export Text As ..."
    exit 1
    fi

    sudo chown -R root:wheel $gExtensionsDirectory/AppleHDA.kext
    sudo touch $gExtensionsDirectory
    gHDAversioninstalled=$(sudo /usr/libexec/PlistBuddy -c "Print ':CFBundleShortVersionString'" $gHDAContentsDirectory/Info.plist)
    echo "Desktop/AppleHDA.kext installed in $gExtensionsDirectory"
fi

# credit: mfram, http://forums.macrumors.com/showpost.php?p=18302055&postcount=6
# get startup disk name
gStartupDevice=$(mount | grep "on / " | cut -f1 -d' ')
gStartupDisk=$(mount | grep "on / " | cut -f1 -d' ' | xargs diskutil info | grep "Volume Name" | perl -an -F'/:\s+/' -e 'print "$F[1]"')

# debug
if [ $gDebug = 2 ]; then
    echo "Boot device: $gStartupDevice"
    echo "Boot volume: $gStartupDisk"
fi

# if [ $gCloverALC = 1 ]; then
#     echo "Verify EFI partition mounted, Finder/Devices/EFI"
#     echo "If not set, Terminal/Quit"
# fi

if [ $gRealtekALC = 1 ]; then
    gChameleonDirectory=/Volumes/"$gStartupDisk"/Extra

# debug
    if [ $gDebug = 2 ]; then
        echo "gChameleonDirectory = $gChameleonDirectory"
        echo "gSysName = $gSysName"
    fi

    if [[ -d $gChameleonDirectory ]]; then
        if [ -f "$gChameleonDirectory/org.chameleon.Boot.plist" ]; then
            cp -p "$gChameleonDirectory/org.chameleon.Boot.plist" "/tmp/org.chameleon.Boot.txt"

# debug
            if [ $gDebug = 2 ]; then
                echo "$gChameleonDirectory/org.chameleon.Boot.plist found"
            fi

        else
            echo "$$gChameleonDirectory/org.chameleon.Boot.plist not found"
            echo "No system files were changed"
            echo "To save a Copy of this Terminal session: Terminal/Shell/Export Text As ..."
            exit 1
        fi

        case $gSysName in

        "Sierra"|"El Capitan" )
        echo $gSID > /tmp/gsid.txt
        if [[ $(cat /tmp/gsid.txt | grep -c "disabled") = 0 ]]; then
            rm -R /tmp/gsid.txt
            echo "$gSID"
            echo ""
            echo "NOK to patch"
            echo "Add org.chameleon.Boot.plist/Kernel Flags = CsrActiveConfig=0x3 and restart"
            echo "No system files were changed"
            echo "To save a Copy of this Terminal session: Terminal/Shell/Export Text As ..."
            exit 1
        else
            rm -R /tmp/gsid.txt
            echo "$gSID"
            echo ""
            echo "OK to patch"
        fi
        ;;

        "Yosemite" )
        if [[ $(cat /tmp/org.chameleon.Boot.txt | grep -c "kext-dev-mode=1") = 0 ]]; then
            rm -R /tmp/org.chameleon.Boot.txt
            echo "Kernel Flags = kext-dev-mode=1 not found; patching not possible"
            echo "Add org.chameleon.Boot.plist/Kernel Flags = kext-dev-mode=1 and restart"
            echo "No system files were changed"
            echo "To save a Copy of this Terminal session: Terminal/Shell/Export Text As ..."
            exit 1
        else
            echo "Kernel Flags = kext-dev-mode=1 found"
        fi
        ;;
        esac
        rm -R /tmp/org.chameleon.Boot.txt

        else
# osmosis/other

    while true
    do
    read -p "No Clover/Chameleon files, confirm Osmosis/other install (y/n): " choice10
    case "$choice10" in

    [yY]* )
        case $gSysName in
        "Sierra"|"El Capitan" )

        echo $gSID > /tmp/gsid.txt
        if [[ $(cat /tmp/gsid.txt | grep -c "disabled") = 0 ]]; then
            rm -R /tmp/gsid.txt
            echo "$gSID"
            echo ""
            echo "NOK to patch"
            echo "Set Kernel Flag = CsrActiveConfig=0x3 and restart"
            echo "No system files were changed"
            echo "To save a Copy of this Terminal session: Terminal/Shell/Export Text As ..."
            exit 1
        else
        rm -R /tmp/gsid.txt
        echo "$gSID"
        echo ""
        echo "OK to patch"
        fi
        break
        ;;

        "Yosemite" )

        while true
        do
        read -p "kext-dev-mode=1 set (y/n): " choice11
        case "$choice11" in

        [yY]* ) break
        ;;

        [nN]* )
        echo "User terminated, set Boot Flag/kext-dev-mode=1 and restart"
        echo "No system files were changed"
        echo "To save a Copy of this Terminal session: Terminal/Shell/Export Text As ..."
        exit 1
        ;;

        * ) echo "Try again...";;
        esac
        done
        ;;
    
    esac
    break
    ;;

    [nN]* )
    echo "User terminated, no Clover/Chameleon files"
    echo "No system files were changed"
    echo "To save a Copy of this Terminal session: Terminal/Shell/Export Text As ..."
    exit 1
    ;;

    * ) echo "Try again...";;
    esac
    done

    fi

fi

# get password
gHDAversioninstalled=$(sudo /usr/libexec/PlistBuddy -c "Print ':CFBundleShortVersionString'" $gHDAContentsDirectory/Info.plist)

# exit if error
if [ "$?" != "0" ]; then
    echo "Error occurred, AppleHDA.kext/Contents/Info.plist/BundleShortVersionString not found"
    echo "No system files were changed"
    echo "To save a Copy of this Terminal session: Terminal/Shell/Export Text As ..."
    exit 1
fi

# set up clover (efi or legacy)
if [ $gCloverALC = 1 ]; then

# initialize variable
    choice8=n

# check for debug (debug=1 does not touch CLOVER folder)
case $gDebug in
0 )

# verify EFI install
gEFI=0
if [ -d $gCloverDirectory ]; then
     gEFI=1
fi

if [ $gEFI = 0 ]; then

    if [ -d '/Volumes/ESP/EFI/CLOVER' ]; then
        gCloverDirectory=/Volumes/ESP/EFI/CLOVER
        gEFI=1
    fi

fi

if [ $gEFI = 1 ]; then
    echo "EFI partition is mounted"
    if [ -f "$gCloverDirectory/config.plist" ]; then
        cp -p "$gCloverDirectory/config.plist" "/tmp/config.txt"

        case $gSysName in

        "Sierra"|"El Capitan" )
	    echo $gSID > /tmp/gsid.txt
            if [[ $(cat /tmp/gsid.txt | grep -c "disabled") = 0 ]]; then
            rm -R /tmp/gsid.txt 
            echo "$gSID"
            echo ""
            echo "NOK to patch"
            echo "Add config.plist/RtVariables/CsrActiveConfig=0x3 and restart"
            echo "No system files were changed"
            echo "To save a Copy of this Terminal session: Terminal/Shell/Export Text As ..."
            exit 1
        else
            rm -R /tmp/gsid.txt            
	     echo "$gSID"
            echo ""
	     echo "OK to patch"
        fi
        ;;

        "Yosemite" )
        if [[ $(cat /tmp/config.txt | grep -c "kext-dev-mode=1") = 0 ]]; then
            rm -R /tmp/config.txt
            echo "Boot/Arguments/kext-dev-mode=1 not found; patching not possible"
            echo "Add config.plist/Boot/Arguments/kext-dev-mode=1 and restart"
            echo "No system files were changed"
            echo "To save a Copy of this Terminal session: Terminal/Shell/Export Text As ..."
            exit 1
        else
            echo "Boot/Arguments = kext-dev-mode=1 found"
        fi
        ;;

        esac

        rm -R /tmp/config.txt
        cp -p "$gCloverDirectory/config.plist" "/tmp/config.plist"
        if [ -f "$gCloverDirectory/config-backup.plist" ]; then
            rm -R "$gCloverDirectory/config-backup.plist"
        fi
        cp -p "$gCloverDirectory/config.plist" "$gCloverDirectory/config-backup.plist"
    else
        echo "$gCloverDirectory/config.plist is missing"
        echo "No system files were changed"
        echo "To save a Copy of this Terminal session: Terminal/Shell/Export Text As ..."
        exit 1
    fi
else
    echo "EFI partition not mounted"

# confirm Clover Legacy install
    gCloverDirectory=/Volumes/"$gStartupDisk"/EFI/CLOVER
    if [ -d "$gCloverDirectory" ]; then
	    echo "$gStartupDisk/EFI folder found"
    else echo "$gStartupDisk/EFI not found"
	    echo "EFI/CLOVER folder not available to install audio"
	    echo "No system files were changed"
	    echo "To save a Copy of this Terminal session: Terminal/Shell/Export Text As ..."
	    exit 1
    fi

    while true
    do
    read -p "Confirm Clover Legacy Install (y/n): " choice8
    case "$choice8" in

    [yY]* )
#    gCloverDirectory=/Volumes/"$gStartupDisk"/EFI/CLOVER
    if [ -d "$gCloverDirectory" ]; then
        if [ -f "$gCloverDirectory/config.plist" ]; then

            cp -p "$gCloverDirectory/config.plist" "/tmp/config.txt"
            case $gSysName in

            "Sierra"|"El Capitan" )
	    	echo $gSID > /tmp/gsid.txt
        	if [[ $(cat /tmp/gsid.txt | grep -c "disabled") = 0 ]]; then
            	rm -R /tmp/gsid.txt 
                echo "$gSID"
                echo ""
                echo "NOK to patch"
                echo "Add config.plist/RtVariables/CsrActiveConfig=0x3 and restart"
                echo "No system files were changed"
                echo "To save a Copy of this Terminal session: Terminal/Shell/Export Text As ..."
                exit 1
            else
            	rm -R /tmp/gsid.txt                
		echo "$gSID"
               echo ""
		echo "OK to patch"
            fi
            ;;

            "Yosemite" )
            if [[ $(cat /tmp/config.txt | grep -c "kext-dev-mode=1") = 0 ]]; then
                rm -R /tmp/config.txt
                echo "Boot/Arguments/kext-dev-mode=1 not found; patching not possible"
                echo "Add config.plist/Boot/Arguments/kext-dev-mode=1 and restart"
                echo "No system files were changed"
                echo "To save a Copy of this Terminal session: Terminal/Shell/Export Text As ..."
                exit 1
            else
                echo "Boot/Arguments = kext-dev-mode=1 found"
            fi
            ;;

            esac

            cp -p "$gCloverDirectory/config.plist" "/tmp/config.plist"
            if [ -f "$gCloverDirectory/config-backup.plist" ]; then
                rm -R "$gCloverDirectory/config-backup.plist"
            fi
            cp -p "$gCloverDirectory/config.plist" "$gCloverDirectory/config-backup.plist"
        else
            echo "$gCloverDirectory/config.plist is missing"
            echo "No system files were changed"
            echo "To save a Copy of this Terminal session: Terminal/Shell/Export Text As ..."
        exit 1
        fi

    else
    echo "$gCloverDirectory not found"
    echo "No system files were changed"
    echo "To save a Copy of this Terminal session: Terminal/Shell/Export Text As ..."
    exit 1
    fi

    break
    ;;

    [nN]* )
    echo "User terminated, EFI partition/folder not mounted"
    echo “Mount EFI partition and Restart“
    echo "No system files were changed"
    echo "To save a Copy of this Terminal session: Terminal/Shell/Export Text As ..."
    exit 1
    ;;

    * ) echo "Try again...";;
    esac
    done
    fi
    ;;

1 )
    if [ -d "$gDesktopDirectory/config-basic.plist" ]; then  
       echo "Desktop/config-basic.plist copied missing"
       exit 1
    fi

    sudo cp -R "$gDesktopDirectory/config-basic.plist" /tmp/config.plist
    echo "Desktop/config-basic.plist copied to /tmp/config.plist"
   ;;

2 )
    echo "gHDAversioninstalled = $gHDAversioninstalled"
    if [ -d "$gDesktopDirectory/config-basic.plist" ]; then  
       echo "Desktop/config-basic.plist copied missing"
       exit 1
    fi

    sudo cp -R "$gDesktopDirectory/config-basic.plist" /tmp/config.plist
    echo "Desktop/config-basic.plist copied to /tmp/config.plist"
    ;;

* )
    echo "gDebug = $gDebug, fix"
    exit 1
    ;;
esac

fi

# exit if error
if [ "$?" != "0" ]; then
    if [ $choice8 != "y" ]; then
        echo "Error, $gStartupDisk/EFI not found"
        echo "No system files were changed"
        echo "To save a Copy of this Terminal session: Terminal/Shell/Export Text As ..."
        exit 1
    fi
    echo "Error, EFI partition not mounted"
    echo "No system files were changed"
    echo "To save a Copy of this Terminal session: Terminal/Shell/Export Text As ..."
    exit 1
fi

# debug
if [ $gDebug = 2 ]; then
    echo "EFI: success"
fi

# verify ioreg/HDEF
ioreg -rw 0 -p IODeviceTree -n HDEF > /tmp/HDEF.txt

if [[ $(cat /tmp/HDEF.txt | grep -c "HDEF@1") != 0 ]]; then
    gLayoutidioreg=$(cat /tmp/HDEF.txt | grep layout-id | sed -e 's/.*<//' -e 's/>//')
    gLayoutidhex="0x${gLayoutidioreg:6:2}${gLayoutidioreg:4:2}${gLayoutidioreg:2:2}${gLayoutidioreg:0:2}"
    gAudioid=$((gLayoutidhex))
    sudo rm -R /tmp/HDEF.txt
else
    echo "Error: no IOReg/HDEF; BIOS/audio/disabled or ACPI problem"
    echo "No system files were changed"
    echo "To save a Copy of this Terminal session: Terminal/Shell/Export Text As ..."
    sudo rm -R /tmp/HDEF.txt
exit 1
fi

# debug
if [ $gDebug = 2 ]; then
    echo "gLayoutidioreg = $gLayoutidioreg"
    echo "gLayoutidihex = $gLayoutidhex"
    echo "gAudioid = $gAudioid"
    echo "HDEF/Audio ID: success"
fi

# verify native s/l/e/applehda.kext 
if [ $gMake = 0 ]; then

    if [[ $(perl -le "print scalar grep /\x8b\x19\xd4\x11/, <>;" $gHDAContentsDirectory/MacOS/AppleHDA) = 0 ]]; then
        echo "codec: 8b19d411 is missing"
        echo "S/L/E/AppleHDA.kext is not native"
        echo "Install native AppleHDA.kext"
        echo "No system files were changed"
        echo "To save a Copy of this Terminal session: Terminal/Shell/Export Text As ..."
        exit 1
    fi

    if [[ $(perl -le "print scalar grep /\x84\x19\xd4\x11/, <>;" $gHDAContentsDirectory/MacOS/AppleHDA) = 0 ]]; then
        echo "codec: 8419d411 is missing"
        echo "S/L/E/AppleHDA.kext is not native"
        echo "Install native AppleHDA.kext"
        echo "No system files were changed"
        echo "To save a Copy of this Terminal session: Terminal/Shell/Export Text As ..."
        exit 1
    fi

    if [[ $(perl -le "print scalar grep /\x62\x02\xec\x10/, <>;" $gHDAContentsDirectory/MacOS/AppleHDA) = 0 ]]; then
        echo "codec: 6202ec10 is missing"
        echo "S/L/E/AppleHDA.kext is not native"
        echo "Install native AppleHDA.kext"
        echo "No system files were changed"
        echo "To save a Copy of this Terminal session: Terminal/Shell/Export Text As ..."
        exit 1
    fi

    case $gSysName in

    "Mountain Lion" )
    if [[ $(perl -le "print scalar grep /\xff\x87\xec\x1a/, <>;" $gHDAContentsDirectory/MacOS/AppleHDA) = 0 ]]; then
        echo "codec: ff87ec10 is missing"
        echo "S/L/E/AppleHDA.kext is not native"
        echo "Install native AppleHDA.kext"
        echo "No system files were changed"
        echo "To save a Copy of this Terminal session: Terminal/Shell/Export Text As ..."
        exit 1
    fi
    ;;

    esac

fi

# debug
if [ $gDebug = 2 ]; then
    echo "Native AppleHDA: success"
fi

# get installed codec/revision
gCodecsInstalled=$(ioreg -rxn IOHDACodecDevice | grep VendorID | awk '{ print $4 }' | sed -e 's/ffffffff//')
gCodecsVersion=$(ioreg -rxn IOHDACodecDevice | grep RevisionID| awk '{ print $4 }')

# debug
if [ $gDebug = 2 ]; then
# gCodecsInstalled=0x10ec0887
# gCodecsVersion=0x100101
# gCodecsVersion=0x100202
# gCodecsVersion=0x100302
# gCodecsInstalled=0x10ec0900
# gCodecsVersion=0x100001
# gCodecsInstalled=0x10134206
# gCodecsVersion=0x100302
    echo "gCodecsInstalled = $gCodecsInstalled"
    echo "gCodecsVersion = $gCodecsVersion"
fi

# no codecs detected
if [ -z "${gCodecsInstalled}" ]; then
    echo ""
    echo "No audio codec detected"
    echo "To save a Copy of this Terminal session: Terminal/Shell/Export Text As ..."
    exit 1
fi

# initialize variables
intel=n
amd=n
nvidia=n
realtek=n
unknown=n
alternate=n

# find realtek codecs
index=0
version=($gCodecsVersion)
for codec in $gCodecsInstalled
do

# debug
if [ $gDebug = 2 ]; then
    echo "Index = $index, Codec = $codec, Version = ${version[$index]}"
fi

# sort vendors and devices
case ${codec:2:4} in

    8086 ) Codecintelhdmi=$codec; intel=y
    ;;
    1002 ) Codecamdhdmi=$codec; amd=y
    ;;
    10de ) Codecnvidiahdmi=$codec; nvidia=y
    ;;
    10ec ) Codecrealtekaudio=$codec; Versionrealtekaudio=${version[$index]}; realtek=y
    ;;
    *) Codecunknownaudio=$codec; unknown=y
    ;;

esac
index=$((index + 1))
done

# debug
if [ $gDebug = 2 ]; then
    echo "HDMI audio codec(s)"
        if [ $intel = y ]; then
            echo "Intel:    $Codecintelhdmi"
        fi
        if [ $amd = y ]; then
            echo "AMD:      $Codecamdhdmi"
        fi
        if [ $nvidia = y ]; then
            echo "Nvidia:   $Codecnvidiahdmi"
        fi
    echo ""
    echo "Onboard audio codec"
        if [ $realtek = y ]; then
            echo "Realtek:  $Codecrealtekaudio"
            echo "Version:  $Versionrealtekaudio"
        fi
        if [ $unknown = y ]; then
            echo "Unknown:  $Codecunknownaudio"
        fi
fi

if [ $unknown = y ]; then

while true
do
read -p "Codec $Codecunknownaudio is not supported, continue (y/n): " choice7

case "$choice7" in
    [yY]* )  break;;
    [nN]* ) echo "No system files were changed"
        echo "To save a Copy of this Terminal session: Terminal/Shell/Export Text As ..."
        exit 1;;
    * ) echo "Try again..."
;;
esac

done

fi

# special names
if [ $realtek = y ]; then
    gCodecVendor=${Codecrealtekaudio:2:4}
    gCodecDevice=${Codecrealtekaudio:6:4}

# debug
    if [ $gDebug = 2 ]; then
        echo "gCodecVendor = $gCodecVendor"
        echo "gCodecDevice = $gCodecDevice"
    fi

    if [ ${gCodecDevice:0:1} = 0 ]; then
        gCodecName=${gCodecDevice:1:3}
    fi

    if [ $gCodecDevice = "0899" ]; then
        gCodecName=898
    fi

    if [ $gCodecDevice = "0900" ]; then
        gCodecName=1150
    fi

# debug
if [ $gDebug = 2 ]; then
    echo "Codec identification: success"
fi

if [ $gPikerAlphaALC = 1 ]; then
    echo ""
    echo "Note: when AppleHDA8Series asks:"
    echo "Do you want to copy AppleHDA$gCodec.kext to: /System/Library/Extensions? (y/n)"
    echo "Answer: n"
    echo ""
fi

#  validate_realtek codec
    case "$gCodecName" in
    269|283|885|887|888|889|892|898|1150 )

# confirm codec, go button
    while true
    do
    read -p "Confirm Realtek ALC$gCodecName (y/n): " choice3
    case "$choice3" in
        [yY]* ) gCodec=$gCodecName; gCodecvalid=y; break;;
        [nN]* ) break;;
    * ) echo "Try again...";;
    esac
    done
    ;;

    * ) echo "Realtek ALC$gCodecName is not supported with $gFile"
        echo "No system files were changed"
        echo "To save a Copy of this Terminal session: Terminal/Shell/Export Text As ..."
        exit 1
    ;;
    esac

# exit if error
    if [ "$?" != "0" ]; then
        echo Error: ??
        echo "No system files were changed"
        echo "To save a Copy of this Terminal session: Terminal/Shell/Export Text As ..."
        exit 1
    fi

fi

if [ $gCodecvalid != y ]; then

#  get supported codec
    echo "Supported RealtekALC codecs: 885, 887, 888, 889, 892, 898 or 1150 (0 to exit)"
    while true
    do
    read -p "Enter codec: " choice0
    case "$choice0" in
        269|283|885|887|888|889|892|898|1150 ) gCodec=$choice0; break;;
        0 ) echo "No system files were changed"
        echo "To save a Copy of this Terminal session: Terminal/Shell/Export Text As ..."
        exit 1;;

        * ) echo "Try again...";;
    esac
    done
# Versionrealtekaudio=0x100302

fi

# legacy

case "$gCodec" in

    887|888 )
    if [ $gMake = 0 ]; then

    case "$Versionrealtekaudio" in
        0x100302 ) echo "ALC$gCodec v_$Versionrealtekaudio (Current)"; gLegacy=n ;;
        0x100202 ) echo "ALC$gCodec v_$Versionrealtekaudio (Legacy)"; gLegacy=y ;;
        * ) echo "ALC$gCodec v_$Versionrealtekaudio not supported"

        while true
        do
        read -p "Use Legacy (v100202) Patch (y/n): " choice1
        case "$choice1" in
            [yY]* ) gLegacy=y; break;;
            [nN]* ) echo "No system files were changed"
            echo "To save a Copy of this Terminal session: Terminal/Shell/Export Text As ..."
            exit;;
            * ) echo "Try again...";;
        esac
        done
    esac

    else
    while true
    do
    read -p "887/888 Legacy (v100202) Patch (y/n): " choice1
    case "$choice1" in
        [yY]* ) gLegacy=y; break;;
        [nN]* ) gLegacy=n; break;;
        * ) echo "Try again...";;
    esac
    done

    fi

esac

case "$gCodec" in

887|892|898|1150 )

# verify ioreg/HDAU for HD4600 HDMI audio
   ioreg -rw 0 -p IODeviceTree -n HDAU > /tmp/HDAU.txt

   if [[ $(cat /tmp/HDAU.txt | grep -c "HDAU@3") != 0 ]]; then
       if [[ $(cat /tmp/HDAU.txt | grep -c "0c0c") != 0 ]]; then
           echo "HDAU@3 found, HD4600 HDMI audio capable"
           gController=1
       fi
   fi
   sudo rm -R /tmp/HDAU.txt

   ioreg -rw 0 -p IODeviceTree -n B0D3 > /tmp/B0D3.txt

   if [[ $(cat /tmp/B0D3.txt | grep -c "B0D3@3") != 0 ]]; then
        if [[ $(cat /tmp/B0D3.txt | grep -c "0c0c") != 0 ]]; then
            echo "B0D3@3 found, HDAU edit required for HD4600 HDMI audio"
            echo "dsdt edit/ssdt injection not available with this script"
            gController=1
        fi
   fi
   sudo rm -R /tmp/B0D3.txt

   ;;

esac

# HD4600 HDMI audio patch]
choice2=n
if [ $gController = 1 ]; then
    if [ $gCodec = 887 -a $gLegacy = y ]; then gController=n; else
        case "$gCodec" in

        887|892|898|1150 )
        while true
        do
        read -p "Patch AppleHDA.kext for HD4600 HDMI audio (y/n): " choice2
        case "$choice2" in
            [yY]* ) gController=y; break;;
            [nN]* ) gController=n; break;;
            * ) echo "Try again...";;
        esac
        done
        esac
    fi
fi

# validate audio id
case $gAudioid in
# 0|1|2|3 ) gAudioidvalid=y;;
1|2|3 ) gAudioidvalid=y;;
* )  
while true
do
read -p "Audio ID: $gAudioid is not supported, continue (y/n): " choice9
case "$choice9" in
	[yY]* ) gAudioid=0; gAudioidvalid=n break;;
	[nN]* ) echo "No system files were changed"; exit;;
	* ) echo "Try again..."
;;
esac
done
;;
esac

if [ $gRealtekALC = 1 ]; then
    if [ $gAudioidvalid = n ]; then
        echo ""
        echo "Note"
        echo "Set Audio ID injection before restart; valid IDs are:"
# echo "0 - dsdt/ssdt HDMI audio (AMD/Nvidia/Intel)"
        echo "1 - 3/5/6 port Realtek ALCxxx audio"
        echo "2 - 3 port (5.1) Realtek ALCxxx audio (n/a 885)"
        echo "3 - HD3000/HD4000/HD5xx HDMI audio and Realtek ALCxxx audio (n/a 885 & 887/888 Legacy)"
        echo "Caution: if Audio ID: $gAudioid is not fixed, no audio after restart"
    fi
fi

if [ $gCloverALC = 1 ]; then
    while true
    do
    read -p "Clover Audio ID Injection (y/n): " choice4
    case "$choice4" in
        [yY]* ) choice4=y; break;;
        [nN]* ) gAudioid=1; choice5=y; break;;
        * ) echo "Try again...";;
    esac
    done

    if [ $gAudioidvalid = n ]; then
    choice5=n
    else
        if [ $choice4 = y ]; then
        while true
        do
        read -p "Use Audio ID: $gAudioid (y/n): " choice5
        case "$choice5" in
            [yY]* ) break;;
            [nN]* ) choice5=n; break;;
            * ) echo "Try again...";;
        esac
        done
        fi
    fi

    if [ $choice5 = n ]; then
        echo "Audio IDs:"
# echo "0 - dsdt/ssdt HDMI audio (AMD/Nvidia/Intel)"
        echo "1 - 3/5/6 port Realtek ALCxxx audio"
        echo "2 - 3 port (5.1) Realtek ALCxxx audio (n/a 885)"
        echo "3 - HD3000/HD4000/HD5xx HDMI audio and Realtek ALCxxx audio (n/a 885 & 887/888 Legacy)"
        while true
        do
# read -p "Select Audio ID? (0, 1, 2 or 3): " choice6
        read -p "Select Audio ID: " choice6
        case "$choice6" in
#	0* ) gAudioid=0; break;;
            1* ) gAudioid=1; break;;
            2* ) gAudioid=2; if [ $gCodec = 885 ]; then echo "ID: 2 n/a, try again..."; else break; fi;;
            3* ) gAudioid=3; valid=y;
                if [ $gCodec = 885 ]; then valid=n; fi;
#                if [ $gCodec = 1150 ]; then valid=n; fi;
                if [ $gLegacy = y ]; then valid=n; fi;
                if [ $valid = n ]; then echo "ID: 3 n/a, try again..."; else break; fi;;
            * ) echo "Try again...";;
        esac
        done
    fi

fi



# debug
if [ $gDebug = 2 ]; then
    echo "gCodec = $gCodec"
    echo "gAudioid = $gAudioid"
    echo "gLegacy = $gLegacy"
    echo "gController = $gController"
    echo "Codec configuration: success"
fi

if [ $gPikerAlphaALC = 0 ]; then
echo ""
echo "Download ALC$gCodec files ..."

if [ $gtestALC = 0 ]; then
gDownloadLink="https://raw.githubusercontent.com/toleda/audio_ALC$gCodec/master/$gCodec.zip"
if [ $gLegacy = y ]; then
    Legacy=_v100202
    gDownloadLinkLegacy="https://raw.githubusercontent.com/toleda/audio_ALC$gCodec/master/$gCodec$Legacy.zip"
    sudo curl -o "/tmp/ALC$gCodec.zip" $gDownloadLinkLegacy
else
    sudo curl -o "/tmp/ALC$gCodec.zip" $gDownloadLink
fi

unzip -qu "/tmp/ALC$gCodec.zip" -d "/tmp/"

else

# confirm codec test
while true
do
    read -p "Confirm Realtek ALC$gCodec test (y/n): "  choice13
    case "$choice13" in
    [yY]* ) break;;
    [nN]* )
        echo "Error: set gtestALC=0"
        echo "No system files were changed"
        echo "To save a Copy of this Terminal session: Terminal/Shell/Export Text As ..."
        exit 1
        ;;
    * ) echo "Try again...";;
    esac
done

gDownloadLink="https://raw.githubusercontent.com/toleda/audio_alc_test/master/$gCodec.zip"
sudo curl -o "/tmp/ALC$gCodec.zip" $gDownloadLink
unzip -qu "/tmp/ALC$gCodec.zip" -d "/tmp/"
gDownloadLink="https://raw.githubusercontent.com/toleda/audio_alc_test/master/realtekALC.kext.zip"
sudo curl -o "/tmp/realtekALC.kext.zip" $gDownloadLink
unzip -qu "/tmp/realtekALC.kext.zip" -d "/tmp/"

fi

# exit if error
if [ "$?" != "0" ]; then
    echo "Error: Download failure, verify network"
    echo "No system files were changed"
    echo "To save a Copy of this Terminal session: Terminal/Shell/Export Text As ..."
    exit 1
fi
fi

# debug
if [ $gDebug = 2 ]; then
    echo "gCloverALC = $gCloverALC"
    echo "gPikerAlphaALC = $gPikerAlphaALC"
    echo "gRealtekALC = $gRealtekALC"
fi

######################

if [ $gCloverALC = 1 ]; then    # main loop

######################

# if no clover audio id injection, exit
configaudio=$(sudo /usr/libexec/PlistBuddy -c "Print ':Devices'" /tmp/config.plist | grep -c "Audio")
if [ $gAudioid != 0 ]; then
# set Devices/Audio/Inject/gLayout-id
    echo "Edit config.plist/Devices/Audio/Inject/$gAudioid"
    if [ $configaudio = 0 ]; then
        sudo /usr/libexec/PlistBuddy -c "Add :Devices:Audio dict" /tmp/config.plist
        sudo /usr/libexec/PlistBuddy -c "Add :Devices:Audio:Inject string '$gAudioid'" /tmp/config.plist
    else
        sudo /usr/libexec/PlistBuddy -c "Set :Devices:Audio:Inject $gAudioid" /tmp/config.plist
    fi
fi
# check for Devices/Audio/#Inject
configaudio=$(sudo /usr/libexec/PlistBuddy -c "Print ':Devices'" /tmp/config.plist | grep -c "#Inject")
if [ $configaudio != 0 ]; then
sudo /usr/libexec/PlistBuddy -c "Add :Devices:Audio:Inject string '$gAudioid'" /tmp/config.plist
fi

# debug
if [ $gDebug = 2 ]; then
    echo "gAudioid = $gAudioid"
    echo "configaudio = $configaudio"
fi

if [ $gPikerAlphaALC = 0 ]; then
echo "Edit config.plist/SystemParameters/InjectKexts/YES"

injectkexts=$(sudo /usr/libexec/PlistBuddy -c "Print ':SystemParameters:InjectKexts:'" /tmp/config.plist)

# debug
if [ $gDebug = 2 ]; then
    echo "SystemParameters:InjectKexts: = $injectkexts"
fi

if [ -z "${injectkexts}" ]; then
    sudo /usr/libexec/PlistBuddy -c "Add :SystemParameters:InjectKexts string" /tmp/config.plist
    echo "Edit config.plist: Add SystemParameters/InjectKexts - Fixed"
fi

if [ $(sudo /usr/libexec/PlistBuddy -c "Print ':SystemParameters:InjectKexts'" /tmp/config.plist | grep -c "YES") = 0 ]; then
    sudo /usr/libexec/PlistBuddy -c "Set :SystemParameters:InjectKexts YES" /tmp/config.plist
fi

# debug 
if [ $gDebug = 2 ]; then
    echo "After edit. :SystemParameters:InjectKexts; = $(sudo /usr/libexec/PlistBuddy -c "Print ':SystemParameters:InjectKexts:'" /tmp/config.plist)"
fi

# exit if error
if [ "$?" != "0" ]; then
    echo Error: config.plst edit failed
    echo “Original config.plist restored”
    sudo cp -X $gCloverDirectory/config-backup.plist $gCloverDirectory/config.plist
    sudo rm -R /tmp/ktp.plist
    sudo rm -R /tmp/config.plist
    sudo rm -R /tmp/config-audio_cloverALC.plist
    sudo rm -R /tmp/$gCodec.zip
    sudo rm -R /tmp/$gCodec
    echo "To save a Copy of this Terminal session: Terminal/Shell/Export Text As ..."
    exit 1
fi

fi

echo "Download kext patches"

gDownloadLink="https://raw.githubusercontent.com/toleda/audio_cloverALC/master/config-audio_cloverALC.plist.zip"
sudo curl -o "/tmp/config-audio_cloverALC.plist.zip" $gDownloadLink
unzip -qu "/tmp/config-audio_cloverALC.plist.zip" -d "/tmp/"

# add KernelAndKextPatches/KextsToPatch codec patches
# remove existing audio patches

ktpexisting=$(sudo /usr/libexec/PlistBuddy -c "Print ':KernelAndKextPatches:KextsToPatch:'" /tmp/config.plist)

if [ -z "${ktpexisting}" ]; then
    sudo /usr/libexec/PlistBuddy -c "Add KernelAndKextPatches:KextsToPatch array" /tmp/config.plist
    echo "Edit config.plist: Add KernelAndKextPatches/KextsToPatch - Fixed"
fi

ktpexisting=$(sudo /usr/libexec/PlistBuddy -c "Print ':KernelAndKextPatches:KextsToPatch:'" /tmp/config.plist | grep -c "t1-")

if [ $ktpexisting = 0 ]; then
    if [ $(sudo /usr/libexec/PlistBuddy -c "Print ':KernelAndKextPatches:KextsToPatch:$index dict'" /tmp/config.plist | grep -c "AppleHDA") != 0 ]; then
        gMB=1
    fi
fi

# remove t1 patches (cloverALC)
# index=0
# while [ $ktpexisting -ge 1 ]; do
# if [ $(sudo /usr/libexec/PlistBuddy -c "Print ':KernelAndKextPatches:KextsToPatch:$index dict'" /tmp/config.plist | grep -c "t1-") = 1 ]; then
#     sudo /usr/libexec/PlistBuddy -c "Delete ':KernelAndKextPatches:KextsToPatch:$index dict'" /tmp/config.plist
#     ktpexisting=$(sudo /usr/libexec/PlistBuddy -c "Print ':KernelAndKextPatches:KextsToPatch:'" /tmp/config.plist | grep -c "t1-")
#     index=$((index - 1))
# fi
# index=$((index + 1))
# debug
# if [ $gDebug = 2 ]; then
#     echo "t1 patches"
#     echo "index = $index"
#     echo "ktpexisting = $ktpexisting"
# fi
# done

# remove AppleHDAController patches (mb)
ktpexisting=$(sudo /usr/libexec/PlistBuddy -c "Print ':KernelAndKextPatches:KextsToPatch:'" /tmp/config.plist | grep -c "AppleHDAController")

index=0
while [ $ktpexisting -ge 1 ]; do
if [ $(sudo /usr/libexec/PlistBuddy -c "Print ':KernelAndKextPatches:KextsToPatch:$index dict'" /tmp/config.plist | grep -c "AppleHDAController") = 1 ]; then
    if [ $(sudo /usr/libexec/PlistBuddy -c "Print ':KernelAndKextPatches:KextsToPatch:$index dict'" /tmp/config.plist | grep -c "x99") = 0 ]; then
            sudo /usr/libexec/PlistBuddy -c "Delete ':KernelAndKextPatches:KextsToPatch:$index dict'" /tmp/config.plist
    fi
    ktpexisting=$(sudo /usr/libexec/PlistBuddy -c "Print ':KernelAndKextPatches:KextsToPatch:'" /tmp/config.plist | grep -c "AppleHDAController")
    index=$((index - 1))
fi
index=$((index + 1))
# debug
if [ $gDebug = 2 ]; then
    echo "AppleHDAController patches (mb)"
    echo "index = $index"
    echo "ktpexisting = $ktpexisting"
fi
done

# remove AppleHDA patches (mb)
ktpexisting=$(sudo /usr/libexec/PlistBuddy -c "Print ':KernelAndKextPatches:KextsToPatch:'" /tmp/config.plist | grep -c "AppleHDA")

index=0
while [ $ktpexisting -ge 1 ]; do
if [ $(sudo /usr/libexec/PlistBuddy -c "Print ':KernelAndKextPatches:KextsToPatch:$index dict'" /tmp/config.plist | grep -c "AppleHDA") != 0 ]; then
    if [ $(sudo /usr/libexec/PlistBuddy -c "Print ':KernelAndKextPatches:KextsToPatch:$index dict'" /tmp/config.plist | grep -c "x99") = 0 ]; then
            sudo /usr/libexec/PlistBuddy -c "Delete ':KernelAndKextPatches:KextsToPatch:$index dict'" /tmp/config.plist
    fi
    ktpexisting=$(sudo /usr/libexec/PlistBuddy -c "Print ':KernelAndKextPatches:KextsToPatch:'" /tmp/config.plist | grep -c "AppleHDA")
    index=$((index - 1))
fi
# gMB=1
index=$((index + 1))
# debug
if [ $gDebug = 2 ]; then
    echo "AppleHDA patches (mb)"
    echo "index = $index"
    echo "ktpexisting = $ktpexisting"
fi
done

# remove AppleHDA patches (any remaining)
# ktpexisting=$(sudo /usr/libexec/PlistBuddy -c "Print ':KernelAndKextPatches:KextsToPatch:'" /tmp/config.plist | grep -c "AppleHDA")

# index=0
# while [ $ktpexisting -ge 1 ]; do
# if [ $(sudo /usr/libexec/PlistBuddy -c "Print ':KernelAndKextPatches:KextsToPatch:$index dict'" /tmp/config.plist | grep -c "AppleHDA") = 1 ]; then
#         if [ $(sudo /usr/libexec/PlistBuddy -c "Print ':KernelAndKextPatches:KextsToPatch:$index dict'" /tmp/config.plist | grep -c "x99") = 0 ]; then
#         sudo /usr/libexec/PlistBuddy -c "Delete ':KernelAndKextPatches:KextsToPatch:$index dict'" /tmp/config.plist
#     fi
#     ktpexisting=$(sudo /usr/libexec/PlistBuddy -c "Print ':KernelAndKextPatches:KextsToPatch:'" /tmp/config.plist | grep -c "AppleHDA")
#     index=$((index - 1))
# fi
# gMB=1
# index=$((index + 1))

# debug
# if [ $gDebug = 2 ]; then
#     echo "AppleHDA patches (any remaining)"
#     echo "index = $index"
#     echo "ktpexisting = $ktpexisting"
# fi
# done

# set patch for codec

case $gCodec in
# xml>znl, patch1=0
885 ) patch1=1;;
887 ) patch1=2;;
888 ) patch1=3;;
889 ) patch1=4;;
892 ) patch1=5;;
898 ) patch1=6;;
1150 ) patch1=7;;
269 ) patch1=8;;
283) patch1=9;;
# sierra only, patch1=13
# el capitan only, patch1=10
# hd4600 hdmi audio only, patch1=11
# hd4600 hdmi audio only, patch1=12
esac

patch=( 0 $patch1 )
index=0

if [ $gPikerAlphaALC = 1 ]; then
    index=1
fi

while [ $index -lt 2 ]; do

sudo /usr/libexec/PlistBuddy -c "Print ':KernelAndKextPatches:KextsToPatch:${patch[$index]}'" /tmp/config-audio_cloverALC.plist -x > "/tmp/ktp.plist"
ktpcomment=$(sudo /usr/libexec/PlistBuddy -c "Print 'Comment'" "/tmp/ktp.plist")
sudo /usr/libexec/PlistBuddy -c "Set :Comment 't1-$ktpcomment'" "/tmp/ktp.plist"
sudo /usr/libexec/PlistBuddy -c "Add :KernelAndKextPatches:KextsToPatch:0 dict" /tmp/config.plist
sudo /usr/libexec/PlistBuddy -c "Merge /tmp/ktp.plist ':KernelAndKextPatches:KextsToPatch:0'" /tmp/config.plist

index=$((index + 1))
done

case $gSysName in

"Sierra"|"El Capitan" )

case $gCodec in

887|888|889|892|898|1150 )

case $gSysName in

"Sierra" )
# codec patch out/credit pcpaul/Riley Freeman
sudo /usr/libexec/PlistBuddy -c "Print ':KernelAndKextPatches:KextsToPatch:13}'" /tmp/config-audio_cloverALC.plist -x > "/tmp/ktp.plist"
;;

"El Capitan" )
# codec patch out/credit lisai9093
sudo /usr/libexec/PlistBuddy -c "Print ':KernelAndKextPatches:KextsToPatch:10}'" /tmp/config-audio_cloverALC.plist -x > "/tmp/ktp.plist"
;;

esac

esac

ktpcomment=$(sudo /usr/libexec/PlistBuddy -c "Print 'Comment'" "/tmp/ktp.plist")
sudo /usr/libexec/PlistBuddy -c "Set :Comment 't1-$ktpcomment'" "/tmp/ktp.plist"
sudo /usr/libexec/PlistBuddy -c "Add :KernelAndKextPatches:KextsToPatch:0 dict" /tmp/config.plist
sudo /usr/libexec/PlistBuddy -c "Merge /tmp/ktp.plist ':KernelAndKextPatches:KextsToPatch:0'" /tmp/config.plist
;;

esac

# codec patch hd4600 hdmi audio/credit TimeWalker75a
if [ $choice2 = y ]; then
    index=11

    while [ $index -lt 13 ]; do

sudo /usr/libexec/PlistBuddy -c "Print ':KernelAndKextPatches:KextsToPatch:$index}'" /tmp/config-audio_cloverALC.plist -x > "/tmp/ktp.plist"
ktpcomment=$(sudo /usr/libexec/PlistBuddy -c "Print 'Comment'" "/tmp/ktp.plist")
sudo /usr/libexec/PlistBuddy -c "Set :Comment 't1-$ktpcomment'" "/tmp/ktp.plist"
sudo /usr/libexec/PlistBuddy -c "Add :KernelAndKextPatches:KextsToPatch:0 dict" /tmp/config.plist
sudo /usr/libexec/PlistBuddy -c "Merge /tmp/ktp.plist ':KernelAndKextPatches:KextsToPatch:0'" /tmp/config.plist

    index=$((index + 1))
    done

fi

# exit if error
if [ "$?" != "0" ]; then
    echo Error: config.plst edit failed
    echo “Original config.plist restored”
    sudo cp -X $gCloverDirectory/config-backup.plist $gCloverDirectory/config.plist
    sudo rm -R /tmp/ktp.plist
    sudo rm -R /tmp/config.plist
    sudo rm -R /tmp/config-audio_cloverALC.plist
    sudo rm -R /tmp/$gCodec.zip
    sudo rm -R /tmp/$gCodec
    echo "To save a Copy of this Terminal session: Terminal/Shell/Export Text As ..."
    exit 1
fi

# install updated config.plst
case $gDebug in

0 )
    sudo cp -R "/tmp/config.plist" "$gCloverDirectory/config.plist"
    ;;

1|2 )
    sudo cp -R /tmp/config.plist /tmp/$gCodec
    echo "/tmp/config.plist copied to /tmp/$gCodec"
    ;;

esac

# cleanup /tmp
sudo rm -R /tmp/ktp.plist
sudo rm -R /tmp/config.plist
sudo rm -R /tmp/config-audio_cloverALC.plist
sudo rm -R /tmp/config-audio_cloverALC.plist.zip

# echo "config.plist patching finished."

if [ $gPikerAlphaALC = 1 ]; then

# download AppleHDA8Series.sh to /tmp/
echo "Download Piker-Alpha/AppleHDA8Series.sh"

curl -o /tmp/AppleHDA8Series.zip https://codeload.github.com/Piker-Alpha/AppleHDA8Series.sh/zip/master
if [ -d /tmp/AppleHDA8Series ]; then
    sudo rm -R /tmp/AppleHDA8Series
fi
unzip -qu /tmp/AppleHDA8Series.zip -d /tmp/
mv /tmp/AppleHDA8Series.sh-master /tmp/AppleHDA8Series

# remove installed AppleHDAxxx.kext
if [ -d "$gLibraryDirectory/AppleHDA$gCodec.kext" ]; then
    sudo rm -R "$gLibraryDirectory/AppleHDA$gCodec.kext"
fi

# run AppleHDA8Series.sh
echo "Install $gLibraryDirectory/AppleHDA$gCodec.kext"
chmod +x /tmp/AppleHDA8Series/AppleHDA8Series.sh
sh /tmp/AppleHDA8Series/AppleHDA8Series.sh -a $gCodec -l $gAudioid -d $gLibraryDirectory

# exit if error
if [ "$?" != "0" ]; then
    echo Error: AppleHDA8Series.sh
    echo "No system files were changed"
    echo "To save a Copy of this Terminal session: Terminal/Shell/Export Text As ..."
    sudo rm -R /tmp/AppleHDA8Series.zip
    sudo rm -R /tmp/AppleHDA8Series
    sudo rm -R /tmp/ALC$gCodec.zip
    sudo rm -R /tmp/$gCodec
    sudo rm -R /tmp/ConfigData-ALC$gCodec.xml
    sudo rm -R /tmp/HDEF.txt
    exit 1
fi

# clean up
sudo rm -R /tmp/AppleHDA8Series.zip
sudo rm -R /tmp/AppleHDA8Series
sudo rm -R /tmp/ALC$gCodec.zip
sudo rm -R /tmp/$gCodec
sudo rm -R /tmp/ConfigData-ALC$gCodec.xml
sudo rm -R /tmp/HDEF.txt

else        # PikerAlphaALC
# determine kexts/folder
if [ -d "$gCloverDirectory/$gSysFolder" ]; then
    gSysFolder=$gSysFolder
    else
    gSysFolder=kexts/Other
fi

if [ $gtestALC = 0 ]; then
    echo "Download config kext and install ..."
    gDownloadLink="https://raw.githubusercontent.com/toleda/audio_cloverALC/master/realtekALC.kext.zip"
    sudo curl -o "/tmp/realtekALC.kext.zip" $gDownloadLink
    unzip -qu "/tmp/realtekALC.kext.zip" -d "/tmp/"
fi

# install realtekALC.kext

case $gDebug in

0 )

case $gMB in

   0 )
# to EFI/CLOVER/kexts/ (cloverALC)

    if [ -d "$gCloverDirectory/$gSysFolder/realtekALC.kext" ]; then
    sudo rm -R "$gCloverDirectory/$gSysFolder/realtekALC.kext"
    # echo "$gCloverDirectory/$gSysFolder/realtekALC.kext deleted"
    fi

    sudo cp -R "/tmp/realtekALC.kext" "$gCloverDirectory/$gSysFolder/"
    echo "Install $gCloverDirectory/$gSysFolder/realtekALC.kext"
    if [ -d "$gLibraryDirectory/realtekALC.kext" ]; then
    	sudo rm -R "$gLibraryDirectory/realtekALC.kext"
    fi
    ;;

   1 )
# to Library/Extensions/ (mb)

    if [ -d "$gLibraryDirectory/realtekALC.kext" ]; then
    sudo rm -R "$gLibraryDirectory/realtekALC.kext"
	else
	gMB=0
    # echo "$gLibraryDirectory/realtekALC.kext deleted"
    fi

    sudo cp -R "/tmp/realtekALC.kext" "/tmp/$gCodec"
    echo "Install $gLibraryDirectory/realtekALC.kext"
    ;;

    esac

    ;;

1|2 )
    sudo cp -R /tmp/realtekALC.kext /tmp/$gCodec
    echo "/tmp/realtekALC.kext copied to /tmp/$gCodec"
    ;;

esac

sudo rm -R /tmp/realtekALC.kext.zip
sudo rm -R /tmp/realtekALC.kext
sudo rm -R /tmp/__MACOSX

# exit if error
if [ "$?" != "0" ]; then
    echo Error: Download failure
    echo "No system files were changed"
    echo "To save a Copy of this Terminal session: Terminal/Shell/Export Text As ..."
    exit 1
fi

# set install folder
case $gDebug in

0 )

# install codec specific files
    if [ -d "$gHDAContentsDirectory/Resources/*.zml.zlib" ]; then
    sudo rm -R "$gHDAContentsDirectory/Resources/*.zml.zlib"
# echo "System/Library/Extensions/AppleHDA.kext/ALC$gCodec zml files deleted"
    fi

    echo "Install System/Library/Extensions/AppleHDA.kext/ALC$gCodec zml files"
    sudo install -m 644 -o root -g wheel /tmp/$gCodec/Platforms.xml.zlib  $gHDAContentsDirectory/Resources/Platforms.zml.zlib
    sudo install -m 644 -o root -g wheel /tmp/$gCodec/layout1.xml.zlib  $gHDAContentsDirectory/Resources/layout1.zml.zlib

    case $gCodec in

    887|888|889|892|898|1150 )
    sudo install -m 644 -o root -g wheel /tmp/$gCodec/layout2.xml.zlib  $gHDAContentsDirectory/Resources/layout2.zml.zlib
    sudo install -m 644 -o root -g wheel /tmp/$gCodec/layout3.xml.zlib  $gHDAContentsDirectory/Resources/layout3.zml.zlib
    ;;
#   1150 )
#   sudo install -m 644 -o root -g wheel /tmp/$gCodec/layout2.xml.zlib  $gHDAContentsDirectory/Resources/layout2.zml.zlib
#   ;;
    esac
    ;;

1|2 )
    if [ -d $gDesktopDirectory$gCodec-${gDebugMode[$gDebug]} ]; then
        sudo rm -R $gDesktopDirectory$gCodec-${gDebugMode[$gDebug]}
    fi
    sudo cp -R /tmp/$gCodec $gDesktopDirectory$gCodec-${gDebugMode[$gDebug]}
    sudo rm -R "$gDesktopDirectory$gCodec-${gDebugMode[$gDebug]}"/Info-*.plist
    echo "$gCodec-${gDebugMode[$gDebug]} copied to Desktop"
    echo "No system files were changed"
    ;;

esac

# remove temp files
sudo rm -R /tmp/ALC$gCodec.zip
sudo rm -R /tmp/$gCodec

# exit if error
if [ "$?" != "0" ]; then
    echo "Error: Installation failure"
    sudo rm -R "$gHDAContentsDirectory/Resources/*zml.zlib"
    sudo touch $gExtensionsDirectory
    echo "Original S/L/E/AppleHDA.kext restored"
    echo "To save a Copy of this Terminal session: Terminal/Shell/Export Text As ..."
    exit 1
fi

fi    # end: PikerAlphaALC

fi    # end: if [ $gCloverALC = 1 ]

# fix permissions and rebuild cache

if [ $gDebug = 0 ]; then
case $gSysName in

"Sierra"|"El Capitan"|"Yosemite" )
echo "Fix permissions ..."
sudo chown -R root:wheel $gExtensionsDirectory/AppleHDA.kext
echo "Kernel cache..."
sudo touch $gExtensionsDirectory
sudo kextcache -Boot -U /
;;

"Mavericks"|"Mountain Lion" )
echo "Fix permissions ..."
sudo chown -R root:wheel $gExtensionsDirectory/AppleHDA.kext
echo "Kernel cache..."
sudo touch $gExtensionsDirectory
echo "Allow a few minutes for kernel cache rebuild."
;;

esac
fi

# exit if error
# if [ "$?" != "0" ]; then
# echo Error: Maintenance failure
# echo "Verify Permissions"
# echo "Rebuild Kernel Cache"
# echo "Verify S/L/E/AppleHDA.kext"
# echo "To save a Copy of this Terminal session: Terminal/Shell/Export Text As ..."
# exit 1
# fi

echo ""
case $gDebug in

0 )
    echo "Install finished, restart required."
    ;;

1|2 )
    echo "Install finished, see Desktop/$gCodec-${gDebugMode[$gDebug]}"
    ;;

esac

echo "To save a Copy of this Terminal session: Terminal/Shell/Export Text As ..."
exit 0