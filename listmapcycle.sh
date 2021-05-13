#!/bin/bash
source="."
dest="./cfg"

DirExistExit() {
find -type d -wholename "$1" | grep -q .
if [ $? != 0 ];then
    echo ">$1 directory does not exist, Are you sure you are executing within NMRiH directory?"
    read -p ">Press any button to continue and stuff" x
    echo ">Exiting.."
    exit
else   
    echo "$1 directory exists, continuing.."
fi
}

DirExistMK() {
find -type d -wholename "$1" | grep -q .
if [ $? != 0 ];then
    mkdir "$1"
    echo "$1 directory does not exist, creating.."
else   
    echo "$1 directory exists, continuing.."
fi
}

echo -e "----------------------------------------"
FileExistBU() {
    find -wholename "$1/$2" | grep -q .   #note to self: $1 refers to first parameter passed to func, $0 refers to the function itself
    if [ $? == 0 ];then
        echo ">$2 already exists, backing up.."
        #cut filename at '.', insert -old
        substrf1="`cut -d "." -f1 <<< "$2"`"
        substrf2="`cut -d "." -f2 <<< "$2"`"
        temp="$substrf1-old.$substrf2"
        mv "$1/$2" "$1/$temp"
        find -wholename "$1/$temp" | grep -q .
        if [ $? == 0 ];then
            echo ">Made backup $1/$temp"
        else
            echo ">Something went wrong making backup of $2, please try in administrator/su mode"
            exit
        fi
    else
    echo ">$2 does not exist, continuing.."
    fi
}

DirExistExit "$source/maps"
DirExistMK "$dest"
FileExistBU	"$dest" "mapcycle.txt"

find maps -name "*.bsp" | cut -c6- | cut -d '.' -f1 >> "$dest/mapcycle.txt"
find -wholename "$dest/mapcycle.txt" | grep -q .
if [ $? != 0 ];then
    echo ">Something went wrong writing mapcycle, please try in administrator/su mode"
else
    find maps -name "*.bsp" | echo "Found $(wc -l) maps."
    echo -e "----------------------------------------\n>Finished!"
fi