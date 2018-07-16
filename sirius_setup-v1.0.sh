#!/bin/bash -E
clear
if [ "$EUID" -ne 0 ]
  then echo "This script must run  as root"
	echo "If you need help visit https://discord.gg/9GB8Fzc  to step in to guide you!"
  exit
fi
wget -q https://siriuspool.net/sirius_logo.txt -O .logo
cat .logo ; rm .logo
printf '#!/bin/bash
SCRIPT_PATH=$(dirname "$0")/sirius_core
$SCRIPT_PATH/clients/nodejs/nimiq "$@"' > worker
chmod +x ./worker
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

apt update && apt upgrade -y
apt install git  build-essential curl 
if ! [ -x "$(command -v nodejs)" ]; then
echo "Installing Nodejs v10.x"
bash <(curl -s https://deb.nodesource.com/setup_10.x  )
  apt-get install -y nodejs
fi
npm install -g yarn
#rm -r core
yarn add global gulp
git clone https://github.com/nimiq-network/core sirius_core
cd sirius_core
npm install --unsafe-perm
yarn && yarn build
cd ..

echo " Downloading The Main-Full-Consensus"
wget -q https://raw.githubusercontent.com/circulosmeos/gdown.pl/master/gdown.pl
chmod +x ./gdown.pl
./gdown.pl  https://drive.google.com/file/d/1ZhC4F_px6Vf4MQsIr-Bp68LWHXHJ-B_5/main-full-consensus.tar consensus.tar
echo "Extracting Data"  					
tar xf consensus.tar
rm consensus.tar  ./gdown.pl
printf "done!!\n"
echo "All Done.To Start Mining  Enter : ./init"
printf "\n"

#  bash <(curl -s  https://siriuspool.net/sirius_setup-v1.0.sh)