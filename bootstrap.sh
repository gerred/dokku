# Repository locations - set environment variables to override defaults
#  e.g. DOKKU_REPO=https://github.com/yourusername/dokku.git bootstrap.sh
GITRECEIVE_URL=${GITRECEIVE_URL:-"https://raw.github.com/progrium/gitreceive/master/gitreceive"}
DOKKU_REPO=${DOKKU_REPO:-"https://github.com/gerred/dokku.git"}

apt-get install -y linux-image-extra-`uname -r` software-properties-common
add-apt-repository -y ppa:dotcloud/lxc-docker
apt-get update && apt-get install -y lxc-docker git ruby nginx make

wget -O /usr/local/bin/gitreceive ${GITRECEIVE_URL}
chmod +x /usr/local/bin/gitreceive
gitreceive init

cd ~ && git clone ${DOKKU_REPO}
cd dokku && make install
cd buildstep && make build

start nginx-reloader
/etc/init.d/nginx start

echo "include /home/git/*/nginx.conf;" > /etc/nginx/conf.d/dokku.conf
if [[ $(dig +short $HOSTNAME) ]]; then
  echo $HOSTNAME > /home/git/DOMAIN
else
  echo $HOSTNAME > /home/git/HOSTNAME
fi

echo
echo "Be sure to upload a public key for your user:"
echo "  cat ~/.ssh/id_rsa.pub | ssh root@$HOSTNAME \"gitreceive upload-key gerred\""
