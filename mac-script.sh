#!/bin/bash

BP="%BuildParams%"
BP_ARR=$(echo $BP | sed -e 's/,/ /g')

if [ -d RESULT ]; then
    rm -rf RESULT/*
else
    mkdir RESULT
fi

if [ "%DEV%" == "--dev" ]; then
    DEV="%DEV%"
else
    DEV=""
fi

if [ "%Autotests%" == "--autotest" ]; then
    AUTOTESTS="%Autotests%"
        else
    AUTOTESTS=""
fi

for i in ${BP_ARR[@]}
    do
        case $i in
            Amazon )
                cp Src/CaesarsSlots/CaesarsSlots.Android/Properties/AndroidManifest_Amazon.xml Src/CaesarsSlots/CaesarsSlots.Android/Properties/AndroidManifest.xml
            ;;
            1136x640Tablet )
                cp Src/CaesarsSlots/CaesarsSlots.Android/Properties/AndroidManifest_Tablet.xml Src/CaesarsSlots/CaesarsSlots.Android/Properties/AndroidManifest.xml
            ;;
            1136x640 )
                cp Src/CaesarsSlots/CaesarsSlots.Android/Properties/AndroidManifest_Large.xml Src/CaesarsSlots/CaesarsSlots.Android/Properties/AndroidManifest.xml
            ;;
            854x480 )
                cp Src/CaesarsSlots/CaesarsSlots.Android/Properties/AndroidManifest_Medium.xml Src/CaesarsSlots/CaesarsSlots.Android/Properties/AndroidManifest.xml
            ;;
            480x320 )
                cp Src/CaesarsSlots/CaesarsSlots.Android/Properties/AndroidManifest_Small.xml Src/CaesarsSlots/CaesarsSlots.Android/Properties/AndroidManifest.xml
            ;;
        esac

        if [ $i == "Amazon" ]; then
            python CopyAssets.py -r 1136x640
            echo "Build number=%build.number%" > Assets/version.ini
            cd Src
            ./premake4 --target=Android $DEV $Autotests --config=Release xamarin
        elif [ $i == "1136x640Tablet" ]; then
            python CopyAssets.py -r "1136x640"
            echo "Build number=%build.number%" > Assets/version.ini
            cd Src
            ./premake4 --target=Android $DEV $Autotests --config=Release xamarin
        else
            python CopyAssets.py -r $i
            echo "Build number=%build.number%" > Assets/version.ini
            cd Src
            ./premake4 --target=Android $DEV $Autotests --config=Release xamarin
        fi
        cd ..
        xbuild "CaesarsSlots\CaesarsSlots.Android\CaesarsSlots.Android.Android.csproj" /p:Configuration=Release /t:Clean
        xbuild "Src/CaesarsSlots/CaesarsSlots.Android/CaesarsSlots.Android.Android.csproj" /p:Configuration=Release /t:SignAndroidPackage

        mv Bin/Android/*-Signed.apk RESULT/com.playtika.caesarscasino-${i}Signed.apk
    done
