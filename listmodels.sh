source="."
dest="./addons/sourcemod/configs/nmrih_skins"

#not working? wtf
# FileExistADLs() {
# find -wholename "pets_additionalDLs.cfg" | grep .
# if [ $? != 0 ];then
#     echo ">No additional downloads config, creating.."
#     touch "pets_additionalDLs.cfg"
# else   
#     echo "additionalDLs config exists, continuing.."
# fi
# }

exclude_array=( cat pika ) #define skins_menu exclusions here ( "exclude1" "exclude2" )

#Check if a given filename exists, make backup if yes.
FileExistBU() {
    find -wholename "$1/$2" | grep -q .   #note to self: $1 refers to first parameter passed to func, $0 refers to the function itself
    if [ $? == 0 ];then
        echo ">$2 already exists, backing up"
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
    echo ">$2 does not exist, continueing"
    fi
}

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
    mkdir -p "$dest"
    echo "$1 directory does not exist, creating.."
	return 1
else   
    echo "$1 directory exists, continuing.."
	return 0
fi
}

# FileExistADLs
additionaldownloads=`grep \. pets_additionalDLs.cfg`

DirExistExit "$source/models"
DirExistMK "$dest"

if [ $? == 0 ];then
FileExistBU	"$dest" "downloads_list.ini"
FileExistBU "$dest" "skins_menu.ini"
fi

#scan model files
find ./models -type f | cut -c3- >> "$dest/downloads_list.ini"
find ./materials -type f | cut -c3- >> "$dest/downloads_list.ini"
echo -e "----------------------------------------"
echo "adding extra additional defined downloads"
echo -e "$additionaldownloads" >> "$dest/downloads_list.ini"

echo -e ">Finished scanning for model files\n----------------------------------------\n\n----------------------------------------"

#now to create a skins_menu.ini configuration

echo -e "\"Models\"\n{\n	\"Public Models\"\n	{\n		\"Public\" \"\"\n		\"List\"\n		{" >> "$dest/skins_menu.ini"
#get lines with .mdl extension
#for every line:
#cut line from instance of /, repeated until no / found
#cut remaining string up to .mdl
#print model name, and model path in correct formatting
for i in `grep .mdl "$dest/downloads_list.ini"`;do
    #check exclusions 
    for substr in "${exclude_array[@]}";do
        if [[ "$i" == *$substr* ]];then
            echo "found exclusion keyword $substr, lol!"
            continue 2
    fi
    done

        temp=$i
        n=0
        while (($n<=6))
            do
                temp="`cut -d "/" -f2- <<< "$temp"`"
                ((n+=1))
                #echo "itiration n${n}"
        done
        echo ">done removing /'s: ${temp}"
        temp="`cut -d "." -f1 <<< "$temp"`"
        echo ">done removing .mdl: ${temp}"
        echo "          \"${temp}\""            >> "$dest/skins_menu.ini"
        echo "          {"                      >> "$dest/skins_menu.ini"
        echo "              \"path\" \"${i}\""  >> "$dest/skins_menu.ini"
        echo "          }"                      >> "$dest/skins_menu.ini"
        (( num+=1 ))
 
done

echo "Found $num models"

echo -e "		}
	}

	\"Default Models\"
	{
		\"Public\" \"\"
		\"List\"
		{
			\"Badass\"
			{
				\"path\" \"models/player/p_badass.mdl\"
			}
			\"Bateman\"
			{
				\"path\" \"models/player/p_bateman.mdl\"
			}
			\"Butcher\"
			{
				\"path\" \"models/player/p_butcher.mdl\"
			}
			\"Hunter\"
			{
				\"path\" \"models/player/p_hunter.mdl\"
			}
			\"Jive\"
			{
				\"path\" \"models/player/p_jive.mdl\"
			}
			\"Molotov\"
			{
				\"path\" \"models/player/p_molotov.mdl\"
			}
			\"Roje\"
			{
				\"path\" \"models/player/p_roje.mdl\"
			}
			\"Wally\"
			{
				\"path\" \"models/player/p_wally.mdl\"
			}
		}
	}
}
" >> "$dest/skins_menu.ini"

echo -e "----------------------------------------"
echo ">extracted all custom model (file)names and formatted .ini"

find -wholename "$dest/skins_menu.ini" | grep -q .
if [ $? != 0 ];then
    echo ">Something went wrong writing mapcycle, please try in administrator/su mode"
	fi
echo "done!"