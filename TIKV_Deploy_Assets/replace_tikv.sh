
## replace tikv node with custom verion
cluster=$1
if [ "$1" = "" ]; then
    echo "cluster name should not be empty!"
    exit
fi

set -x

echo update tikv binary of cluster: $cluster

mkdir -p tmp
cp ~/·······/tikv/target/release/tikv-server ./tmp
cd tmp
tar zcf tikv-server.tar.gz tikv-server
tiup cluster patch $cluster ./tikv-server.tar.gz -R tikv
rm tikv-server tikv-server.tar.gz
