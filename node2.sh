#!/bin/bash
_interupt() {
    echo "Shutdown $child_proc"
    kill -TERM $child_proc
    exit
}

trap _interupt INT TERM

touch .pwd
export $(cat .env | xargs)
Bin_NAME=XDC

WORK_DIR=$PWD
PROJECT_DIR="/home/ubuntu/XDPoSChain"
cd $PROJECT_DIR && make XDC
cd $WORK_DIR

if [ ! -d ./nodes/1/$Bin_NAME/chaindata ]
then
  wallet1=$(${PROJECT_DIR}/build/bin/$Bin_NAME account import --password .pwd --datadir ./nodes/1 <(echo ${PRIVATE_KEY_1}) | awk -v FS="({|})" '{print $2}')
  wallet2=$(${PROJECT_DIR}/build/bin/$Bin_NAME account import --password .pwd --datadir ./nodes/2 <(echo ${PRIVATE_KEY_2}) | awk -v FS="({|})" '{print $2}')
  wallet3=$(${PROJECT_DIR}/build/bin/$Bin_NAME account import --password .pwd --datadir ./nodes/3 <(echo ${PRIVATE_KEY_3}) | awk -v FS="({|})" '{print $2}')
  wallet4=$(${PROJECT_DIR}/build/bin/$Bin_NAME account import --password .pwd --datadir ./nodes/4 <(echo ${PRIVATE_KEY_4}) | awk -v FS="({|})" '{print $2}')
  ${PROJECT_DIR}/build/bin/$Bin_NAME --datadir ./nodes/1 init ./genesis/genesis.json
  ${PROJECT_DIR}/build/bin/$Bin_NAME --datadir ./nodes/2 init ./genesis/genesis.json
  ${PROJECT_DIR}/build/bin/$Bin_NAME --datadir ./nodes/3 init ./genesis/genesis.json
  ${PROJECT_DIR}/build/bin/$Bin_NAME --datadir ./nodes/4 init ./genesis/genesis.json
else
  wallet1=$(${PROJECT_DIR}/build/bin/$Bin_NAME account list --datadir ./nodes/1 | head -n 1 | awk -v FS="({|})" '{print $2}')
  wallet2=$(${PROJECT_DIR}/build/bin/$Bin_NAME account list --datadir ./nodes/2 | head -n 1 | awk -v FS="({|})" '{print $2}')
  wallet3=$(${PROJECT_DIR}/build/bin/$Bin_NAME account list --datadir ./nodes/3 | head -n 1 | awk -v FS="({|})" '{print $2}')
  wallet4=$(${PROJECT_DIR}/build/bin/$Bin_NAME account list --datadir ./nodes/4 | head -n 1 | awk -v FS="({|})" '{print $2}')
fi

VERBOSITY=3
GASPRICE="1"
networkid=50


echo Starting the nodes ...

${PROJECT_DIR}/build/bin/$Bin_NAME --bootnodes "enode://048fb0712b244999f62b8c4481f7ed4b2a47632a9b56e4947396b24a8cfa4af9e5490cb36294df76421269d83668f4ac51166bdf85b03b8e912ec07c0e8ef3a6@127.0.0.3:30301" --syncmode "fast" --datadir ./nodes/2 --networkid "${networkid}" --port 30304 --rpc --rpccorsdomain "*" --rpcaddr 0.0.0.0 --ws --wsaddr="0.0.0.0" --wsorigins "*" --wsport 8556 --rpcport 8546 --rpcvhosts "*" --unlock "${wallet2}" --password ./.pwd --mine --gasprice "${GASPRICE}" --targetgaslimit "420000000" --verbosity ${VERBOSITY} --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,XDPoS --ethstats "Leo-Node-02:xinfin_xdpos_hybrid_network_stats@stats.xinfin.network:3000" console 2>>XDC_node2.log
