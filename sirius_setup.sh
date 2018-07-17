#!/bin/bash -E
version="1.0"
SKIP_DOWNLOAD=false
columns=$(tput cols)
let "right=columns -1"
#GREEN=$(tput setaf 2)
#NORMAL=$(tput sgr0)


clear
function get_version(){
	 echo -e "\x1b[31m Sirius_Setup : $version \x1b[0m "
	 exit
}
function help(){
	 
	 echo -e "\x1b[31m
./sirius_setup.sh [OPTIONS] or bash <(curl -s  https://siriuspool.net/sirius_setup-v1.0.sh) [OPTIONS]

	-h 	, -help 			: Show this help
	-v 	, --version 		: Print scripts version and exit
	-s 	, --skip-download	: Skip Download tar consensus (do it if you already have an instance of the chain local)


	   \x1b[0m "
	   exit
}

for i in "$@"
do
case $i in
    -s*|--skip-download*)
    SKIP_DOWNLOAD=true #"${i#*=}"
    shift # past argument=value
    ;;
    -v|--version )
    get_version
        shift # past argument with no value
    ;;
    -h|--help )
    help
        shift # past argument with no value
    ;;
    *)
          # unknown option
    ;;
esac
done

if [[ -n $1 ]]; then
	echo "Usage :"
	help
    tail -1 $1
fi

if [ "$EUID" -ne 0 ]
  then echo "This script must run  as root"
	echo "If you need help visit https://discord.gg/9GB8Fzc  to step in and guide you!"
  exit
fi
echo -e "\e[34m"
wget -q https://siriuspool.net/sirius_logo.txt -O .logo ;  cat .logo & sleep 2 &
PID=$!
i=1
sp="/-\|"
printf '%s%*s%s' "$GREEN0" $right
#echo -n ' '
 while [ -d /proc/$PID ]
do
# printf "\b${sp:i++%${#sp}:1}"
  printf     "\b ${sp:i++%${#sp}:1}"
# printf '%s%*s%s' "$GREEN" $right "[OK]" "$NORMAL"
done
printf  "$NORMAL"
 cat .logo
rm .logo

clear
echo "------------------ Miner Settings ------------------"
read -e -p "Select Threads: " -i $(getconf _NPROCESSORS_ONLN) threads
read -e -p "Enter your Wallet (NQ00 XX..): " address
read   -e -p  "Set a Unique Device Name (optional): " miner_name
read  -e -p "Stats Interval (seconds): "  -i "30" stats

echo  "#!/bin/bash
UV_THREADPOOL_SIZE=128
threads=$threads
address='"$address"'
miner_name='$miner_name'
stats=$stats
" > init 
printf './worker --protocol="dumb" --pool=siriuspool.net:3000  --miner=$threads --wallet-address="$address" --statistics=$stats --extra-data="$miner_name"
' >> ./init
chmod +x init 
printf '#!/bin/bash
SCRIPT_PATH=$(dirname "$0")/sirius_core
$SCRIPT_PATH/clients/nodejs/nimiq "$@"' > worker
chmod +x ./worker

clear
apt update && apt upgrade -y
apt install git  build-essential curl 
if ! [ -x "$(command -v nodejs)" ]; then
echo "Installing Nodejs v9.x"
bash <(curl -s https://deb.nodesource.com/setup_9.x  )
  apt-get install -y nodejs
fi
clear
npm install -g yarn
#rm -r core
yarn add global gulp
clear
git clone https://github.com/nimiq-network/core sirius_core
cd sirius_core
clear
npm install --unsafe-perm
yarn && yarn build
cd ..
clear
if [ "$SKIP_DOWNLOAD" !== "true" ] ;then
echo " Downloading The Main-Full-Consensus"
wget -q https://raw.githubusercontent.com/circulosmeos/gdown.pl/master/gdown.pl
chmod +x ./gdown.pl
./gdown.pl  https://drive.google.com/file/d/1ZhC4F_px6Vf4MQsIr-Bp68LWHXHJ-B_5/main-full-consensus.tar consensus.tar
echo "Extracting Data"  					
tar xf consensus.tar
rm consensus.tar  ./gdown.pl
printf "done!!\n"
fi
echo "All Done.To Start Mining  Enter : ./init"
printf "\n"

#  bash <(curl -s  https://siriuspool.net/sirius_setup.sh)
