apt-get update
apt-get install -y \
    curl \
    jq \
    less \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    unzip 

curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.asc.gpg
CLI_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ ${CLI_REPO} main" > /etc/apt/sources.list.d/azure-cli.list
apt-get update
apt-get install -y azure-cli
rm -rf /var/lib/apt/lists/*

curl -sLo tofu.zip https://nightlies.opentofu.org/nightlies/20250909/tofu_nightly-20250909-22910f2b01_linux_amd64.zip
unzip tofu.zip
mkdir /tmp/ott
mv tofu /tmp/ott

curl -fsSL https://get.opentofu.org/opentofu.gpg > /etc/apt/trusted.gpg.d/opentofu.gpg
curl -fsSL https://packages.opentofu.org/opentofu/tofu/gpgkey | gpg --no-tty --batch --dearmor -o /etc/apt/trusted.gpg.d/opentofu-repo.gpg
chmod a+r /etc/apt/trusted.gpg.d/opentofu.gpg /etc/apt/trusted.gpg.d/opentofu-repo.gpg
echo "deb [signed-by=/etc/apt/trusted.gpg.d/opentofu.gpg,/etc/apt/trusted.gpg.d/opentofu-repo.gpg] https://packages.opentofu.org/opentofu/tofu/any/ any main" > /etc/apt/sources.list.d/opentofu.list
echo "deb-src [signed-by=/etc/apt/trusted.gpg.d/opentofu.gpg,/etc/apt/trusted.gpg.d/opentofu-repo.gpg] https://packages.opentofu.org/opentofu/tofu/any/ any main" >> /etc/apt/sources.list.d/opentofu.list 
chmod a+r /etc/apt/sources.list.d/opentofu.list
apt-get update
apt-get install -y tofu

apt-get autoremove 
apt-get clean
